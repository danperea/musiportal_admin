# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_09_19_090120) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.date "date"
    t.string "time"
    t.string "location"
    t.text "description"
    t.string "event_type"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "group_id"
    t.index ["group_id"], name: "index_events_on_group_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_genres_on_created_by_id"
    t.index ["name"], name: "index_genres_on_name", unique: true
  end

  create_table "gig_applications", force: :cascade do |t|
    t.bigint "gig_id"
    t.bigint "user_id"
    t.integer "offer_amount"
    t.text "message"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "group_id"
    t.index ["gig_id"], name: "index_gig_applications_on_gig_id"
    t.index ["group_id"], name: "index_gig_applications_on_group_id"
    t.index ["status"], name: "index_gig_applications_on_status"
    t.index ["user_id"], name: "index_gig_applications_on_user_id"
  end

  create_table "gigs", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.jsonb "genres", default: []
    t.string "location"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer "budget_min"
    t.integer "budget_max"
    t.integer "status", default: 0
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "event_id"
    t.index ["event_id"], name: "index_gigs_on_event_id"
    t.index ["starts_at"], name: "index_gigs_on_starts_at"
    t.index ["status"], name: "index_gigs_on_status"
    t.index ["user_id"], name: "index_gigs_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.string "type"
    t.string "bio"
    t.jsonb "genres", default: []
    t.string "location"
    t.string "website"
    t.string "image_url"
    t.string "email"
    t.string "phone"
    t.text "description"
    t.boolean "verified", default: false
    t.float "latitude"
    t.float "longitude"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "vibes", default: []
    t.string "zipCode"
    t.string "demo_video_url"
    t.jsonb "featured_videos", default: []
    t.json "group_pictures", default: []
    t.jsonb "video_data"
    t.index ["deleted_at"], name: "index_groups_on_deleted_at"
    t.index ["genres"], name: "index_groups_on_genres", using: :gin
    t.index ["latitude", "longitude"], name: "index_groups_on_latitude_and_longitude"
    t.index ["location"], name: "index_groups_on_location"
    t.index ["name"], name: "index_groups_on_name"
    t.index ["type"], name: "index_groups_on_type"
    t.index ["verified"], name: "index_groups_on_verified"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.string "status", default: "active"
    t.datetime "joined_at"
    t.datetime "left_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "roles", default: []
    t.index ["deleted_at"], name: "index_memberships_on_deleted_at"
    t.index ["group_id"], name: "index_memberships_on_group_id"
    t.index ["joined_at"], name: "index_memberships_on_joined_at"
    t.index ["roles"], name: "index_memberships_on_roles", using: :gin
    t.index ["status"], name: "index_memberships_on_status"
    t.index ["user_id", "group_id"], name: "index_memberships_on_user_id_and_group_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "similarities", force: :cascade do |t|
    t.string "source_type"
    t.integer "source_id"
    t.string "target_type"
    t.integer "target_id"
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_similarities_on_created_by_id"
    t.index ["source_id"], name: "index_similarities_on_source_id"
    t.index ["source_type", "source_id", "target_type", "target_id"], name: "idx_similarities_unique", unique: true
    t.index ["source_type", "source_id"], name: "index_similarities_on_source_type_and_source_id"
    t.index ["source_type"], name: "index_similarities_on_source_type"
    t.index ["target_id"], name: "index_similarities_on_target_id"
    t.index ["target_type", "target_id"], name: "index_similarities_on_target_type_and_target_id"
    t.index ["target_type"], name: "index_similarities_on_target_type"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.jsonb "genres", default: []
    t.string "location"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "bio"
    t.string "phone"
    t.jsonb "roles", default: []
    t.bigint "active_group_id"
    t.jsonb "vibes", default: []
    t.jsonb "portfolio_videos", default: []
    t.string "profile_picture"
    t.index ["active_group_id"], name: "index_users_on_active_group_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["roles"], name: "index_users_on_roles", using: :gin
  end

  create_table "vibes", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_vibes_on_created_by_id"
    t.index ["name"], name: "index_vibes_on_name", unique: true
  end

  add_foreign_key "events", "groups"
  add_foreign_key "events", "users"
  add_foreign_key "genres", "users", column: "created_by_id"
  add_foreign_key "gig_applications", "gigs"
  add_foreign_key "gig_applications", "groups"
  add_foreign_key "gig_applications", "users"
  add_foreign_key "gigs", "events"
  add_foreign_key "gigs", "users"
  add_foreign_key "memberships", "groups"
  add_foreign_key "memberships", "users"
  add_foreign_key "similarities", "users", column: "created_by_id"
  add_foreign_key "users", "groups", column: "active_group_id"
  add_foreign_key "vibes", "users", column: "created_by_id"
end
