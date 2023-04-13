import numpy as np


def rle2mask(rle, shape):
    '''
    mask_rle: run-length as string formated (start length)
    shape: (width,height) of array to return
    Returns numpy array, 1 - mask, 0 - background

    '''
    cur = 0
    img = np.zeros(shape[0] * shape[1], dtype=np.bool_)
    for idx, sector in enumerate(rle):
        img[cur:cur + sector] = idx % 2
        cur += sector
    return img.reshape(shape).T
