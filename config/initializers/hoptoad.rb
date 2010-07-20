if Rails.env.production?
  HoptoadNotifier.configure do |config|
    config.api_key = 'f7647ab497343a81ba2de713a7895d03'
    config.ignore_user_agent << /(bot)|(spider)/i
  end
end
