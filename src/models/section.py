"""Section domain model."""

from dataclasses import dataclass


@dataclass(frozen=True)
class Section:
    id: int
    code: str
    course_id: int
    registration_size: int  # 0=Small, 1=Average, 2=Large
