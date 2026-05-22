Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{31536000}" }
  config.public_file_server.enabled = true
  config.assume_ssl = true
  config.force_ssl = true
  config.ssl_options = { redirect: { exclude: ->(r) { r.path == "/up" } } }
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_tags = [ :request_id ]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info").to_sym
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false
  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]
  config.hosts << "liqstore.up.railway.app"
  config.require_master_key = false

  public_host = ENV.fetch("RAILS_PUBLIC_HOST", "liqstore.up.railway.app")
  protocol = ENV.fetch("RAILS_PUBLIC_PROTOCOL", "https")
  config.action_mailer.default_url_options = { host: public_host, protocol: protocol }
  config.action_mailer.raise_delivery_errors = false

  if (smtp_address = ENV["SMTP_ADDRESS"]).present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    smtp = {
      address: smtp_address,
      port: ENV.fetch("SMTP_PORT", "587").to_i,
      enable_starttls_auto: ENV.fetch("SMTP_ENABLE_STARTTLS_AUTO", "true") == "true"
    }
    if ENV["SMTP_USER_NAME"].present?
      smtp[:user_name] = ENV["SMTP_USER_NAME"]
      smtp[:password] = ENV["SMTP_PASSWORD"]
      smtp[:authentication] = ENV["SMTP_AUTH"].presence&.to_sym || :plain
    end
    config.action_mailer.smtp_settings = smtp
  else
    config.action_mailer.perform_deliveries = false
  end

  config.active_storage.service = :production
end
