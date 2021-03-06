Rollbar.configure do |config|
  # Without configuration, Rollbar is enabled in all environments.
  # To disable in specific environments, set config.enabled=false.

  config.access_token = '7a0de940426844c8aa5c3dba4b32b8f5'

  # Here we'll disable in 'test':
  if Rails.env.test? || Rails.env.development?
    config.enabled = false
  end

  # By default, Rollbar will try to call the `current_user` controller method
  # to fetch the logged-in user object, and then call that object's `id`,
  # `username`, and `email` methods to fetch those properties. To customize:
  # config.person_method = "my_current_user"
  # config.person_id_method = "my_id"
  # config.person_username_method = "my_username"
  # config.person_email_method = "my_email"

  # If you want to attach custom data to all exception and message reports,
  # provide a lambda like the following. It should return a hash.
  # config.custom_data_method = lambda { {:some_key => "some_value" } }

  # Add exception class names to the exception_level_filters hash to
  # change the level that exception is reported at. Note that if an exception
  # has already been reported and logged the level will need to be changed
  # via the rollbar interface.
  # Valid levels: 'critical', 'error', 'warning', 'info', 'debug', 'ignore'
  # 'ignore' will cause the exception to not be reported at all.
  # config.exception_level_filters.merge!('MyCriticalException' => 'critical')
  #
  # You can also specify a callable, which will be called with the exception instance.
  # config.exception_level_filters.merge!('MyCriticalException' => lambda { |e| 'critical' })

  # Enable asynchronous reporting (uses girl_friday or Threading if girl_friday
  # is not installed)
  # config.use_async = true
  # Supply your own async handler:
  # config.async_handler = Proc.new { |payload|
  #  Thread.new { Rollbar.process_from_async_handler(payload) }
  # }

  # Enable asynchronous reporting (using sucker_punch)
  # config.use_sucker_punch

  # Enable delayed reporting (using Sidekiq)
  # config.use_sidekiq
  # You can supply custom Sidekiq options:
  # config.use_sidekiq 'queue' => 'default'

  # If you run your staging application instance in production environment then
  # you'll want to override the environment reported by `Rails.env` with an
  # environment variable like this: `ROLLBAR_ENV=staging`. This is a recommended
  # setup for Heroku. See:
  # https://devcenter.heroku.com/articles/deploying-to-a-custom-rails-environment
  config.environment = ENV['ROLLBAR_ENV'] || Rails.env

  # Ignore the typical "attacks..."
  config.exception_level_filters.merge!('ActionController::RoutingError' => lambda { |e|
    e.message =~ %r(No route matches \[[A-Z]+\] "/(.+)")

    result = 'warning'
    url_parts  = $1.downcase.split("/").reject!(&:blank?)
    return result if url_parts.blank?

    errors = [ "apptagi", "asp", "aspx", "cfide", "cgi-bin", "clientaccesspolicy.xml", "hnap1", "home.asp", "index.php", "jsp",
               "maios.html", "myadmin", "password.cgi", "php", "phpmyadmin", "pma", "server-status", "test",
               "testproxy.php", "vb", "w00tw00t", "webdav", "wordpress", "wp", "wp-admin", "xmlrpc.php", "zecmd"]

    url_parts.each do |part|
      if errors.include?(part)
        result = 'ignore'
      end
    end

    if result == 'warning'
      file_parts = url_parts.last.split(".")

      result = case file_parts.last
      when *errors
        'ignore'

      else
        'warning'
      end
    end

    result
  })
end
