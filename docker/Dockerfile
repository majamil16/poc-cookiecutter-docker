FROM python:3.10 as build

WORKDIR /src
COPY ../requirements.txt /src/
RUN pip install -r requirements.txt

# copy the src
# RUN mkdir src tests
# COPY ../ .
COPY ../src .
COPY ../tests .


FROM build as test
ENV PYTHONPATH=/src
WORKDIR /src
COPY ../requirements-dev.txt .
RUN pip install -r requirements-dev.txt
RUN pytest
