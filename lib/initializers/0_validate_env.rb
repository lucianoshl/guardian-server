# frozen_string_literal: true

raise('Enviroment variable ENV is required') if ENV['ENV'].blank?
raise('Enviroment variable MONGO_URL is required') if ENV['MONGO_URL'].blank?
