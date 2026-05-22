# Railway / production web process — full chain requested for start.
# Note: migrate + seed run on every boot of this container. Prefer a singleton “release” job if you scale beyond one web dyno.
web: bundle exec rails assets:precompile && bundle exec rails db:migrate && bundle exec rails db:seed && bundle exec puma -C config/puma.rb
