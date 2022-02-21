
FROM node:14.16-alpine AS build

ARG ARTIFACTORY_AUTH=abcde
ARG JDA_REGISTRY=abcde

WORKDIR /app
COPY . /app/ 


ENV PATH /app/node_modules/.bin:$PATH


ENV NO_UPDATE_NOTIFIER=true
COPY package*.json ./
COPY package-lock.json ./

RUN npm config set _auth=${ARTIFACTORY_AUTH}
RUN npm config set always-auth
RUN npm config set registry ${JDA_REGISTRY}
RUN npm config set @jda:registry ${JDA_REGISTRY}
RUN npm config set email no-reply@jda.com

RUN npm install
RUN npm run build

FROM nginx:alpine
# See https://hub.docker.com/_/nginx/

# Remove 'nginx:alpine' defaults
RUN rm -f /etc/nginx/conf.d/*.conf /etc/nginx/nginx.conf /docker-entrypoint.d/*

RUN addgroup --gid 1000 \
    "stratosphere" \
    && \
    adduser \
    --disabled-password \
    --gecos "" \
    --ingroup "stratosphere" \
    --no-create-home \
    --uid 1000 \
    "stratosphere"

USER 1000

COPY nginx/nginx.conf /etc/nginx/nginx.conf
EXPOSE 8080

COPY --from=build /app/build /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]
