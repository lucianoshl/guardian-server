# frozen_string_literal: true

abort('Enviroment variable ENV is required') if ENV['ENV'].blank?
abort('Enviroment variable MONGO_URL is required') if ENV['MONGO_URL'].blank?
