require 'pry'

ENV['RACK_ENV'] = ENV['ENV'] 

namespace 'guardian' do
  desc "Run webapp"
  task :server do
    ENV['PORT'] = ENV['PORT'] || '3000'
    sh("bundle exec ruby ./bin/run.rb -p #{ENV['PORT']}")
  end

  desc "Run worker"
  task :worker do
    ARGV.shift
    queue = ARGV.empty? ?  '' : " --queue=#{ARGV[0]}"
    sh("bundle exec ruby ./bin/delayed_job.rb run#{queue}")
  end
end
