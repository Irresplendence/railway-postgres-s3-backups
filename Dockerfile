ARG NODE_VERSION='22.14.0'

FROM node:${NODE_VERSION}-bookworm AS build

ENV NPM_CONFIG_UPDATE_NOTIFIER=false
ENV NPM_CONFIG_FUND=false

WORKDIR /app

COPY package*.json tsconfig.json ./
COPY src ./src

RUN npm ci && \
    npm run build && \
    npm prune --production

FROM node:${NODE_VERSION}-bookworm

WORKDIR /app

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/package.json ./

ARG PG_VERSION='17'

RUN apt-get update && apt-get install -y postgresql-client-${PG_VERSION}

CMD pg_isready --dbname=$BACKUP_DATABASE_URL && \
    pg_dump --version && \
    node dist/index.js
