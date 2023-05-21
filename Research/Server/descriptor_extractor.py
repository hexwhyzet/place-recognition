import sys
from typing import List

import numpy as np
import torch

from feature_generator import FeatureGenerator
from image import NdarrayImage, PathImage, ImageMeta

sys.path.append("../pytorch-NetVlad")
import netvald_interface

sys.path.append("../mixVPR")
import mixvpr_interface


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
        assert image.image.content.shape == (512, 512, 3)
        tensor = torch.tensor(np.expand_dims(np.moveaxis(image.image.content, [2], [0]), axis=0).astype(np.float32))
        return self.model.pred(tensor)[0].detach().numpy()


class MixVPR(DescriptorExtractor):
    def __init__(self):
        self.model = mixvpr_interface.get_loaded_model()

    def filter(self, image: NdarrayImage) -> bool:
        return True

    def descriptor(self, image: NdarrayImage) -> np.ndarray:
        assert image.image.content.shape == (320, 320, 3)
        tensor = torch.tensor(np.expand_dims(np.moveaxis(image.image.content, [2], [0]), axis=0).astype(np.float32))
        return self.model(tensor)[0].detach().numpy()
