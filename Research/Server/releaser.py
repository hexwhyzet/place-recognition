import glob
import os
import pickle
from dataclasses import dataclass
from typing import List

from image import NdarrayImage, PathImage

PATH_TO_RELEASES = './releases'


@dataclass
class Release:
    name: str
    images: List[PathImage]


def empty_directory(directory):
    files = glob.glob(os.path.join(directory, '*'))
    for f in files:
        os.remove(f)


def save_obj(obj, path):
    return pickle.dump(obj, open(path, 'wb+'))


def get_obj(path):
    return pickle.load(open(path, 'rb'))


def release_obj_path(release_name):
    return os.path.join(PATH_TO_RELEASES, release_name, 'release.pkl')


def create_release(images: List[NdarrayImage], release_name) -> Release:
    release_images = []
    directory = os.path.join(PATH_TO_RELEASES, release_name)
    if os.path.exists(directory):
        empty_directory(directory)
    else:
        os.mkdir(directory)
    for i, image in enumerate(images):
        image_path = os.path.join(directory, f'{i}.jpg')
        annotations_path = os.path.join(directory, f'{i}_annotation.jpg')
        path_image = image.save(image_path)
        path_image.meta.annotations.debug_save(annotations_path)
        release_images.append(path_image)
    release = Release(name=release_name, images=release_images)
    save_obj(release, release_obj_path(release_name))
    return release
