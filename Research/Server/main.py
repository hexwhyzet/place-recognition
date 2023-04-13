from descriptor_extractor import NetVlad
from feature_generator import *
from readers import read_coco_dataset
from releaser import create_release

images = dataset = read_coco_dataset("./images/place-recognition-sur-coco")
cropper = SquareCrop()
netvlad = NetVlad()
resizer = Resizer(512, 512)
images = netvlad(resizer(cropper(images)))
s = create_release(images, release_name='v1')
