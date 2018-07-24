# frozen_string_literal: true

current_folder = File.dirname(__FILE__)

Thread.new do
  Filewatcher.new("#{current_folder}/..").watch do |filename, _event|
    load filename
  end
end
