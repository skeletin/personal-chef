Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{172800}" }
  config.active_support.deprecation_behavior = [ :stderr, :log ]

  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :file
  config.action_mailer.file_settings = { location: Rails.root.join("tmp", "mail_store") }

  config.active_storage.service = :local
end
