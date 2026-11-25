"""Session domain model (a single scheduled lecture)."""

from dataclasses import dataclass


@dataclass
class Session:
    day: int       # 0..4 (Mon..Fri)
    timeslot: int  # 0..5 (1..3 Morning, 4..6 Afternoon)
    room_id: int   # 0..34

    def copy(self) -> "Session":
        return Session(day=self.day, timeslot=self.timeslot, room_id=self.room_id)
