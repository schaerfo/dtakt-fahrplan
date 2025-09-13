# Deutschlandtakt Journey Planner

## What is this about?
The Deutschlandtakt is a concept for an integrated clock-facing timetable for railways in Germany,
providing consistent travel options with matched connections at railway hubs throughout the day.
This is similar to what is already implemented in Switzerland.

This project aims to provide a convenient way to search for railway journeys between arbitrary stations,
potentially encompassing one or more transfers, to anyone interested.
The purpose is to demonstrate the usefulness of the Deutschlandtakt to the general public.

## Acknowledgements
This project is based on the publicly available timetable data for the Deutschlandtakt,
published by the Federal Ministry for Digital and Transport under the German Freedom of Information Act (Informationsfreiheitsgesetz) [1].

Routing is provided by Motis [2], which takes timetable data in commonly used formats such as GTFS.
Therefore, this repository consists mostly of scripts to transform the raw timetable data into GTFS
and enrich it with additional information.

## Status
This is still work-in-progress, see the issues tab for details.

## Developer Information
### Requirements
**Note:** Building the initial database requires approximately 10 GB of RAM.

For building the timetable the following software is required:

* CUrl
* dos2unix
* jq
* GNU Make
* patch
* Python >= 3.12
* Poetry
* SQLite
* unzip
* wget

On Ubuntu 24.04 and later, these can be installed with:

```shell
sudo apt-get install -y --no-install-recommends dos2unix jq make patch python3 python3-poetry sqlite3 unzip wget
```

Additional Python packages will be installed by Poetry in the build process.

### Building
Building the timetable data is done by running:

```shell
make
```

The resulting file will be placed in the `output` directory.

### Running
Acquire a version of Motis from [2] and follow instructions from there.
The Dockerfile of this repository may serve as inspiration.

## API Access
The backend is a simple Motis instance. Therefore, the [API documentation of Motis](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/motis-project/motis/refs/heads/master/openapi.yaml) applies.
Please note that some features may not be available yet, as we are not necessarily using the latest version of Motis.
You can find the currently used version by looking at the `server` HTTP header.

If you use this service, please set relevant HTTP headers (e.g. `User-Agent` or `Origin`) appropriately
and provide a link to this project.

## License
Since the file `motis/empty.osm.pbf` is an excerpt from OpenStreetMap, a different license applies to this file than
the rest of the project.

**Note:** Other licences may apply to artifacs that are downloaded or created in the build process.

### motis/empty.osm.pbf
[© OpenStreetMap contributors](https://www.openstreetmap.org/copyright)

### Everything Else
MIT License

Copyright 2025 Christian Schärf

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the " Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

## References
[1] https://fragdenstaat.de/anfrage/maschinenlesbarer-deutschland-takt/

[2] https://github.com/motis-project/motis
