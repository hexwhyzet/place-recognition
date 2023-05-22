from __future__ import print_function
import argparse
from dataclasses import dataclass

from math import log10, ceil
import random, shutil, json
from os.path import join, exists, isfile, realpath, dirname
from os import makedirs, remove, chdir, environ

import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.autograd import Variable
from torch.utils.data import DataLoader, SubsetRandomSampler
from torch.utils.data.dataset import Subset
import torchvision.transforms as transforms
from PIL import Image
from datetime import datetime
import torchvision.datasets as datasets
import torchvision.models as models
import h5py
import faiss

from tensorboardX import SummaryWriter
import numpy as np
import netvlad_model


@dataclass
class Options:
    batchSize: int = 4
    cacheBatchSize: int = 24
    cacheRefreshRate: int = 1000
    nEpochs: int = 30
    start_epoch: int = 0
    nGPU: int = 1
    optim: str = 'SGD'
    lr: float = 0.0001
    lrStep: int = 5
    lrGamma: float = 0.5
    weightDecay: float = 0.001
    momentum: float = 0.9
    nocuda: bool = True
    threads: int = 8
    seed: int = 123
    dataPath: str = None
    resume: str = None
    ckpt: str = 'latest'
    evalEvery: int = 1
    patience: int = 10
    dataset: str = 'pittsburgh'
    arch: str = 'vgg16'
    vladv2: bool = True
    pooling: str = 'netvlad'
    num_clusters: int = 64
    margin: float = 0.1
    split: str = 'val'
    fromscratch: bool = False


class NetVladModel:
    def __init__(self, opt: Options):
        self.opt = opt

        if opt.dataset.lower() == 'pittsburgh':
            import pittsburgh as dataset
        else:
            raise Exception('Unknown dataset')

        self.cuda = not opt.nocuda
        if self.cuda and not torch.cuda.is_available():
            raise Exception("No GPU found, please run with --nocuda")

        self.device = torch.device("cuda" if self.cuda else "cpu")

        random.seed(opt.seed)
        np.random.seed(opt.seed)
        torch.manual_seed(opt.seed)
        if self.cuda:
            torch.cuda.manual_seed(opt.seed)

        print('===> Loading dataset(s)')
        if opt.split.lower() == 'test':
            whole_test_set = dataset.get_whole_test_set()
            print('===> Evaluating on test set')
        elif opt.split.lower() == 'test250k':
            whole_test_set = dataset.get_250k_test_set()
            print('===> Evaluating on test250k set')
        elif opt.split.lower() == 'train':
            whole_test_set = dataset.get_whole_training_set()
            print('===> Evaluating on train set')
        elif opt.split.lower() == 'val':
            whole_test_set = dataset.get_whole_val_set()
            print('===> Evaluating on val set')
        else:
            raise ValueError('Unknown dataset split: ' + opt.split)
        print('====> Query count:', whole_test_set.dbStruct.numQ)

        print('===> Building model')

        pretrained = not opt.fromscratch
        if opt.arch.lower() == 'alexnet':
            self.encoder_dim = 256
            encoder = models.alexnet(pretrained=pretrained)
            # capture only features and remove last relu and maxpool
            layers = list(encoder.features.children())[:-2]

            if pretrained:
                # if using pretrained only train conv5
                for l in layers[:-1]:
                    for p in l.parameters():
                        p.requires_grad = False

        elif opt.arch.lower() == 'vgg16':
            self.encoder_dim = 512
            encoder = models.vgg16(pretrained=pretrained)
            # capture only feature part and remove last relu and maxpool
            layers = list(encoder.features.children())[:-2]

            if pretrained:
                # if using pretrained then only train conv5_1, conv5_2, and conv5_3
                for l in layers[:-5]:
                    for p in l.parameters():
                        p.requires_grad = False
        else:
            raise ValueError('Uknown dataset arch')

        encoder = nn.Sequential(*layers)
        self.model = nn.Module()
        self.model.add_module('encoder', encoder)

        if opt.pooling.lower() == 'netvlad':
            net_vlad = netvlad_model.NetVLAD(num_clusters=opt.num_clusters, dim=self.encoder_dim, vladv2=opt.vladv2)
            initcache = join(opt.dataPath, 'centroids', opt.arch + '_' + whole_test_set.dataset + '_' + str(
                opt.num_clusters) + '_desc_cen.hdf5')

            print(initcache)

            if not exists(initcache):
                raise FileNotFoundError(
                    'Could not find clusters, please run with --mode=cluster before proceeding')

            with h5py.File(initcache, mode='r') as h5:
                clsts = h5.get("centroids")[...]
                traindescs = h5.get("descriptors")[...]
                net_vlad.init_params(clsts, traindescs)
                del clsts, traindescs

            self.model.add_module('pool', net_vlad)
        elif opt.pooling.lower() == 'max':
            global_pool = nn.AdaptiveMaxPool2d((1, 1))
            self.model.add_module('pool', nn.Sequential(*[global_pool, Flatten(), L2Norm()]))
        elif opt.pooling.lower() == 'avg':
            global_pool = nn.AdaptiveAvgPool2d((1, 1))
            self.model.add_module('pool', nn.Sequential(*[global_pool, Flatten(), L2Norm()]))
        else:
            raise ValueError('Unknown pooling type: ' + opt.pooling)

        isParallel = False
        if opt.nGPU > 1 and torch.cuda.device_count() > 1:
            self.model.encoder = nn.DataParallel(self.model.encoder)
            self.model.pool = nn.DataParallel(self.model.pool)
            isParallel = True

        self.model = self.model.to(self.device)

    def pred(self, image):
        image_encoding = self.model.encoder(image.to(self.device))
        vlad_encoding = self.model.pool(image_encoding)
        return vlad_encoding


class Flatten(nn.Module):
    def forward(self, input):
        return input.view(input.size(0), -1)


class L2Norm(nn.Module):
    def __init__(self, dim=1):
        super().__init__()
        self.dim = dim

    def forward(self, input):
        return F.normalize(input, p=2, dim=self.dim)
