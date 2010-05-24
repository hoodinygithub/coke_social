class RecreateComments < ActiveRecord::Migration
  def self.up
    drop_table :comments

    create_table :comments, :force => true do |t|
      t.string   :title, :limit => 50, :default => ""
      t.string   :comment, :default => ""
      t.datetime :created_at, :null => false
      t.integer  :commentable_id, :default => 0, :null => false
      t.string   :commentable_type, :limit => 15, :default => "", :null => false
      t.integer  :user_id, :default => 0, :null => false
      t.integer  :rating, :default => 0
    end

    add_index :comments, ["user_id"], :name => "fk_comments_user"
  end

  def self.down
    drop_table :comments
    create_table "comments" do |t|
      t.integer :owner_id
      t.string  :commentable_type
      t.integer :commentable_id
      t.text    :body
      t.timestamps
    end
  end
end
