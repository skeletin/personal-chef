# Usage: bin/rails runner script/export_storefront_snapshot.rb
# Writes db/seeds/storefront_snapshot.yml and db/seeds/attachments/* from the current DB.

require "fileutils"

attachments_dir = Rails.root.join("db/seeds/attachments")
FileUtils.mkdir_p(attachments_dir)

rows =
  Liquor.includes(photo_attachment: :blob).order(Arel.sql("LOWER(liquors.name)")).map do |l|
    unless l.photo.attached?
      raise "Liquor #{l.name.inspect} has no attached photo — add one or detach requirement in export script."
    end

    ext = File.extname(l.photo.filename.to_s).downcase
    ext = ".jpg" if ext.blank?
    safe = "#{l.name.parameterize(separator: '-')}" + ext

    File.binwrite(attachments_dir.join(safe), l.photo.download)

    h = {
      "name" => l.name,
      "quantity" => l.quantity,
      "price" => format("%.2f", l.price.to_d),
      "attachment" => safe
    }

    h["category"] = l.category if l.category.present?
    h["typical_store_price"] = format("%.2f", l.typical_store_price.to_d) if l.typical_store_price.present?
    h["comparison_note"] = l.comparison_note if l.comparison_note.present?
    h["comparison_url"] = l.comparison_url if l.comparison_url.present?
    h["notes"] = l.notes if l.notes.present?
    h
  end

snapshot_path = Rails.root.join("db/seeds/storefront_snapshot.yml")

File.open(snapshot_path, "w") do |f|
  f.puts "# Auto-generated snapshot of storefront inventory (Liquor rows + filenames into db/seeds/attachments)."
  f.puts "# Regenerate after changing dev data:"
  f.puts "#   bin/rails runner script/export_storefront_snapshot.rb"
  YAML.dump({ "liquors" => rows }, f, line_width: -1)
end

puts "Wrote #{snapshot_path} (#{rows.size} listing(s))"
rows.each do |r|
  p = attachments_dir.join(r.fetch("attachment"))
  puts "  #{p.basename} (#{p.size} bytes)"
end
