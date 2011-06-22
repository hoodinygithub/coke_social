class AddUniqueIndexToStationPlayables < ActiveRecord::Migration
  def self.up
    #remove_index :stations, [:playable_type, :playable_id]
    #add_index :stations, [:playable_type, :playable_id], :unique => true
  end

  def self.down
    remove_index :stations, [:playable_type, :playable_id], :unique => true
    add_index :stations, [:playable_type, :playable_id]
  end
end
