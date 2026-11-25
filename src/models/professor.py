"""Professor domain model (including Bonus 1 & 2 course lists)."""

from dataclasses import dataclass, field
from typing import List


@dataclass
class Professor:
    id: int
    code: str
    name: str
    eligible_courses: List[int] = field(default_factory=list)
    favorite_courses: List[int] = field(default_factory=list)  # Top-3 ranked
    max_sessions: int = 20
