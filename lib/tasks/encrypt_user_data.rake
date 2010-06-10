namespace :db do
  namespace :populate do
    desc "Convert encrypted user data to clear text"
    task :decrypted_user_data => :environment do
      attrs = [:email, :name, :gender]
      users = User.find_all_by_network_id(2)
      users.each do |u|
        timebox "Updated #{u.slug}" do
          attrs.each do |a| 
            u.write_attribute(a, u.send(a))
            u.write_attribute("encrypted_#{a.to_s}".to_sym, nil) unless ENV.has_key?('keep_original')
          end
          u.write_attribute(:born_on, Date.parse(u.born_on_string))
          u.write_attribute("encrypted_born_on_string".to_sym, nil) unless ENV.has_key?('keep_original')
          u.save!
        end
      end
    end

    desc "Convert clear text to encrypted data"
    task :encrypted_user_data => :environment do
      attrs = [:email, :name, :gender]
      users = User.find_all_by_network_id(2)
      users.each do |u|
        timebox "Updated #{u.slug}" do
          attrs.each do |a|
            u.send("#{a.to_s}=".to_sym, u.read_attribute(a))
            u.write_attribute(a, nil) unless ENV.has_key?('keep_original')
          end
          u.born_on_string = u.read_attribute(:born_on).to_s
          u.write_attribute(:born_on, nil) unless ENV.has_key?('keep_original') 
          u.save!
        end
      end
    end
  end
end