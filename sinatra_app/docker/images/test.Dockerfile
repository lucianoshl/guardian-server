FROM lucianoshl/guardian-base

RUN apk update && apk upgrade && apk add --update git curl
RUN rm -rf /var/cache/apk/*

RUN curl -o /cc-test-reporter -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64
RUN chmod +x /cc-test-reporter