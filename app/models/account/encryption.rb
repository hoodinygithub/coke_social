module Account::Encryption
  def self.included(base)
    base.class_eval do
      attr_encrypted :email, :key => :encryption_key      
      attr_encrypted :name, :key => :encryption_key      
      attr_encrypted :born_on_string, :key => :encryption_key      
      attr_encrypted :gender, :key => :encryption_key      
    end
  end

  def encryption_key
    '1710d78515ea0f308ed10f5edc0888ee2b893d4def678849b073b703cc678ac4'
  end

end
