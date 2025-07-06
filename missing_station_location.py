# Copyright 2025 Christian Schärf
# SPDX-License-Identifier: MIT

import sys
import sqlite3

import pandas as pd
import requests


def get_station_location(station):
    url = "https://nominatim.openstreetmap.org/search"
    params = {
        "q": f"{station['name']}",
        "format": "json",
        "limit": 1
    }
    headers = {"User-Agent": "StationLocationFinder/1.0"}

    response = requests.get(url, params=params, headers=headers)
    response.raise_for_status()
    data = response.json()

    if len(data):
        result = pd.Series({
            "Laenge": float(data[0]["lon"]),
            "Breite": float(data[0]["lat"]),
            "osm_id": data[0]["osm_id"],
            "osm_name": data[0]["name"],
        })
    else:
        result = pd.Series({"Laenge": None, "Breite": None, "osm_id": None, "osm_name": None})
    print(station['name'], station['DS100'], result['osm_id'], result['osm_name'], result['Laenge'], result['Breite'])
    return result


def main():
    output_file = sys.argv[2]
    with sqlite3.connect(sys.argv[1]) as conn:
        df = pd.read_sql('''SELECT "name", substr(replace(station_id, '_x0020_', ' '), 2) as DS100 
                           FROM "passenger_station" WHERE "Laenge" IS NULL''', conn)

    locations = df.apply(get_station_location, axis=1)
    df = pd.concat([df, locations], axis=1)
    df.to_csv(output_file, index=False)


if __name__ == '__main__':
    main()
