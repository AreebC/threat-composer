from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .database import Base


class Project(Base):
    __tablename__ = "projects"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(120))
    description: Mapped[str] = mapped_column(Text, default="")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    threats: Mapped[list["Threat"]] = relationship(
        back_populates="project", cascade="all, delete-orphan"
    )


class Threat(Base):
    __tablename__ = "threats"

    id: Mapped[int] = mapped_column(primary_key=True)
    project_id: Mapped[int] = mapped_column(ForeignKey("projects.id"), index=True)
    name: Mapped[str] = mapped_column(String(160))
    description: Mapped[str] = mapped_column(Text, default="")
    component: Mapped[str] = mapped_column(String(60), default="Other")
    stride_category: Mapped[str] = mapped_column(String(40))
    likelihood: Mapped[int] = mapped_column(Integer)
    impact: Mapped[int] = mapped_column(Integer)
    mitigation: Mapped[str] = mapped_column(Text, default="")
    status: Mapped[str] = mapped_column(String(20), default="Open")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    project: Mapped[Project] = relationship(back_populates="threats")

    @property
    def risk_score(self) -> int:
        return self.likelihood * self.impact

    @property
    def severity(self) -> str:
        return severity_for(self.risk_score)


def severity_for(score: int) -> str:
    if score >= 20:
        return "Critical"
    if score >= 12:
        return "High"
    if score >= 6:
        return "Medium"
    return "Low"
