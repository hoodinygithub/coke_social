class AddIndexOnCommentableToComments < ActiveRecord::Migration
  def self.up
    add_index :comments, [:commentable_type, :commentable_id]
  end

  def self.down
    remove_index :comments, :column => [:commentable_type, :commentable_id]
  end
end
