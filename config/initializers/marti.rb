Marti.configure do |config|
  config.article_directory = File.join(Rails.root, *%w(app articles))
end
