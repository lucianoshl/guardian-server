# frozen_string_literal: true

ENV['ENV'] ||= 'development'
ENV['RACK_ENV'] = ENV['ENV'] || 'development'

require 'rubygems'
require 'rake'

namespace 'guardian' do
  desc 'Run webapp'
  task :server do
    ENV['PORT'] = ENV['PORT'] || '3000'
    sh("ENV=#{ENV['ENV']} bundle exec rackup -p #{ENV['PORT']} config/config.ru")
  end

  desc 'Run worker'
  task :worker do
    ARGV.shift
    queue = ARGV.empty? ? '' : " --queue=#{ARGV[0]}"
    sh("ENV=#{ENV['ENV']} bundle exec ruby ./bin/delayed_job.rb run#{queue}")
  end

  desc 'Run console'
  task :console do
    sh("ENV=#{ENV['ENV']} bundle exec ruby ./bin/console.rb")
  end
end

if ENV['ENV'] == 'test'
  require 'rspec/core/rake_task'
  require 'coveralls/rake/task'
  desc 'Run RSpec'
  RSpec::Core::RakeTask.new do |t|
    t.verbose = false
  end
  task default: :spec
  Coveralls::RakeTask.new
end
