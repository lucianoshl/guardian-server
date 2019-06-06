FROM ruby:2.5-alpine

RUN apk update && apk upgrade && apk add --update build-base tzdata curl less
RUN rm -rf /var/cache/apk/*

ENV APP /usr/app

RUN mkdir $APP
WORKDIR $APP

COPY Gemfile $APP
COPY Gemfile.lock $APP
RUN bundle install
COPY . $APP