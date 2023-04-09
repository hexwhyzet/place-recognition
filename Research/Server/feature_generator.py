from copy import deepcopy
from typing import List, Union

import cv2

from image import NdarrayImage


class FeatureGenerator:
    name: str = 'default'

    def __call__(self, images: Union[NdarrayImage, List[NdarrayImage]]) -> List[NdarrayImage]:
        if not isinstance(images, List):
            images = [images]
        result_images = []
        for image in images:
            if self.filter(image):
                image.meta.features.append(self.name)
                result_images.extend(self.transform(image))
        return result_images

    def filter(self, image: NdarrayImage) -> bool:
        raise NotImplementedError

    def transform(self, image: NdarrayImage) -> List[NdarrayImage]:
        raise NotImplementedError


class Cropper(FeatureGenerator):
    name = 'cropper'

    def __init__(self, width, height, width_stride=None, height_stride=None):
        self.height = height
        self.width = width
        self.height_stride = height_stride or height
        self.width_stride = width_stride or width

    def filter(self, image: NdarrayImage) -> bool:
        return True

    def transform(self, image: NdarrayImage) -> List[NdarrayImage]:
        images = []
        for height_end in range(self.height, image.height + 1, self.height_stride):
            for width_end in range(self.width, image.width + 1, self.width_stride):
                width_start = width_end - self.width
                height_start = height_end - self.height
                images.append(image.crop(width_start=width_start,
                                         width_end=width_end,
                                         height_start=height_start,
                                         height_end=height_end))
        return images


class Resizer(FeatureGenerator):
    name = 'scaler'

    def __init__(self, width=None, height=None, width_scale=None, height_scale=None):
        self.width = width
        self.height = height
        self.width_scale = width_scale
        self.height_scale = height_scale

    def filter(self, image: NdarrayImage) -> bool:
        return True

    def transform(self, image: NdarrayImage) -> List[NdarrayImage]:
        return [image.resize(width=self.width,
                             height=self.height,
                             width_scale=self.width_scale,
                             height_scale=self.height_scale)]


class SquareCrop(FeatureGenerator):
    name = 'square_crop'

    def filter(self, image: NdarrayImage) -> bool:
        return True

    def transform(self, image: NdarrayImage) -> List[NdarrayImage]:
        return [image.square_crop()]
