"""Room domain model."""

from dataclasses import dataclass
from typing import List


@dataclass
class Room:
    id: int
    code: str
    size: int                      # 0=Small, 1=Average, 2=Large
    availability: List[List[bool]]  # shape [NUM_DAYS][NUM_TIMESLOTS]

    def is_available(self, day: int, timeslot: int) -> bool:
        return self.availability[day][timeslot]
