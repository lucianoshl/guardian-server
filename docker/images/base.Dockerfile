FROM ruby:2.5
RUN apt-get update -qq \
  && apt-get install -y nodejs libpq-dev build-essential
COPY . /app
WORKDIR /app
RUN bundle install
RUN bundle exec rake assets:precompile
EXPOSE 5000
CMD bin/rails s