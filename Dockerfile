FROM ruby:2.5.5
RUN apt-get update -qq \
  && apt-get install -y nodejs libpq-dev build-essential libnss3-dev unzip

RUN wget -N http://chromedriver.storage.googleapis.com/2.29/chromedriver_linux64.zip -P /tmp
RUN unzip /tmp/chromedriver_linux64.zip -d ~/tmp
RUN mv -f /tmp/chromedriver /usr/local/share/
RUN chmod +x /usr/local/share/chromedriver
RUN ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver
RUN ln -s /usr/local/share/chromedriver /usr/bin/chromedriver

COPY . /app
WORKDIR /app
RUN gem install bundler
RUN bundle install
RUN bundle exec rake assets:precompile
EXPOSE 5000
CMD bundle exec foreman start -f Procfile.workers --timestamp=false