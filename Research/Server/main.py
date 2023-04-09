from descriptor_extractor import NetVlad
from feature_generator import *
from releaser import create_release
from readers import read_coco_dataset

# path_image = PathImage(
#     path='/Users/kabakov/PycharmProjects/place-recognition/Research/Server/images/google/6MctSlMu0L2ukWG7CSSgCQ.jpg',
#     meta=ImageMeta(8192, 16384, "test"))
# nd_image = image_to_ndarray(path_image)
# cropper = Cropper(512, 512, 256, 256)
# scaler = Scaler(0.15, 0.15)
# netvlad = NetVlad()
# images = netvlad(cropper(scaler(nd_image)))
# # for idx, image in enumerate(images):
#     # print(idx, image)
#     # ndarray_to_image(image, path=f'Sample{idx}.png')
# # print(images)
# s = create_release(images, 'test')

images = dataset = read_coco_dataset(
    "/Users/kabakov/PycharmProjects/place-recognition/Research/Server/images/place-recognition-sur-coco")
cropper = SquareCrop()
netvlad = NetVlad()
resizer = Resizer(512, 512)
images = netvlad(resizer(cropper(images)))
s = create_release(images, release_name='test')
