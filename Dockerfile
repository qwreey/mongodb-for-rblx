FROM node:alpine

ADD package.json /app/package.json
WORKDIR /app
RUN \
	npm i
ADD src /app/src

CMD [ "npm", "run", "start" ]

