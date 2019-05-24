FROM ruby:2.5-alpine

RUN apk update && apk upgrade && apk add --update build-base tzdata curl git
RUN rm -rf /var/cache/apk/*

RUN mkdir /usr/app 
WORKDIR /usr/app

COPY Gemfile /usr/app/ 
COPY Gemfile.lock /usr/app/ 
RUN bundle install