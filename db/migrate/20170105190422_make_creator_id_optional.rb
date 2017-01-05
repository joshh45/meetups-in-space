class MakeCreatorIdOptional < ActiveRecord::Migration
  def change
    change_column_null :meetups, :creator_id, true
    change_column :meetups, :description, :text
  end
end
