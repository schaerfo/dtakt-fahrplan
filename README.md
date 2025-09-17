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

For building the timetable, the following software is required:

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
Everything in this repository is licensed under as specified in the `LICENSE` file.

**Note:** Other licenses may apply to artifacts that are downloaded or created in the build process.

## References
[1] https://fragdenstaat.de/anfrage/maschinenlesbarer-deutschland-takt/

[2] https://github.com/motis-project/motis
