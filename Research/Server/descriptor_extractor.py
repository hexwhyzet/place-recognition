import sys
from typing import List

import numpy as np
import torch

from feature_generator import FeatureGenerator
from image import image_to_ndarray
from meta import ImageMeta
from image import NdarrayImage, PathImage

sys.path.append("../pytorch-NetVlad")
import netvald_interface


class DescriptorExtractor(FeatureGenerator):
    name = 'descriptor'

    def transform(self, image: NdarrayImage) -> List[NdarrayImage]:
        image.meta.descriptor = self.descriptor(image)
        return [image]

    def descriptor(self, image: NdarrayImage) -> np.array:
        raise NotImplementedError


class NetVlad(DescriptorExtractor):
    def __init__(self):
        opt = netvald_interface.Options(
            dataPath='/Users/kabakov/PycharmProjects/place-recognition/Research/pytorch-NetVlad/Pittsburgh250k/data',
        )
        self.model = netvald_interface.NetVladModel(opt=opt)

    def filter(self, image: NdarrayImage) -> bool:
        return True

    def descriptor(self, image: NdarrayImage) -> np.ndarray:
        # may be wrong order of axis ??? second and third, width and height
        assert image.ndarray.shape == (512, 512, 3)
        tensor = torch.tensor(np.expand_dims(np.moveaxis(image.ndarray, [2], [0]), axis=0).astype(np.float32))
        return self.model.pred(tensor)[0].detach().numpy()


if __name__ == '__main__':
    path_image = PathImage(path='Sample.png', meta=ImageMeta(100, 100, "test"))
    nd_image = image_to_ndarray(path_image).ndarray.shape

    print(nd_image)
    # nd_image = NdarrayImage(ndarray=np.random.rand(512, 512, 3), meta=ImageMeta(100, 100, "test"))
    # nva = NetVlad()
    # # # print(nd_image.ndarray.shape)
    # print(nva.descriptor(image=nd_image))
