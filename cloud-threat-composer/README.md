# Cloud Threat Composer

A lightweight STRIDE threat-modelling application built as a DevSecOps portfolio project. Users can create architecture projects, record threats, calculate risk from likelihood × impact, track mitigations, and use cloud-specific threat suggestions.

## Features

- Create and delete threat-model projects
- Add threats using all six STRIDE categories
- Score likelihood and impact from 1–5
- Automatically classify Low, Medium, High, and Critical risk
- Track Open, Mitigated, and Accepted threats
- Filter the threat register by severity
- Suggestions for API, S3, EC2, RDS, and ECS components
- PostgreSQL in Docker, with SQLite as a zero-setup local fallback
- Health endpoint and automated tests
- Non-root production container with a container health check

## Architecture

```text
Browser → FastAPI/Jinja UI → SQLAlchemy → PostgreSQL
```

This repository contains the application layer. The planned deployment layer is GitHub Actions → ECR → ECS Fargate behind an ALB, with RDS PostgreSQL and Terraform-managed infrastructure.

## Run with Docker (recommended)

Install Docker Desktop, then run:

```bash
cp .env.example .env            # Windows PowerShell: Copy-Item .env.example .env
docker compose up --build
```

Open <http://localhost:8000>. Stop with `Ctrl+C`, then run `docker compose down`. Add `-v` only if you intentionally want to delete the database volume.

## Run directly with Python

This method uses a local SQLite database automatically:

```bash
python -m venv .venv
source .venv/bin/activate       # Windows PowerShell: .venv\Scripts\Activate.ps1
pip install -r requirements-dev.txt
uvicorn app.main:app --reload
```

Open <http://localhost:8000>.

## Run tests

```bash
pytest -q
```

## Continuous integration

The `.github/workflows/ci.yml` workflow runs for pushes and pull requests to
`main`:

1. Install the development dependencies.
2. Run the pytest suite.
3. Build the production Docker image.
4. Scan the image with Trivy.
5. Fail when a fixable Critical vulnerability is detected.

The workflow builds but does not publish the image. Publishing to Amazon ECR
will be added after Terraform creates the repository and GitHub OIDC role.

## Risk calculation

`risk score = likelihood × impact`

| Score | Severity |
|---:|---|
| 20–25 | Critical |
| 12–19 | High |
| 6–11 | Medium |
| 1–5 | Low |

## Repository structure

```text
app/
├── data/threat_library.json  # Cloud threat suggestions
├── static/                   # CSS and browser JavaScript
├── templates/                # Jinja HTML views
├── database.py               # Engine and database sessions
├── main.py                   # Routes and application setup
└── models.py                 # SQLAlchemy entities and risk logic
tests/                        # Unit and HTTP smoke tests
.github/workflows/ci.yml      # Tests, image build, and Trivy scan
Dockerfile                    # Production container
docker-compose.yml            # App + local PostgreSQL
```

## Portfolio ownership

The application code in this repository is an original, intentionally small implementation created for learning and portfolio use. Be ready to explain the request flow, database relationships, risk thresholds, and why the production architecture uses ECS, ALB, and RDS.

## Next stage

1. Write Terraform for VPC, ALB, ECS, ECR, RDS, IAM, and CloudWatch.
2. Add Checkov scanning for Terraform.
3. Configure GitHub OIDC and publish immutable images to ECR.
4. Deploy the image to ECS Fargate.
