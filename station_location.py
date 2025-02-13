import pandas as pd
import sqlite3
import sys

STATION_LOCATION_SQL = \
'''
CREATE TABLE "station_location" (
  "location_id" INTEGER,
  "EVA_NR" TEXT,
  "DS100" TEXT,
  "IFOPT" TEXT,
  "name_db" TEXT,
  "Verkehr" TEXT,
  "Laenge" REAL,
  "Breite" REAL,
  "Betreiber_Name" TEXT,
  "Betreiber_Nr" TEXT,
  "Status" TEXT,
  PRIMARY KEY ("location_id"),
  FOREIGN KEY ("location_id") REFERENCES "ds100"("location_id")
)
'''

DS100_SQL = \
'''
CREATE TABLE "ds100" (
  "location_id" INTEGER,
  "DS100" TEXT,
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
    # Create id column from RangeIndex
    location_df.reset_index(inplace=True)
    location_df.rename(columns={"NAME": "name_db", "index": "location_id"}, inplace=True)

    ds100_df = location_df[['location_id', 'DS100']]
    ds100_df.loc[:, 'DS100'] = ds100_df['DS100'].str.split(',')
    ds100_df = ds100_df.explode('DS100')

    with sqlite3.connect(sys.argv[1]) as conn:
        conn.execute(DS100_SQL)
        conn.execute(STATION_LOCATION_SQL)
        location_df.to_sql("station_location", conn, index=False, if_exists='append')
        ds100_df.to_sql("ds100", conn, index=False, if_exists='append')


if __name__ == '__main__':
    main()
