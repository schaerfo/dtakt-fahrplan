# Copyright 2025 Christian Schärf
# SPDX-License-Identifier: MIT

python: .python

.python: pyproject.toml poetry.lock
	poetry install --sync
	touch .python
