import sys
import sqlite3

import pandas as pd

OVERPASS_QUERY = \
    '''
[out:json][timeout:1800];
(
  area["ISO3166-1"="DE"][admin_level=2];
  area["ISO3166-1"="DK"][admin_level=2];
  area["ISO3166-1"="NL"][admin_level=2];
  area["ISO3166-1"="BE"][admin_level=2];
  area["ISO3166-1"="LU"][admin_level=2];
  area["ISO3166-1"="FR"][admin_level=2];
  area["ISO3166-1"="CH"][admin_level=2];
  area["ISO3166-1"="AT"][admin_level=2];
  area["ISO3166-1"="IT"][admin_level=2];
  area["ISO3166-1"="CZ"][admin_level=2];
  area["ISO3166-1"="PL"][admin_level=2];
)->.searchArea;
node["railway"~"station|halt"][~"^name.*$"~"{}"](area.searchArea)->.stations;
{}
'''

STATION_QUERY = \
    '''
node.stations[~"^name.*$"~"^{}$"];
convert node
    ::id=id(),
    ::=::,
    lat=lat(),
    lon=lon(),
    ds100="{}";
out;
'''


def main():
    with sqlite3.connect(sys.argv[1]) as conn:
        df = pd.read_sql('''SELECT "name", substr(replace(dtakt_id, '_x0020_', ' '), 2) as ds100 FROM "passenger_station" WHERE "Laenge" IS NULL''', conn)
    station_nodes = '\n'.join(df.apply(lambda row: STATION_QUERY.format(row['name'], row['ds100']), axis=1))
    print(OVERPASS_QUERY.format('|'.join(df['name']), station_nodes))


if __name__ == '__main__':
    main()
