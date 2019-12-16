FROM ruby:2.5.5
RUN apt-get update -qq \
  && apt-get install -y nodejs libpq-dev build-essential libnss3-dev
COPY . /app
WORKDIR /app
RUN gem install bundler
RUN bundle install
RUN bundle exec rake assets:precompile
EXPOSE 5000
CMD bundle exec foreman start -f Procfile.workers --timestamp=false