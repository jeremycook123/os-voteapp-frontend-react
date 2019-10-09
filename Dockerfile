# => Build container
FROM node:alpine as builder
WORKDIR .
COPY package.json .
COPY yarn.lock .
RUN yarn install
COPY . .
RUN yarn build

# => Run container
FROM nginx:1.15.2-alpine

# Nginx config
RUN rm -rf /etc/nginx/conf.d
COPY conf /etc/nginx

# Static build
COPY --from=builder /build /usr/share/nginx/html/

# Default port exposure
EXPOSE 8080

# Copy .env file and shell script to container
WORKDIR /usr/share/nginx/html
COPY ./env.sh .
COPY .env .

# Add bash
RUN apk add --no-cache bash

# Make our shell script executable
RUN chmod +x env.sh
RUN chown -R nginx:nginx .
RUN mkdir -p /var/run/
RUN chown -R nginx:nginx /var/run/
RUN chown -R nginx:nginx /usr/share/nginx/html/

RUN chmod -R 777 /usr/share/nginx/html

RUN mkdir -p /var/cache/nginx/
RUN chown -R nginx:nginx /var/cache/nginx/
RUN chmod -R 777 /var/cache/nginx/

RUN mkdir -p /var/run/
RUN chown -R nginx:nginx /var/run/
RUN chmod -R 777 /var/run/

USER 100

# Start Nginx server
CMD ["/bin/bash", "-c", "/usr/share/nginx/html/env.sh && nginx -g \"daemon off;\""]
