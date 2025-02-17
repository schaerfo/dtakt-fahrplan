# Copyright 2025 Christian Schärf
# SPDX-License-Identifier: MIT

import pandas as pd
import sqlite3
import sys
from zipfile import ZipFile, ZIP_DEFLATED

GTFS_FILES = [
    "agency.txt",
    "calendar.txt",
    "routes.txt",
    "stop_times.txt",
    "stops.txt",
    "trips.txt",
]


def main():
    with sqlite3.connect(sys.argv[1]) as conn:
        with ZipFile(sys.argv[2], mode='w', compression=ZIP_DEFLATED) as output_file:
            for view in GTFS_FILES:
                view_name = "gtfs_" + view.split('.')[0]
                df = pd.read_sql(f"SELECT * FROM {view_name}", conn)
                with output_file.open(view, mode='w') as fp:
                    df.to_csv(fp, index=False)


if __name__ == '__main__':
    main()
