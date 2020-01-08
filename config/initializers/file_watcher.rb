if ENV['DISABLE_SPRING'] == '1'
  Thread.new do
    Filewatcher.new("#{Rails.root}/app").watch do |filename, event|
      load filename
    end
  end
end