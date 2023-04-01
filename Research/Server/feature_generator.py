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

    def __init__(self, height, width, height_stride=None, width_stride=None):
        self.height = height
        self.width = width
        self.height_stride = height_stride or height
        self.width_stride = width_stride or width

    def filter(self, image: NdarrayImage) -> bool:
        return True

    def transform(self, image: NdarrayImage) -> List[NdarrayImage]:
        images = []
        for upper_height in range(self.height, image.meta.height + 1, self.height_stride):
            for right_width in range(self.width, image.meta.width + 1, self.width_stride):
                new_meta = deepcopy(image.meta)
                new_meta.height = self.height
                new_meta.width = self.width
                cropped_image = NdarrayImage(
                    ndarray=image.ndarray[upper_height - self.height:upper_height,
                            right_width - self.width:right_width],
                    meta=new_meta,
                )
                images.append(cropped_image)
        return images


class Scaler(FeatureGenerator):
    name = 'scaler'

    def __init__(self, height_scale, width_scale):
        self.height_scale = height_scale
        self.width_scale = width_scale

    def filter(self, image: NdarrayImage) -> bool:
        return True

    def transform(self, image: NdarrayImage) -> List[NdarrayImage]:
        new_height = int(image.meta.height * self.height_scale)
        new_width = int(image.meta.width * self.width_scale)
        new_meta = deepcopy(image.meta)
        new_meta.height = new_height
        new_meta.width = new_width
        return [NdarrayImage(
            ndarray=cv2.resize(image.ndarray, dsize=(new_width, new_height)),
            meta=new_meta,
        )]
