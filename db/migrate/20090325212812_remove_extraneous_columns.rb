class RemoveExtraneousColumns < ActiveRecord::Migration
  def self.up

    remove_column :idx_reports, :some_datetime
    remove_column :idx_reports, :admitted_datetime
    remove_column :idx_reports, :discharge_datetime
    remove_column :idx_reports, :scheduled_datetime
    remove_column :idx_reports, :complete_datetime
    remove_column :idx_reports, :visit_number
    remove_column :idx_reports, :exambegin_datetime
    remove_column :idx_reports, :examend_datetime
    remove_column :idx_reports, :order_number

  end

  def self.down
    add_column :idx_reports, :some_datetime, :datetime
    add_column :idx_reports, :admitted_datetime, :datetime
    add_column :idx_reports, :discharge_datetime, :datetime
    add_column :idx_reports, :scheduled_datetime, :datetime
    add_column :idx_reports, :complete_datetime, :datetime
    add_column :idx_reports, :visit_number, :string, :limit => 20
    add_column :idx_reports, :order_number, :string, :limit => 30
    add_column :idx_reports, :exambegin_datetime, :datetime
    add_column :idx_reports, :examend_datetime, :datetime
  end
  
end
