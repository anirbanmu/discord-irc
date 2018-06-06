# Builder
FROM node:alpine AS builder

RUN mkdir -p /code
WORKDIR /code/

COPY .babelrc .eslintrc .npmignore package.json package-lock.json ./
COPY lib ./lib

RUN npm install && \
    npm run build

# Final image
FROM node:alpine
RUN apk --no-cache add shadow && \
    useradd --system discord-irc

RUN mkdir -p /code
RUN chown discord-irc:discord-irc /code
WORKDIR /code/

COPY --from=builder --chown=discord-irc:discord-irc /code/dist ./dist
COPY --from=builder --chown=discord-irc:discord-irc /code/node_modules ./node_modules
COPY --from=builder --chown=discord-irc:discord-irc /code/package.json /code/package-lock.json /code/.npmignore ./
COPY --chown=discord-irc:discord-irc config.json /discord-irc-config

USER discord-irc
CMD ["npm", "start", "--", "--config", "/discord-irc-config"]