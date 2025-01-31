python: .python

.python: pyproject.toml poetry.lock
	poetry install --sync
	touch .python
