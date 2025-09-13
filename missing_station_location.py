# Copyright 2025 Christian Schärf
# SPDX-License-Identifier: MIT

import sqlite3
import sys
import random

# Central Europe coordinate boundaries
MIN_LAT = 47.0  # Southern boundary
MAX_LAT = 55.0  # Northern boundary
MIN_LON = 0.0  # Western boundary
MAX_LON = 20.0  # Eastern boundary


def generate_random_location():
    lat = random.uniform(MIN_LAT, MAX_LAT)
    lon = random.uniform(MIN_LON, MAX_LON)
    return lon, lat


def main():
    conn = sqlite3.connect(sys.argv[1])
    cursor = conn.cursor()

    # Get all station IDs with an unknown location
    cursor.execute("SELECT substr(replace(station_id, '_x0020_', ' '), 2) FROM passenger_station WHERE Laenge IS NULL")
    stations = cursor.fetchall()

    # Generate and insert random locations
    locations = [(station[0], *generate_random_location()) for station in stations]
    cursor.executemany("INSERT INTO station_location (RL100, Laenge, Breite) VALUES (?, ?, ?)",
                       locations)
    conn.commit()
    conn.close()


if __name__ == '__main__':
    main()
