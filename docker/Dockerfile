FROM python:3.10 as build

WORKDIR /src
COPY ../requirements.txt /src/
RUN pip install -r requirements.txt

# copy the src
RUN mkdir src tests
COPY ../src ./src
COPY ../tests ./tests

RUN python tests/test_model.py
