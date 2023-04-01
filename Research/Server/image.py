from dataclasses import dataclass

import cv2
import numpy as np

from meta import ImageMeta


@dataclass
class PathImage:
    path: str
    meta: ImageMeta


@dataclass
class NdarrayImage:
    ndarray: np.ndarray
    meta: ImageMeta


def image_to_ndarray(image: PathImage) -> NdarrayImage:
    bgr_ndarray = cv2.imread(image.path)
    rgb_ndarray = cv2.cvtColor(bgr_ndarray, cv2.COLOR_BGR2RGB)
    return NdarrayImage(ndarray=rgb_ndarray, meta=image.meta)


def ndarray_to_image(image: NdarrayImage, path: str) -> PathImage:
    cv2.imwrite(path, cv2.cvtColor(image.ndarray, cv2.COLOR_RGB2BGR))
    return PathImage(path=path, meta=image.meta)
