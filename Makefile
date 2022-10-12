.PHONY: clean data lint requirements sync_data_to_gcs sync_data_from_gcs

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
BUCKET = [OPTIONAL] your-bucket-for-syncing-data (do not include 's3://') # gcs
PROFILE = default
PROJECT_NAME = poc-cookiecutter-docker
PYTHON_INTERPRETER = python3
PYTHON_VERSION=3.9.10

ifeq (,$(shell which pyenv))
HAS_PYENV=False
else
HAS_PYENV=True
endif

# check for python version
ifeq (,$(shell pyenv versions | grep ${PYTHON_VERSION}))
HAS_PYTHON_VERSION=False
else
HAS_PYTHON_VERSION=True
endif

#################################################################################
# COMMANDS                                                                      #
#################################################################################
check_pyenv:
	@echo "Has pyenv: ${HAS_PYENV}"
check_pyver: check_pyenv
	@echo "Has python=${PYTHON_VERSION}: ${HAS_PYTHON_VERSION}"

## Install Python Dependencies
requirements: test_environment
	$(PYTHON_INTERPRETER) -m pip install -U pip setuptools wheel
	$(PYTHON_INTERPRETER) -m pip install -r requirements.txt

## Make Dataset
data: requirements
	$(PYTHON_INTERPRETER) src/data/make_dataset.py data/raw data/processed

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Lint using flake8
lint:
	flake8 src

## Upload Data to S3
sync_data_to_gcs:
ifeq (default,$(PROFILE))
	aws s3 sync data/ gs://$(BUCKET)/data/
else
	aws s3 sync data/ gs://$(BUCKET)/data/ --profile $(PROFILE)
endif

## Download Data from S3
sync_data_from_gcs:
ifeq (default,$(PROFILE))
	aws s3 sync gs://$(BUCKET)/data/ data/
else
	aws s3 sync gs://$(BUCKET)/data/ data/ --profile $(PROFILE)
endif

setup_pyenv:
	@echo 'export PYENV_ROOT="$$HOME/.pyenv"' >> ~/.xyc
	@echo 'command -v pyenv >/dev/null || export PATH="$$PYENV_ROOT/bin:$$PATH"' >> ~/.xyc
	@echo eval "$('shell pyenv init -')" >> ~/.xyc

## Set up python interpreter environment with poetry and pyenv
create_environment:
ifeq (True,$(HAS_PYENV) & $(!HAS_PYTHON_VERSION)) #install python version if required
	@echo ">>> Detected pyenv, installing python version."
	@bash $(shell which pyenv) install 3.9.10
	@bash $(shell which pyenv) local 3.9.10
else
	@echo "has pyenv and python version"
endif
ifeq (True,$(HAS_PYTHON_VERSION)) # activate the python version
	@bash $(shell which pyenv) local 3.9.10
else # install both pyenv and pyenv version
	@echo ">>> Not detected pyenv, installing pyenv and installing python version."
	@bash brew install pyenv
	@bash $(shell which pyenv) install 3.9.10
	@bash $(shell which pyenv) local 3.9.10
endif

ifeq (,$(shell which poetry)) # activate the python version
	@echo ">>> Installing poetry if not already installed.\nMake you have python 3.9.10 installed with pyenv\n"
	@bash $(PYTHON_INTERPRETER) -m pip install -q poetry
else
	@echo "Aleady have poetry"
endif
	@bash $(shell which poetry) init
	@bash $(shell which poetry) config --local virtualenvs.in-project true
	# @bash -c "source `which virtualenvwrapper.sh`;mkvirtualenv $(PROJECT_NAME) --python=$(PYTHON_INTERPRETER)"
	@echo ">>> New virtualenv created. Activate with:\poetry shell"

## Activate your environment.
init_environment:# create_environment
	@bash $(shell which poetry) shell
	@bash $(shell which poetry) config --local virtualenvs.in-project true
	@bash $(shell which poetry) install


# Init the repo
init_repo: #init_environment
	@git init
	@pre-commit install


## Test python environment is setup correctly
test_environment:
	$(PYTHON_INTERPRETER) test_environment.py

lint:
	pylint
	black

build:
	docker build . -f ./docker/Dockerfile  -t  "my_model:$(date +'%m-%d-%y')"

# todo store the date
test: build
	docker run -it my_model:10-12-22  pytest

#################################################################################
# PROJECT RULES                                                                 #
#################################################################################



#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
