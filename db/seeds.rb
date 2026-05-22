# Load with: bin/rails db:seed
#
# 1. Creates / updates the staff user — set ADMIN_USERNAME and ADMIN_PASSWORD in the environment
#    (see README). Dotenv picks up `.env` in development/test.
#
# 2. Applies storefront inventory from `db/seeds/storefront_snapshot.yml`, including bottle photos in
#    `db/seeds/attachments/` (exported from development via `bin/rails runner script/export_storefront_snapshot.rb`).
#
# Rows in the snapshot are upserted by `name`. Liquors absent from YAML are destroyed unless you set
# `SKIP_STOREFRONT_SEED_PRUNE=true`.

require "yaml"

def seed_storefront_from_snapshot!
  snapshot_path = Rails.root.join("db/seeds/storefront_snapshot.yml")

  unless File.file?(snapshot_path)
    raise <<~MESSAGE.squish
      Missing #{snapshot_path.relative_path_from(Rails.root)}.
      Export it from development: bin/rails runner script/export_storefront_snapshot.rb — then commit
      the YAML and attachment files before seeding elsewhere.
    MESSAGE
  end

  snapshot_doc = YAML.load_file(snapshot_path)
  rows = snapshot_doc.is_a?(Hash) ? snapshot_doc["liquors"] : nil
  raise "storefront_snapshot.yml must define a top-level 'liquors' array" unless rows.is_a?(Array)

  allowed_names = rows.map { |row| row.fetch("name") }

  Liquor.transaction do
    skip_prune = ActiveModel::Type::Boolean.new.cast(
      ENV.fetch("SKIP_STOREFRONT_SEED_PRUNE", "false")
    )

    unless skip_prune
      Liquor.where.not(name: allowed_names).find_each(&:destroy!)
    end

    rows.each do |row|
      name = row.fetch("name")

      liquor = Liquor.find_or_initialize_by(name: name)
      liquor.quantity = Integer(row.fetch("quantity"))
      liquor.price = BigDecimal(row.fetch("price"))
      liquor.category = row["category"].presence
      liquor.typical_store_price = row["typical_store_price"].present? ? BigDecimal(row["typical_store_price"]) : nil
      liquor.comparison_note = row["comparison_note"].presence
      liquor.comparison_url = row["comparison_url"].presence
      liquor.notes = row["notes"].presence || ""
      liquor.save!

      attachment = row.fetch("attachment")
      path = Rails.root.join("db/seeds/attachments", attachment)

      unless path.file?
        raise "Seed attachment missing: #{path.relative_path_from(Rails.root)} (referenced by #{name.inspect})"
      end

      content_type = Marcel::MimeType.for(Pathname(path))

      liquor.photo.purge if liquor.photo.attached?

      liquor.photo.attach(
        io: StringIO.new(File.binread(path)),
        filename: attachment,
        content_type: content_type
      )
    end
  end
end

admin_username = ENV["ADMIN_USERNAME"]

admin_password = ENV["ADMIN_PASSWORD"]

if admin_username.blank? || admin_password.blank?
  raise <<~MESSAGE.squish
    Set ADMIN_USERNAME and ADMIN_PASSWORD in the environment before seeding (#{Rails.env}) — there is intentionally no public sign-up UI.
  MESSAGE
end

user = User.find_or_initialize_by(username: admin_username.to_s.strip.downcase)
user.password = admin_password
user.save!

seed_storefront_from_snapshot!
