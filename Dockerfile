FROM node:16-buster-slim as webpack

WORKDIR /recipes

COPY package.json package-lock.json ./
RUN npm ci

COPY tsconfig.json webpack*.js ./
COPY web/static/ ./web/static/

RUN npm run buildprod

FROM python:3.9-slim-buster as final

ENV PIP_NO_CACHE_DIR=false \
    POETRY_VIRTUALENVS_CREATE=false

WORKDIR /recipes

ENTRYPOINT ["gunicorn"]
CMD ["web:create_app()", "-b", "0.0.0.0:8000"]

RUN pip install -U poetry

COPY poetry.lock pyproject.toml ./

RUN poetry install --no-dev

COPY --from=webpack /recipes/web/static/dist/* ./web/static/dist/
COPY . .
