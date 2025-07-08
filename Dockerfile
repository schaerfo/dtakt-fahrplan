FROM ubuntu:noble AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
curl \
dos2unix \
jq \
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
generate_overpass_query.py \
gtfs_views.sql \
Makefile \
merge_station_location.py \
passenger_train_view.sql \
station_location.py \
./
RUN mkdir intermediate out && make

FROM ghcr.io/cirruslabs/flutter:stable AS ui
WORKDIR /frontend
COPY frontend/pubspec.lock frontend/pubspec.yaml ./
RUN dart pub get
COPY frontend ./
# wasm compilation does not work when a string containing a comma is supplied to --dart-define 😢
RUN flutter build web --dart-define-from-file=.env --no-web-resources-cdn

FROM ghcr.io/motis-project/motis:2 AS import
COPY motis/ .
COPY --from=builder /build/out/dtakt-gtfs.zip .
RUN ./motis import

FROM ghcr.io/motis-project/motis:2
COPY --from=import data data
COPY --from=ui /frontend/build/web ui_flutter
