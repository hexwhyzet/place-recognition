from descriptor_extractor import NetVlad, MixVPR
from feature_generator import *
from readers import read_coco_dataset
from releaser import create_release

images = read_coco_dataset("./images/place-recognition-sur-coco")
# cropper = Cropper(1280, 1280, 640, 640)
desc_ext = MixVPR()
resizer = Resizer(320, 320)
images = desc_ext(resizer(images))
create_release(images, release_name='v2')
