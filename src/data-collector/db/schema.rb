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

ActiveRecord::Schema.define(version: 20160629145403) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "capabilities", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_capabilities_on_name", unique: true, using: :btree
  end

  create_table "last_sensor_values", force: :cascade do |t|
    t.string   "value"
    t.float    "f_value"
    t.datetime "date"
    t.integer  "capability_id"
    t.integer  "platform_resource_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["capability_id"], name: "index_last_sensor_values_on_capability_id", using: :btree
    t.index ["platform_resource_id"], name: "index_last_sensor_values_on_platform_resource_id", using: :btree
  end

  create_table "platform_resource_capabilities", force: :cascade do |t|
    t.integer  "capability_id"
    t.integer  "platform_resource_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["capability_id"], name: "index_platform_resource_capabilities_on_capability_id", using: :btree
    t.index ["platform_resource_id", "capability_id"], name: "index_platform_resource_capabilities", unique: true, using: :btree
    t.index ["platform_resource_id"], name: "index_platform_resource_capabilities_on_platform_resource_id", using: :btree
  end

  create_table "platform_resources", force: :cascade do |t|
    t.string   "uri"
    t.string   "uuid"
    t.string   "status"
    t.integer  "collect_interval"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["uuid"], name: "index_platform_resources_on_uuid", unique: true, using: :btree
  end

  create_table "sensor_values", force: :cascade do |t|
    t.string   "value"
    t.datetime "date"
    t.integer  "capability_id"
    t.integer  "platform_resource_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.float    "f_value"
    t.index ["capability_id"], name: "index_sensor_values_on_capability_id", using: :btree
    t.index ["platform_resource_id"], name: "index_sensor_values_on_platform_resource_id", using: :btree
  end

end
