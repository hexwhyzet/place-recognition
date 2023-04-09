import json
from typing import List

import numpy as np
from fastapi import FastAPI
from pydantic import BaseModel
from starlette.responses import FileResponse

from image import PathImage
from releaser import get_obj, release_obj_path

app = FastAPI()

release = get_obj(release_obj_path('test2'))

IP = "0.0.0.0"
GLOBAL_IP = "51.250.107.202"
PORT = 8000


class ArrayData(BaseModel):
    data: List[float]


class ResponseData(BaseModel):
    id: int
    name: str
    description: str
    url: str
    address: str
    metro: str


id_to_building = {int(building["id"]): building for building in json.loads(open("./buildings.json", "r").read())}


def find_closest(target: np.array) -> int:
    min_dist = float('+inf')
    closest_image: PathImage
    for image in release.images:
        dist = np.linalg.norm(target - image.meta.descriptor)
        if min_dist > dist:
            closest_image = image
            min_dist = dist
    closest_building_id = np.bincount(closest_image.meta.annotations.content).argmax()
    return closest_building_id


@app.post("/nearest", response_model=ResponseData)
async def nearest(array_data: ArrayData):
    # Process the array and create response
    with open("./data.log", "a") as log_file:
        log_file.write(str(array_data) + "\n")

    closest_building_id = find_closest(np.array(array_data.data, dtype=np.float32))
    # url = f"http://{IP}:{PORT}/release/{release.name}/{closest_image.path.split('/')[-1]}"
    building = id_to_building[closest_building_id]
    response_data = ResponseData(
        id=building["id"],
        name=building["name"],
        description=building["description"],
        url=building["url"],
        address=building["address"],
        metro=building["metro"],
    )
    return response_data


@app.get("/release/{release_name}/{image_name}", response_model=ResponseData)
async def release_image(release_name: str, image_name: str):
    with open("./data.log", "a") as log_file:
        log_file.write(str(release_name) + " " + str(image_name) + "\n")
    return FileResponse(f"./releases/{release.name}/{image_name}")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host=IP, port=PORT)
