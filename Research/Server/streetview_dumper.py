import streetview

panoids = streetview.panoids(lat=-33.85693857571269, lon=151.2144895142714)

streetview.api_download(panoid, heading, flat_dir, key)

print(panoids)