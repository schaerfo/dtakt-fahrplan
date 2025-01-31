import pandas as pd
import sqlite3
import sys


def main():
    location_df = pd.read_csv(
        sys.argv[2],
        sep=';',
        decimal=',',
        dtype={"EVA_NR": str, "Betreiber_Nr": str},
    )
    # Create id column from RangeIndex
    location_df.reset_index(inplace=True)
    location_df.rename(columns={"NAME": "name_db", "index": "id"}, inplace=True)

    ds100_df = location_df[['id', 'DS100']]
    ds100_df.loc[:, 'DS100'] = ds100_df['DS100'].str.split(',')
    ds100_df = ds100_df.explode('DS100')

    with sqlite3.connect(sys.argv[1]) as conn:
        location_df.to_sql("station_location", conn, index=False)
        ds100_df.to_sql("ds100", conn, index=False)


if __name__ == '__main__':
    main()
