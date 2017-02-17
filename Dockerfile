FROM ruby:2.3.3-alpine

ENV AUTHIFY_PORT=3000
ENV AUTHIFY_PUBLIC_URL=http://auth.example.com:${AUTHIFY_PORT}
ENV AUTHIFY_API_URL=http://auth.example.com:9292
ENV AUTHIFY_ACCESS_KEY="1a2b3c4d5e6f789"
ENV AUTHIFY_SECRET_KEY="1a2b3c4d5e6f789"
ENV AUTHIFY_ENVIRONMENT=development
ENV AUTHIFY_JWT_ISSUER="My Awesome Company Inc."
ENV AUTHIFY_JWT_ALGORITHM="ES512"

RUN apk --no-cache upgrade \
    && apk --no-cache add git nodejs tzdata

RUN apk --no-cache add --virtual build-dependencies \
        build-base \
        ruby-dev

COPY . /app
RUN cd /app \
    && bundle install --jobs=4 \
    && apk del build-dependencies

RUN chown -R root:root /app \
    && chown -R nobody:nogroup /app/tmp

USER nobody
WORKDIR /app

CMD rails s \
       -b 0.0.0.0 \
       -p $AUTHIFY_PORT \
       -e $AUTHIFY_ENVIRONMENT
