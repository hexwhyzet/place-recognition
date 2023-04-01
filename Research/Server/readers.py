import datetime
import json
import os
from typing import List

from meta import Direction, Coordinates, ImageMeta
from image import PathImage


def GoogleStreatViewImages() -> List[PathImage]:
    base_path = '/Research/Server/images/google'
    raw_metas = json.loads(open(os.path.join(base_path, 'meta.json'), 'r').read())
    images = []
    for raw_meta in raw_metas:
        image = PathImage(
            path=os.path.join(base_path, raw_meta['id'] + '.' + raw_meta['extension']),
            meta=ImageMeta(
                type='google-panorama',
                height=raw_meta['height'],
                width=raw_meta['width'],
                direction=Direction(degree=raw_meta['direction']),
                coordinates=Coordinates(latitude=raw_meta['latitude'], longitude=raw_meta['longitude']),
                date=datetime.datetime.strptime(raw_meta['date'], "%Y-%m"),
            )
        )
        images.append(image)
    return images
