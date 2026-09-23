FROM node:20-slim

WORKDIR /app

COPY package*.json ./

RUN npm install

ADD . ./

CMD ["npm", "start"]

