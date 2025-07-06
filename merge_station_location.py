# Copyright 2025 Christian Schärf
# SPDX-License-Identifier: MIT

import sqlite3
import sys

import pandas as pd


def main():
    osm_locations_df = pd.read_csv(sys.argv[2])
    osm_locations_df.rename(columns={'name': 'name_db'}, inplace=True)
    osm_locations_df = osm_locations_df[["DS100", "name_db", "Laenge", "Breite"]].dropna(subset=['Laenge'])
    # Discard locations that are outside Europe
    osm_locations_df = osm_locations_df[
        (34.0 <= osm_locations_df['Breite']) &
        (osm_locations_df['Breite'] <= 72.0) &
        (-25.0 <= osm_locations_df['Laenge']) &
        (osm_locations_df['Laenge'] <= 45.0)
    ]
    osm_locations_df.set_index("DS100", inplace=True)
    
    with sqlite3.connect(sys.argv[1]) as conn:
        osm_locations_df.to_sql("station_location", conn, index=True, if_exists='append')


if __name__ == '__main__':
    main()
