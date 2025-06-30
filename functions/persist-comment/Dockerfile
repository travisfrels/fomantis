FROM node:lts-alpine
WORKDIR /function
COPY index.js .
COPY package.json .
RUN npm install
ENV FUNC_HANDLER=index.handle
CMD ["npm", "start"]
