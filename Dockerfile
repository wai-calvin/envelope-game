FROM node:16-alpine AS build

WORKDIR /envelope-game

COPY package*.json yarn.lock /envelope-game/

RUN yarn install

COPY *.js /envelope-game/
COPY lib /envelope-game/lib
COPY react /envelope-game/react
COPY routes /envelope-game/routes
COPY __tests__ /envelope-game/__tests__
COPY __mocks__ /envelope-game/__mocks__

RUN yarn test

RUN yarn run build

FROM node:16-alpine AS run

WORKDIR /envelope-game

LABEL org.opencontainers.image.source=https://github.com/liatrio/envelope-game

COPY --from=build /envelope-game/dist .
COPY --from=build /envelope-game/package.json .
COPY --from=build /envelope-game/yarn.lock .
COPY --from=build /envelope-game/server.js .
COPY --from=build /envelope-game/db.js .
COPY --from=build /envelope-game/lib .
COPY --from=build /envelope-game/routes .

ENV NODE_ENV=production
RUN yarn install --production

ENTRYPOINT [ "node", "server.js" ]
