import datetime
from dataclasses import dataclass, field
from typing import Optional

import numpy as np


@dataclass
class Coordinates:
    latitude: float
    longitude: float


@dataclass
class Direction:
    degree: float


@dataclass
class ImageMeta:
    height: int
    width: int
    type: str
    descriptor: Optional[np.array] = None
    coordinates: Optional[Coordinates] = None
    direction: Optional[Direction] = None
    date: Optional[datetime.date] = None
    features: list = field(default_factory=list)
    tags: list = field(default_factory=list)
