FROM node:lts-alpine
WORKDIR /app
COPY package.json .
COPY index.js .
RUN npm install
EXPOSE 3001
CMD ["npm", "start"]
