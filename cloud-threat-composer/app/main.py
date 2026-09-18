import json
from pathlib import Path

from fastapi import Depends, FastAPI, Form, HTTPException, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from .database import Base, engine, get_db
from .models import Project, Threat


BASE_DIR = Path(__file__).resolve().parent
STRIDE_CATEGORIES = [
    "Spoofing", "Tampering", "Repudiation", "Information Disclosure",
    "Denial of Service", "Elevation of Privilege"
]
STATUSES = ["Open", "Mitigated", "Accepted"]
COMPONENTS = ["API", "S3", "EC2", "RDS", "ECS", "Other"]

with (BASE_DIR / "data" / "threat_library.json").open(encoding="utf-8") as file:
    THREAT_LIBRARY = json.load(file)

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Cloud Threat Composer", version="1.0.0")
app.mount("/static", StaticFiles(directory=BASE_DIR / "static"), name="static")
templates = Jinja2Templates(directory=BASE_DIR / "templates")


def get_project_or_404(project_id: int, db: Session) -> Project:
    project = db.scalar(
        select(Project)
        .where(Project.id == project_id)
        .options(selectinload(Project.threats))
    )
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return project


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/", response_class=HTMLResponse)
def home(request: Request, db: Session = Depends(get_db)):
    projects = db.scalars(
        select(Project).options(selectinload(Project.threats)).order_by(Project.created_at.desc())
    ).all()
    return templates.TemplateResponse(request, "index.html", {"projects": projects})


@app.post("/projects")
def create_project(
    name: str = Form(min_length=1, max_length=120),
    description: str = Form(default="", max_length=2000),
    db: Session = Depends(get_db),
):
    project = Project(name=name.strip(), description=description.strip())
    db.add(project)
    db.commit()
    db.refresh(project)
    return RedirectResponse(f"/projects/{project.id}", status_code=303)


@app.get("/projects/{project_id}", response_class=HTMLResponse)
def project_dashboard(project_id: int, request: Request, db: Session = Depends(get_db)):
    project = get_project_or_404(project_id, db)
    summary = {level: 0 for level in ["Critical", "High", "Medium", "Low"]}
    for threat in project.threats:
        summary[threat.severity] += 1
    return templates.TemplateResponse(request, "project.html", {
        "project": project,
        "summary": summary,
        "stride_categories": STRIDE_CATEGORIES,
        "statuses": STATUSES,
        "components": COMPONENTS,
        "threat_library": THREAT_LIBRARY,
    })


@app.post("/projects/{project_id}/threats")
def create_threat(
    project_id: int,
    name: str = Form(min_length=1, max_length=160),
    description: str = Form(default="", max_length=3000),
    component: str = Form(default="Other"),
    stride_category: str = Form(),
    likelihood: int = Form(ge=1, le=5),
    impact: int = Form(ge=1, le=5),
    mitigation: str = Form(default="", max_length=3000),
    status: str = Form(default="Open"),
    db: Session = Depends(get_db),
):
    get_project_or_404(project_id, db)
    if stride_category not in STRIDE_CATEGORIES or status not in STATUSES or component not in COMPONENTS:
        raise HTTPException(status_code=422, detail="Invalid threat option")
    db.add(Threat(
        project_id=project_id, name=name.strip(), description=description.strip(),
        component=component, stride_category=stride_category,
        likelihood=likelihood, impact=impact, mitigation=mitigation.strip(), status=status,
    ))
    db.commit()
    return RedirectResponse(f"/projects/{project_id}", status_code=303)


@app.post("/projects/{project_id}/threats/{threat_id}/status")
def update_threat_status(
    project_id: int, threat_id: int, status: str = Form(), db: Session = Depends(get_db)
):
    if status not in STATUSES:
        raise HTTPException(status_code=422, detail="Invalid status")
    threat = db.scalar(select(Threat).where(Threat.id == threat_id, Threat.project_id == project_id))
    if not threat:
        raise HTTPException(status_code=404, detail="Threat not found")
    threat.status = status
    db.commit()
    return RedirectResponse(f"/projects/{project_id}", status_code=303)


@app.post("/projects/{project_id}/threats/{threat_id}/delete")
def delete_threat(project_id: int, threat_id: int, db: Session = Depends(get_db)):
    threat = db.scalar(select(Threat).where(Threat.id == threat_id, Threat.project_id == project_id))
    if not threat:
        raise HTTPException(status_code=404, detail="Threat not found")
    db.delete(threat)
    db.commit()
    return RedirectResponse(f"/projects/{project_id}", status_code=303)


@app.post("/projects/{project_id}/delete")
def delete_project(project_id: int, db: Session = Depends(get_db)):
    project = get_project_or_404(project_id, db)
    db.delete(project)
    db.commit()
    return RedirectResponse("/", status_code=303)
