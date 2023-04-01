import io
from typing import List

import numpy as np
from fastapi import FastAPI
from pydantic import BaseModel
from starlette.responses import StreamingResponse, FileResponse

from image import PathImage
from releaser import get_obj, release_obj_path

app = FastAPI()

release = get_obj(release_obj_path('test'))

IP = "130.193.55.149"
PORT = 8000


class ArrayData(BaseModel):
    data: List[float]


class ResponseData(BaseModel):
    name: str
    description: str
    url: str


def find_closest(target: np.array, ) -> PathImage:
    min_dist = float('+inf')
    closest_image = None
    for image in release.images:
        dist = np.linalg.norm(target - image.meta.descriptor)
        if min_dist > dist:
            closest_image = image
            min_dist = dist
    return closest_image


@app.post("/nearest", response_model=ResponseData)
async def nearest(array_data: ArrayData):
    # Process the array and create response
    with open("./data.log", "a") as log_file:
        log_file.write(str(array_data) + "\n")

    closest_image = find_closest(np.array(array_data.data, dtype=np.float32))
    name = "Nearest picture"
    description = "This is the nearest picture we store in our database"
    url = f"http://{IP}:{PORT}/release/{release.name}/{closest_image.path.split('/')[-1]}"
    response_data = ResponseData(name=name, description=description, url=url)
    return response_data


@app.get("/release/{release_name}/{image_name}", response_model=ResponseData)
async def release_image(release_name: str, image_name: str):
    with open("./data.log", "a") as log_file:
        log_file.write(str(release_name) + " " + str(image_name) + "\n")
    return FileResponse(f"./releases/{release.name}/{image_name}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=PORT)
