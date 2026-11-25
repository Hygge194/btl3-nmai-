"""Mutation operators: Random Reassignment and Domain-Aware Swap Mutation."""

from __future__ import annotations

import numpy as np

import config
from src.models import Chromosome
from src.services.data_loader import ProblemData


def random_reassignment_mutation(
    chromosome: Chromosome,
    data: ProblemData,
    mutation_rate: float,
    rng: np.random.Generator,
) -> Chromosome:
    """Standard random gene mutation (used by Baseline GA)."""
    n = len(chromosome.genes)
    mut_indices = np.where(rng.random(n) < mutation_rate)[0]
    for idx in mut_indices:
        g = chromosome.genes[int(idx)]
        choice = int(rng.integers(0, 4))
        if choice == 0:
            g.professor_id = int(rng.integers(0, data.num_professors))
        elif choice == 1:
            d1, d2 = config.VALID_DAY_PAIRS[int(rng.integers(0, len(config.VALID_DAY_PAIRS)))]
            g.session_1.day = d1
            g.session_2.day = d2
        elif choice == 2:
            g.session_1.timeslot = int(rng.integers(0, data.num_timeslots))
            g.session_1.room_id = int(rng.integers(0, data.num_rooms))
        else:
            g.session_2.timeslot = int(rng.integers(0, data.num_timeslots))
            g.session_2.room_id = int(rng.integers(0, data.num_rooms))
    return chromosome


def smart_swap_mutation(
    chromosome: Chromosome,
    data: ProblemData,
    mutation_rate: float,
    rng: np.random.Generator,
) -> Chromosome:
    """Domain-aware mutation combining eligible professor reassignment, feasible room/slot
    relocation, balanced day-pair shift, and two-section Swap Mutation."""
    n = len(chromosome.genes)
    mut_indices = np.where(rng.random(n) < mutation_rate)[0]

    for idx in mut_indices:
        idx = int(idx)
        g = chromosome.genes[idx]
        c_id = int(data.section_course_arr[g.section_id])
        sz = int(data.section_size_arr[g.section_id])
        mode = float(rng.random())

        if mode < 0.25:
            # Reassign professor from favorite/eligible pool
            pool = (
                data.course_favorite_profs[c_id]
                if rng.random() < 0.70 and data.course_favorite_profs[c_id]
                else data.course_eligible_profs[c_id]
            )
            if pool:
                g.professor_id = int(rng.choice(pool))
        elif mode < 0.50:
            # Relocate session 1 to a feasible available room
            t = int(rng.integers(0, data.num_timeslots))
            rooms = data.feasible_rooms_compat[(g.session_1.day, t, sz)]
            if rooms:
                g.session_1.timeslot = t
                g.session_1.room_id = int(rng.choice(rooms))
        elif mode < 0.75:
            # Relocate session 2 to a feasible available room
            t = int(rng.integers(0, data.num_timeslots))
            rooms = data.feasible_rooms_compat[(g.session_2.day, t, sz)]
            if rooms:
                g.session_2.timeslot = t
                g.session_2.room_id = int(rng.choice(rooms))
        elif mode < 0.90:
            # Swap Mutation: swap full schedule (both sessions) with another equal-size section
            other_idx = int(rng.integers(0, n))
            if other_idx != idx and int(data.section_size_arr[other_idx]) == sz:
                og = chromosome.genes[other_idx]
                g.session_1, og.session_1 = og.session_1, g.session_1
                g.session_2, og.session_2 = og.session_2, g.session_2
        else:
            # Change to a balanced valid day pair with feasible rooms
            dp = int(rng.choice(len(config.VALID_DAY_PAIRS), p=config.BALANCED_DAY_PAIR_PROBS))
            d1, d2 = config.VALID_DAY_PAIRS[dp]
            r1_pool = data.feasible_rooms_compat[(d1, g.session_1.timeslot, sz)]
            r2_pool = data.feasible_rooms_compat[(d2, g.session_2.timeslot, sz)]
            if r1_pool and r2_pool:
                g.session_1.day = d1
                g.session_1.room_id = int(rng.choice(r1_pool))
                g.session_2.day = d2
                g.session_2.room_id = int(rng.choice(r2_pool))

    return chromosome
