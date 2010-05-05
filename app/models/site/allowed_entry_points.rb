module Site::AllowedEntryPoints
  def self.included(base)
    base.class_eval do
      serialize :allowed_entry_points, Array
    end
  end

  def allowed_entry_points
    read_attribute(:allowed_entry_points) || write_attribute(:allowed_entry_points, [])
  end
end
