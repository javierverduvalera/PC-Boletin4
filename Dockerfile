# syntax=docker/dockerfile:1
ARG NODE_VERSION=22.20.0

# ---- Base ----
FROM node:${NODE_VERSION}-alpine AS base
WORKDIR /usr/src/app
EXPOSE 3000

# ---- Desarrollo ----
FROM base AS dev
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --include=dev
COPY . .
RUN chown -R node:node /usr/src/app
USER node
CMD ["npm", "run", "dev"]

# ---- Tests ----
FROM base AS test
ENV NODE_ENV=test
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --include=dev
COPY . .
RUN chown -R node:node /usr/src/app
USER node
# Ejecuta los tests
RUN npm test

# ---- Producción ----
FROM base AS prod
ENV NODE_ENV=production
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev
COPY . .
RUN chown -R node:node /usr/src/app
USER node
CMD ["node", "src/index.js"]
