# Copyright 2025 Christian Schärf
# SPDX-License-Identifier: MIT

import pandas as pd
import sqlite3
import sys

STATION_LOCATION_SQL = \
'''
CREATE TABLE "station_location" (
  "DS100" TEXT NOT NULL,
  "EVA_NR" TEXT,
  "IFOPT" TEXT,
  "name_db" TEXT,
  "Verkehr" TEXT,
  "Laenge" REAL,
  "Breite" REAL,
  "Betreiber_Name" TEXT,
  "Betreiber_Nr" TEXT,
  "Status" TEXT,
  PRIMARY KEY ("DS100")
)
'''


def main():
    location_df = pd.read_csv(
        sys.argv[2],
        sep=';',
        decimal=',',
        dtype={"EVA_NR": str, "Betreiber_Nr": str},
    )
    location_df.loc[:, 'DS100'] = location_df['DS100'].str.split(',')
    location_df = location_df.explode('DS100')

    location_df.rename(columns={"NAME": "name_db"}, inplace=True)

    with sqlite3.connect(sys.argv[1]) as conn:
        conn.execute(STATION_LOCATION_SQL)
        location_df.to_sql("station_location", conn, index=False, if_exists='append')


if __name__ == '__main__':
    main()
