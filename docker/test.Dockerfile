FROM lucianoshl/guardian-base

RUN apk update && apk upgrade && apk add --update git
RUN rm -rf /var/cache/apk/*

RUN curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./cc-test-reporter
RUN chmod +x ./cc-test-reporter

COPY . /usr/app