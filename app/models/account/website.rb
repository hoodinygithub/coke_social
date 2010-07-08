module Account::Website
  def self.included(base)
    base.class_eval do
      serialize :websites, Array
    end
  end

  def websites
    write_attribute(:websites, []) if read_attribute(:websites).blank?
    read_attribute(:websites)
  end

  def websites=(ary)
    ary.each { |v| puts v }
    ary.reject! { |v| !(/[A-Za-z0-9-_]+\.[A-Za-z0-9-_%&\?\/.=]+$/).match(v) }
    ary.each { |v| v.gsub!('http://', '') }
    write_attribute(:websites, Array(ary).select{|v| !v.blank? }[0..4]) # write up to 5 non-blank items
  end
end
