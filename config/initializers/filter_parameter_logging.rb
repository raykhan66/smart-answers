# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
if Rails.env.production? && ENV['RUNNING_ON_HEROKU'].blank?
  Rails.application.config.filter_parameters += [:responses]
end
