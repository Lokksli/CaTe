import cdsapi

dataset = "reanalysis-era5-single-levels"
request = {
    "product_type": ["reanalysis"],
    "variable": [
        "2m_temperature",
        "total_precipitation"
    ],
    "year": [
        "2025"
        ],
    "month": [
        "01", "02", "03",
        "04", "05", "06",
        "07", "08", "09",
        "10", "11", "12"
    ],
    "day": [
        "01", "02", "03",
        "04", "05", "06",
        "07", "08", "09",
        "10", "11", "12",
        "13", "14", "15",
        "16", "17", "18",
        "19", "20", "21",
        "22", "23", "24",
        "25", "26", "27",
        "28", "29", "30",
        "31"
    ],
    "time": [
        "02:00", "08:00", "14:00",
        "20:00", "23:00"
    ],
    "data_format": "grib",
    "download_format": "unarchived",
    "area": [49.25, 22.00, 47.75, 24.75]
}

target = 'download.grib'


client = cdsapi.Client()
client.retrieve(dataset, request, target) 
