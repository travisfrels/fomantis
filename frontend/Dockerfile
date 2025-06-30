FROM node:lts-alpine
WORKDIR /app
COPY package.json .
COPY app app
RUN npm install
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
