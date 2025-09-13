# Copyright 2025 Christian Schärf
# SPDX-License-Identifier: MIT
import itertools
import json
import sqlite3
import sys

import pandas as pd

STATION_LOCATION_SQL = \
'''
CREATE TABLE "station_location" (
  "RL100" TEXT NOT NULL,
  "name_db" TEXT,
  "Laenge" REAL,
  "Breite" REAL,
  PRIMARY KEY ("RL100")
)
'''


def main():
    with open(sys.argv[2]) as f:
        stop_places = json.load(f)

    locations = []
    for station in filter(lambda item: 'rl100' in item['keys'], stop_places):
        keys = station['keys']
        for ril100 in itertools.chain([keys['rl100']], keys.get('alternativeRl100', [])):
            locations.append(dict(
                RL100=ril100,
                name_db=station['names']['de']['nameLong'],
                Breite=station['location']['lat'],
                Laenge=station['location']['lon'],
            ))
    location_df = pd.DataFrame(locations)
    location_df.drop_duplicates(subset=['RL100'], inplace=True)

    with sqlite3.connect(sys.argv[1]) as conn:
        conn.execute(STATION_LOCATION_SQL)
        location_df.to_sql("station_location", conn, index=False, if_exists='append')


if __name__ == '__main__':
    main()
