# Liquor inventory (Rails 8)

Public storefront listing **liquor names, optional bottle photos**, **quantities**, **prices**, and **optional shelf benchmarks** (curated “typical store” comparisons you maintain), with **live stock** reflected on the page. Owners sign in via **sessions** (`/session/new`) with a **username + password**, then manage stock under **`/admin/liquors`**. There is **no sign-up**: create the admin user via `db:seed` and environment credentials.

Stack: Rails 8, PostgreSQL, Tailwind CSS v4. Visual system uses **Rubik** (headings) and **Nunito Sans** (body) with a slate + sky retail palette.

## Prerequisites

- Ruby 3.4+
- PostgreSQL
- Env: `DATABASE_URL` (production), `SECRET_KEY_BASE`, and optional **`ACTIVE_STORAGE_ROOT`** — set this to your persisted volume mount when it is **not** `…/storage` inside the app (e.g. mount **`/data`** → **`ACTIVE_STORAGE_ROOT=/data`**)

## Deploy / migrations

Never edit shipped migrations (`db/migrate/20260515230159_create_bookings.rb` stays historical); new tables and drops are appended so `bin/rails db:migrate` stays safe on an already-deployed DB.

Production after deploy:

```bash
bin/rails db:migrate
bin/rails db:seed   # creates admin user + storefront from db/seeds snapshot (see below)
```

`db:seed` **requires** `ADMIN_USERNAME` and `ADMIN_PASSWORD` in every environment (use strong values in production). Username is normalized to lowercase; passwords are bcrypt-hashed (max **72 bytes** on input).

### Local `.env` example (development only)

| Variable | Sample |
|---------|--------|
| `ADMIN_USERNAME` | `admin` |
| `ADMIN_PASSWORD` | `changeme-strong-12-char` |

It also expects **`db/seeds/storefront_snapshot.yml`** plus images in **`db/seeds/attachments/`** — commit those alongside the release. Rows are upserted by bottle **name**; by default anything in **`liquors` not listed in the snapshot is destroyed (set **`SKIP_STOREFRONT_SEED_PRUNE=true`** to keep extra rows you added manually outside the snapshot).

```bash
bin/rails runner script/export_storefront_snapshot.rb
# then git add/commit db/seeds/storefront_snapshot.yml db/seeds/attachments/
```

### Changing the admin password

There is **no “forgot password”** email flow. To set a new password in production use the console (or temporarily run a one-off script):

```ruby
user = User.find_by!(username: "admin") # or your username
user.password = "new-strong-secret"
user.save!
```

## Key routes

| Path | Who |
|------|-----|
| `/` | Public inventory grid |
| `/session/new` | Staff login |
| `/admin/liquors` | CRUD (authenticated only) |

## Local workflow

For **development/test**, optional local variables go in `.env` (gitignored). Copy the template:

```bash
cp .env.example .env   # edit values; dotenv-rails loads `.env` when you boot Rails/console
bin/setup                       # bundle + db:prepare + launch bin/dev (omit --skip-server to skip server)
bin/rails db:seed               # requires ADMIN_USERNAME and ADMIN_PASSWORD in `.env`
bin/rails server                # if you prefer `bin/rails s` outside bin/dev / Foreman stack
```


## Operational notes

- **Storefront snapshots:** Checked-in **`db/seeds/storefront_snapshot.yml`** + **`db/seeds/attachments/`** recreate your dev shelf in other environments (`bin/rails db:seed`).
- **Shelf benchmarks (optional):** On each bottle, staff can set a **typical liquor-store shelf price**, optional **https link** to a listing shoppers can open, and a **short note**. The public inventory shows this under your selling price (manual curation — not auto-scraped “live every retailer” pricing).
- **Liquor photos (Active Storage):** Admins attach one storefront image per item (JPEG / PNG / Webp, capped in app). In production, Disk **`root`** is **`ENV["ACTIVE_STORAGE_ROOT"]`**, falling back to **`Rails.root/storage`** ([`config/storage.yml`](config/storage.yml)). Railway: if your volume mounts at **`/data`**, set **`ACTIVE_STORAGE_ROOT=/data`** on the web service — otherwise uploads still go under the ephemeral app tree. Alternative: **S3/R2** for multi-instance / CDN.
- **Bookings retired:** the legacy `bookings` table was dropped via a forward-only migration (`DropBookings`); back up/export first if production data matters.
- **`/me.PNG` hero:** that chef portrait is gone; replace branding via layout + Tailwind `@theme`.
- **`/up`** health check remains wired for Railway.
