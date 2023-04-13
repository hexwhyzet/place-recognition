from copy import deepcopy
from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional, Callable

import cv2
import matplotlib.pyplot as plt
import numpy as np


@dataclass
class Coordinates:
    latitude: float
    longitude: float


@dataclass
class Direction:
    degree: float


@dataclass
class Layer:
    content: np.ndarray

    @property
    def width(self):
        return self.content.shape[1]

    @property
    def height(self):
        return self.content.shape[0]

    def resize(self, width, height):
        return Layer(
            content=cv2.resize(
                self.content,
                dsize=(width, height),
                interpolation=cv2.INTER_LINEAR_EXACT,
            ),
        )

    def crop(self, width_start, width_end, height_start, height_end):
        return Layer(
            content=self.content[height_start:height_end, width_start:width_end],
        )

    def center_crop(self, width, height):
        dim_width, dim_height = width, height
        crop_width = dim_width if dim_width < self.width else self.width
        crop_height = dim_height if dim_height < self.height else self.height
        mid_x, mid_y = int(self.width / 2), int(self.height / 2)
        cw2, ch2 = int(crop_width / 2), int(crop_height / 2)
        return self.crop(mid_x - cw2, mid_x + cw2, mid_y - ch2, mid_y + ch2)

    def square_crop(self):
        square_side = min(self.width, self.height)
        return self.center_crop(square_side, square_side)

    def debug_save(self, path):
        plt.imsave(path, self.content, cmap='gray')
        # cv2.imwrite(path, self.content)


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
    annotations: Layer = None


@dataclass
class PathImage:
    path: str
    meta: ImageMeta

    def open(self):
        bgr_ndarray = cv2.imread(self.path)
        rgb_ndarray = cv2.cvtColor(bgr_ndarray, cv2.COLOR_BGR2RGB)
        return NdarrayImage(image=Layer(content=rgb_ndarray), meta=deepcopy(self.meta))


@dataclass
class NdarrayImage:
    image: Layer
    meta: ImageMeta

    @property
    def width(self):
        return self.image.width

    @property
    def height(self):
        return self.image.height

    def check_layer_dimensions(self):
        for layer in [self.meta.annotations]:
            if layer is not None:
                assert layer.height == self.height and layer.width == self.width

    def __post_init__(self):
        self.check_layer_dimensions()

    def __modify_layers(self, f: Callable[[Layer], Layer]):
        new_meta = deepcopy(self.meta)
        new_meta.annotations = f(self.meta.annotations)
        return NdarrayImage(
            image=f(self.image),
            meta=new_meta,
        )

    def resize(self, width=None, height=None, width_scale=None, height_scale=None):
        if width is None:
            if width_scale is None:
                raise Exception("width or width_scale should be specified")
            width = int(self.meta.width * width_scale)
        if height is None:
            if height_scale is None:
                raise Exception("height or height_scale should be specified")
            height = int(self.meta.height * height_scale)
        return self.__modify_layers(lambda layer: layer.resize(width, height))

    def crop(self, width_start, width_end, height_start, height_end):
        return self.__modify_layers(lambda layer: layer.crop(width_start, width_end, height_start, height_end))

    def center_crop(self, width, height):
        return self.__modify_layers(lambda layer: layer.center_crop(width, height))

    def square_crop(self):
        return self.__modify_layers(lambda layer: layer.square_crop())

    def save(self, path):
        cv2.imwrite(path, cv2.cvtColor(self.image.content, cv2.COLOR_RGB2BGR))
        return PathImage(path=path, meta=deepcopy(self.meta))
