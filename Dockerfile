FROM ruby:2.5.7
RUN apt-get update -qq && \
   apt-get install -y nodejs libpq-dev build-essential libnss3-dev unzip xvfb libxi6 libgconf-2-4 && \
   wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
   dpkg -i google-chrome-stable_current_amd64.deb ; \
   apt-get -fy install

RUN wget -N https://chromedriver.storage.googleapis.com/79.0.3945.36/chromedriver_linux64.zip -P /tmp && \
  unzip /tmp/chromedriver_linux64.zip -d /tmp && \
  mv -f /tmp/chromedriver /usr/local/share/ && \
  chmod +x /usr/local/share/chromedriver && \
  ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver && \
  ln -s /usr/local/share/chromedriver /usr/bin/chromedriver

RUN chown root -R /opt/google/chrome && \
  chmod 4755 /opt/google/chrome/chrome  && \
  chmod 4755 /opt/google/chrome/chrome-sandbox 

COPY . /app
WORKDIR /app
RUN gem install bundler
RUN bundle install
RUN bundle exec rake assets:precompile
EXPOSE 5000
CMD bundle exec foreman start -f Procfile.workers --timestamp=false