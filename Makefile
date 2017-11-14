# Set the environment variable PYTHON to your custom Python exe
PYTHON ?= python

.PHONY: clean-pyc clean-build docs clean

BROWSER := $(PYTHON) -c "import os, sys; os.startfile(os.path.abspath(sys.argv[1]))"

help:
	@echo "clean - remove all build, test, coverage and Python artifacts"
	@echo "clean-build - remove build artifacts"
	@echo "clean-pyc - remove Python file artifacts"
	@echo "clean-test - remove test and coverage artifacts"
	@echo "lint - check style with flake8"
	@echo "test - run tests quickly with the default Python"
	@echo "test-all - run tests on every Python version with tox"
	@echo "coverage - check code coverage quickly with the default Python"
	@echo "docs - generate Sphinx HTML documentation, including API docs"
	@echo "pdf - convert documentation in PDF"
	@echo "release - package and upload a release"
	@echo "dist - package"
	@echo "install - install the package to the active Python's site-packages"
	@echo "stats - show code stats"

clean: clean-build clean-pyc clean-test

clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	rm -rf tests/uploads/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test:
	rm -fr .tox/
	rm -f .coverage
	rm -fr tests/htmlcov/
	rm -fr tests/.cache-url

lint:
	flake8 gramex testlib tests

test:
	$(PYTHON) setup.py nosetests

test-all:
	tox

coverage:
	$(PYTHON) -m nose --with-coverage --cover-package=gramex --cover-erase --cover-html --cover-html-dir=htmlcov --cover-branches
	$(BROWSER) tests/htmlcov/index.html

docs:
	rm -f docs/gramex* docs/modules.rst
	sphinx-apidoc -o docs/ gramex --no-toc
	$(MAKE) -C docs clean
	$(MAKE) -C docs html

PDFLATEX := $(shell pdflatex -version 2>/dev/null)
pdf: docs
ifdef PDFLATEX
	$(MAKE) -C docs latexpdf
else
	@echo "No pdflatex found. Install pdflatex to build PDF docs"
endif

showdocs:
	$(BROWSER) docs/_build/html/index.html

release-test: clean-test lint docs coverage

release: clean
	$(PYTHON) setup.py sdist
	$(PYTHON) setup.py bdist_wheel

dist: clean release
	ls -l dist

install: clean
	$(PYTHON) setup.py install

stats:
	@echo gramex
	@find gramex -path '*node_modules/*' -prune -o -name '*.py' | grep '\.py$$' | xargs wc -l | tail -1
	@echo gramex config
	@wc -l docs/conf.py setup.py | tail -1
	@echo tests
	@find tests testlib -path '*node_modules/*' -prune -o -name '*.py' | grep '\.py$$' | xargs wc -l | tail -1
