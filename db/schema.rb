# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090329170101) do

  create_table "idx_reports", :force => true do |t|
    t.string "patient_id",       :limit => 15
    t.text   "patient_name"
    t.date   "patient_dob"
    t.string "patient_sex",      :limit => 1
    t.string "accession_number", :limit => 15
    t.string "status_code",      :limit => 5
    t.string "resource",         :limit => 10
    t.text   "diag"
    t.text   "procedure_name"
    t.string "requesting",       :limit => 64
    t.string "exam_code",        :limit => 20
    t.string "in_out",           :limit => 2
    t.string "dept",             :limit => 10
    t.string "site",             :limit => 10
    t.string "technologist",     :limit => 64
    t.string "assisting",        :limit => 64
    t.string "attending",        :limit => 64
    t.string "mrn",              :limit => 20
    t.string "report_lines",     :limit => 4
    t.text   "report"
  end

  add_index "idx_reports", ["patient_id"], :name => "some_id"
  add_index "idx_reports", ["accession_number"], :name => "accession_number"

  create_table "search_import", :force => true do |t|
    t.string  "name",             :limit => 64, :null => false
    t.integer "last_id_imported",               :null => false
  end

  add_index "search_import", ["name"], :name => "db", :unique => true

  create_table "search_logs", :force => true do |t|
    t.text     "reason_for"
    t.string   "username"
    t.text     "search_string"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
