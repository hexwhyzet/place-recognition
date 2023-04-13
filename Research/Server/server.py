import json
from copy import deepcopy
from typing import List

import numpy as np
from fastapi import FastAPI
from pydantic import BaseModel
from starlette.responses import FileResponse

from image import PathImage
from releaser import get_obj, release_obj_path

app = FastAPI()

release = get_obj(release_obj_path('v1'))

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


def most_common(lst):
    return max(set(lst), key=lst.count)


def find_closest(target: np.array) -> int:
    # min_dist = float('+inf')
    # closest_image = None
    images = deepcopy(release.images)
    images.sort(key=lambda img: np.linalg.norm(target - img.meta.descriptor))
    closest_images = images[:10]
    answers = []
    for closest_image in closest_images:
        occurrences = np.bincount(closest_image.meta.annotations.content.flatten())
        occurrences[0] = 0
        closest_building_id = occurrences.argmax()
        answers.append(closest_building_id)
    print(answers)
    return answers[0]


@app.post("/recognize", response_model=ResponseData)
async def recognize(array_data: ArrayData):
    # Process the array and create response
    with open("./data.log", "a") as log_file:
        log_file.write(str(array_data) + "\n")

    closest_building_id = find_closest(np.array(array_data.data, dtype=np.float32))
    print(list(np.array(array_data.data, dtype=np.float32)), file=open("desc2.text", "w+"))
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
