"""Central configuration for Class Scheduling using Genetic Algorithm (CO3061)."""

from pathlib import Path

# ---------------------------------------------------------------------------
# Problem configuration (matching HW3_.pdf)
# ---------------------------------------------------------------------------
NUM_COURSES = 60
SECTIONS_PER_COURSE = 8
SESSIONS_PER_SECTION = 2
NUM_SECTIONS = NUM_COURSES * SECTIONS_PER_COURSE          # 480
NUM_SESSIONS = NUM_SECTIONS * SESSIONS_PER_SECTION        # 960
NUM_PROFESSORS = 60
NUM_ROOMS = 35
NUM_DAYS = 5                                              # 0..4 (Mon..Fri)
NUM_TIMESLOTS = 6                                         # 0..5 (1-3 Morning, 4-6 Afternoon)
MAX_PROFESSOR_SESSIONS = 20
ROOM_UNAVAILABLE_RATIO = 0.025                            # ~2.5% unavailable room-slots

# Valid non-same, non-adjacent day pairs: |d2 - d1| >= 2
VALID_DAY_PAIRS = (
    (0, 2),  # Mon - Wed
    (0, 3),  # Mon - Thu
    (0, 4),  # Mon - Fri
    (1, 3),  # Tue - Thu
    (1, 4),  # Tue - Fri
    (2, 4),  # Wed - Fri
)

# Balanced day-pair probabilities solving Mon/Fri bottleneck (E[load] = 192/day)
BALANCED_DAY_PAIR_PROBS = (0.20, 0.18, 0.02, 0.22, 0.18, 0.20)

DAY_NAMES_EN = ("Mon", "Tue", "Wed", "Thu", "Fri")
DAY_NAMES_VI = ("Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6")
SIZE_LABELS_EN = {0: "Small", 1: "Average", 2: "Large"}
SIZE_LABELS_VI = {0: "Nhỏ (0)", 1: "Trung bình (1)", 2: "Lớn (2)"}

# ---------------------------------------------------------------------------
# Genetic Algorithm configuration
# ---------------------------------------------------------------------------
POPULATION_SIZE = 80
MAX_GENERATIONS = 200
CROSSOVER_RATE = 0.85
MUTATION_RATE = 0.015
MAX_MUTATION_RATE = 0.06
TOURNAMENT_SIZE = 5
ELITE_SIZE = 5
REPAIR_RATE = 0.40
RANDOM_SEED = 42
GA_SEED = 2026

# ---------------------------------------------------------------------------
# Fitness & Penalty Weights (Weighted Penalty Function: F(x) = 1 / (1 + P(x)))
# ---------------------------------------------------------------------------
HARD_PENALTY = 100_000.0

SOFT_WEIGHTS = {
    "idle_gap": 5.0,       # S1: professor_idle_gap (intra-day gaps)
    "day_scatter": 3.0,    # S2: professor_day_scatter (intra-week gaps)
    "prof_shift": 5.0,     # S3: professor_shift_conflict (morning+afternoon same day)
    "course_shift": 3.0,   # S4: course_shift_conflict (course morning/afternoon split)
    "room_mismatch": 1.0,  # S5: room_size_mismatch (room_size - section_size)
}

BONUS_WEIGHTS = {
    "not_in_list": 5_000.0,       # Bonus 2: professor teaches course NOT in eligible list
    "no_favorite": 2_000.0,       # Bonus 1: professor has 0 favorite classes from top-3
    "non_favorite_section": 1.5,  # Bonus 1 soft preference: encourage top-3 favorite sections
}

# ---------------------------------------------------------------------------
# Directory paths
# ---------------------------------------------------------------------------
BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "data"
OUTPUT_DIR = BASE_DIR / "outputs"
FIGURES_DIR = OUTPUT_DIR / "figures"
DOCS_DIR = BASE_DIR / "docs"
