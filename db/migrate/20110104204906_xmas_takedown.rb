class XmasTakedown < ActiveRecord::Migration
  # ValidTag.unscoped isn't introduced until Rails3
  class Foo < ValidTag; def self.unscoped; with_exclusive_scope { yield }; end; end

  def self.up
    Badge.update_all({:status => 'inactive'}, {:promo_id => 1} )
    ValidTag.update_all({:deleted_at => Time.now}, {:promo_id => 1})
  end

  def self.down
    Badge.update_all({:status => 'active'}, {:promo_id => 1} )
    Foo.unscoped { Foo.update_all({:deleted_at => nil}, {:promo_id => 1}) }
  end
end

