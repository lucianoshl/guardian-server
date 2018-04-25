# Guardian server
## Deploy app
git clone https://github.com/lucianoshl/guardian-server
cd guardian-server
heroku apps:create <app_name>
heroku config:set ENV=production MONGO_URL=<mongo_server_uri>