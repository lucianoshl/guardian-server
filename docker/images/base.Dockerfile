FROM ruby:2.5

ENV APP /usr/app
COPY . $APP
WORKDIR $APP
RUN bundle install