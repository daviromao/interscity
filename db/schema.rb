# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171207193134) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "basic_resources", force: :cascade do |t|
    t.string   "uri"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.float    "lat"
    t.float    "lon"
    t.string   "status"
    t.integer  "collect_interval"
    t.text     "description"
    t.string   "uuid"
    t.string   "city"
    t.string   "neighborhood"
    t.string   "state"
    t.string   "postal_code"
    t.string   "country"
    t.index ["lat", "lon"], name: "index_basic_resources_on_lat_and_lon", using: :btree
    t.index ["uuid"], name: "index_basic_resources_on_uuid", unique: true, using: :btree
  end

  create_table "basic_resources_capabilities", id: false, force: :cascade do |t|
    t.integer "basic_resource_id"
    t.integer "capability_id"
    t.index ["basic_resource_id"], name: "index_basic_resources_capabilities_on_basic_resource_id", using: :btree
    t.index ["capability_id"], name: "index_basic_resources_capabilities_on_capability_id", using: :btree
  end

  create_table "capabilities", force: :cascade do |t|
    t.string  "name"
    t.integer "function"
    t.text    "description"
    t.index ["name"], name: "index_capabilities_on_name", unique: true, using: :btree
  end

end
