import pandas as pd
import sqlite3
import sys

PASSENGER_STATION = '''
select distinct station.* from station
join stop on stop.station_id = station.id
join passenger_train_with_part on stop.train_part_id = passenger_train_with_part.train_part_id
'''


def main():
    location_df = pd.read_csv(sys.argv[2], sep=';', decimal=',', index_col='DS100', dtype={"EVA_NR": str, "Betreiber_Nr": str})
    location_df.rename(columns={"NAME": "name_db"}, inplace=True)
    with sqlite3.connect(sys.argv[1]) as conn:
        df = pd.read_sql(PASSENGER_STATION, conn)
        df['DS100'] = df.apply(lambda row: row.dtakt_id.replace('_x0020_', ' ')[1:], axis=1)
        merged = df.join(location_df, rsuffix="_db", on='DS100')
        merged = merged[['id', 'name_db', 'Laenge', 'Breite']]
        merged.to_sql("station_location", conn, index=False) # Why is the index of merged a RangeIndex and not the id column from df?


if __name__ == '__main__':
    main()
