import datetime
import glob
import json
import os
from typing import List

import numpy as np

from image import PathImage, Direction, Coordinates, ImageMeta, Layer
from rle_decoder import rle2mask


def google_street_view_images(subpath: str = "") -> List[PathImage]:
    base_path = os.path.join('/Users/kabakov/PycharmProjects/place-recognition/Research/Server/images/google', subpath)
    images = []
    for raw_meta_path in glob.glob(os.path.join(base_path, "*.json")):
        raw_meta = json.loads(open(raw_meta_path, 'r').read())
        # print(raw_meta)
        # print(raw_meta.keys())
        image = PathImage(
            path=os.path.join(base_path, raw_meta['filename']),
            meta=ImageMeta(
                type='google-panorama',
                height=raw_meta['resolution']['height'],
                width=raw_meta['resolution']['width'],
                direction=Direction(degree=raw_meta['rotation']),
                coordinates=Coordinates(latitude=raw_meta['lat'], longitude=raw_meta['lng']),
                date=f"{raw_meta['date']['year']}-{raw_meta['date']['month']}",
            )
        )
        images.append(image)
    return images


def read_coco_dataset(path):
    annotations_path = os.path.join(path, "annotations/instances_default.json")
    coco_annotations = json.loads(open(annotations_path, "r").read())
    images_path = os.path.join(path, "images")
    images = coco_annotations["images"]
    categories = coco_annotations["categories"]
    annotations = coco_annotations["annotations"]
    real_id_by_category_id = {category["id"]: int(category["name"][2:]) for category in categories}

    result = []

    for image in images:
        width = image["width"]
        height = image["height"]
        res_annotation = np.zeros((height, width), dtype=np.int32)
        for annotation in annotations:
            if annotation["image_id"] != image["id"]:
                continue

            assert height == annotation["segmentation"]["size"][0]
            assert width == annotation["segmentation"]["size"][1]
            rle = annotation["segmentation"]["counts"]
            mask = rle2mask(rle, (width, height))
            res_annotation[mask] = real_id_by_category_id[annotation["category_id"]]
        path_image = PathImage(
            path=os.path.join(images_path, image["file_name"]),
            meta=ImageMeta(
                type='flat',
                height=height,
                width=width,
                annotations=Layer(content=res_annotation),
            )
        )
        result.append(path_image.open())
    return result


if __name__ == '__main__':
    dataset = read_coco_dataset(
        "/Users/kabakov/PycharmProjects/place-recognition/Research/Server/images/place-recognition-sur-coco")
    test_image = dataset[70]
    test_image.save("TestImage.jpg")
    test_image.meta.annotations.debug_save("TestAnnot.jpg")
    print(test_image.image.content.shape)
    print(test_image.meta.annotations.content.shape)
