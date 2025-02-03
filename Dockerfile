FROM ubuntu:noble AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
dos2unix \
make \
patch \
python3 \
python3-poetry \
sqlite3 \
unzip \
wget

WORKDIR /build

COPY python.mk pyproject.toml poetry.lock ./
RUN make -f python.mk

COPY input.mk ./
RUN mkdir input && make -f input.mk

COPY \
db_ingest.py \
export_gtfs.py \
gtfs_views.sql \
Makefile \
passenger_train_view.sql \
station_location.py \
./
RUN mkdir intermediate out && make

FROM ghcr.io/motis-project/motis:2 AS import
COPY motis/ .
COPY --from=builder /build/out/dtakt-gtfs.zip .
RUN ./motis import

FROM ghcr.io/motis-project/motis:2
COPY --from=import data data
