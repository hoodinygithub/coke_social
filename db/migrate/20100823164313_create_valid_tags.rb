class CreateValidTags < ActiveRecord::Migration
  def self.up
    create_table :valid_tags do |t|
      t.integer :site_id
      t.integer :tag_id
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :valid_tags, [:site_id, :tag_id]
  end

  def self.down
    remove_index :valid_tags, [:site_id, :tag_id]
    drop_table :valid_tags
  end
end