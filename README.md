[![Build Status](https://travis-ci.org/lucianoshl/guardian-server.svg?branch=master)](https://travis-ci.org/lucianoshl/guardian-server)
[![Coverage Status](https://coveralls.io/repos/github/lucianoshl/guardian-server/badge.svg?branch=master)](https://coveralls.io/github/lucianoshl/guardian-server?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/2ca7992702f76e8037d6/maintainability)](https://codeclimate.com/github/lucianoshl/guardian-server/maintainability)

# Guardian server
## Deploy app
git clone https://github.com/lucianoshl/guardian-server

cd guardian-server

heroku apps:create <app_name>

heroku config:set ENV=production MONGO_URL=<mongo_server_uri>