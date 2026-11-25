"""Course domain model."""

from dataclasses import dataclass


@dataclass(frozen=True)
class Course:
    id: int
    code: str
    name: str
