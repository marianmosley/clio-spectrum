
NewBooks::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  :address => "smtp.gmail.com",
  :enable_starttls_auto => true, 
  :port => "587",
  :authentication => :plain,
  :user_name => "clio.new.arrivals@gmail.com",
  :password => "qbridge7engage"
}
  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
end