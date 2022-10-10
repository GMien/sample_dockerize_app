FROM node:14.16.0-alpine3.13 AS development
ENV NODE_ENV development
WORKDIR /app
COPY package.json .
COPY package-lock.json .
RUN npm install --force
COPY . .
EXPOSE 3000
CMD ["npm", "start"]

FROM node:14.16.0-alpine3.13 AS builder
ENV NODE_ENV production
WORKDIR /app
COPY package.json .
COPY package-lock.json .
RUN npm config delete https-proxy
RUN npm cache clean --force
RUN npm install --no-package-lock --force
RUN npm audit fix --force
COPY . .
RUN npm run build

FROM nginx:1.21.0-alpine AS production
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]