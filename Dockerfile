FROM node:alpine

ADD src /app/src
ADD package.json /app/src/package.json

WORKDIR /app
RUN \
	npm i && \

CMD [ "npm", "run", "start" ]

