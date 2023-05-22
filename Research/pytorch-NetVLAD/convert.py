import coremltools as ct
import numpy as np
import torch

from netvald_interface import NetVladModel, Options

opt = Options(
    dataPath='/Users/kabakov/PycharmProjects/place-recognition/Research/pytorch-NetVlad/Pittsburgh250k/data',
)
nv = NetVladModel(opt=opt)
image = torch.tensor(np.random.rand(1, 512, 512, 3).astype(np.float32))
encoder_example_input = torch.rand(1, 512, 512, 3)

encoder_traced_model = torch.jit.trace(nv.model.pool, encoder_example_input)
netvlad_pool = ct.convert(
    encoder_traced_model,
    # convert_to="mlprogram",
    inputs=[ct.TensorType(shape=encoder_example_input.shape, dtype=np.float32)]
)
netvlad_pool.save("encoder.mlmodel")

pool_example_input = torch.rand(1, 512, 32, 32)
pool_traced_model = torch.jit.trace(nv.model.pool, pool_example_input)

netvlad_pool = ct.convert(
    pool_traced_model,
    # convert_to="mlprogram",
    inputs=[ct.TensorType(shape=pool_example_input.shape, dtype=np.float32)]
)
netvlad_pool.save("pool.mlmodel")
