import pygrib
import numpy as np
import csv

target_lat = 48.62
target_lon = 22.30

grbs = pygrib.open("carpathian_data.grib")

temp_file = open("uzhorod_temperature.csv", "w", newline="")
prec_file = open("uzhorod_prec.csv", "w", newline="")

temp_writer = csv.writer(temp_file)
prec_writer = csv.writer(prec_file)

temp_writer.writerow(["date", "latitude", "longitude", "temperature_c"])
prec_writer.writerow(["date", "latitude", "longitude", "precipitation"])

lats = None
lons = None

for grb in grbs:
    if grb.name not in ["2 metre temperature", "Total precipitation"]:
        continue

    if lats is None:
        lats, lons = grb.latlons()

        distance = (lats - target_lat)**2 + (lons - target_lon)**2

        i, j = np.unravel_index(
            np.argmin(distance),
            distance.shape
        )

        point_lat = lats[i, j]
        point_lon = lons[i, j]

        del distance, lats, lons
        lats = True

    data = grb.values
    value = data[i, j]

    if grb.name == "2 metre temperature":
        temp_writer.writerow([
            grb.validDate,
            point_lat,
            point_lon,
            value - 273.15
        ])

    elif grb.name == "Total precipitation":
        prec_writer.writerow([
            grb.validDate,
            point_lat,
            point_lon,
            value * 1000
        ])

    del data

temp_file.close()
prec_file.close()
grbs.close()

print("Finished!")
