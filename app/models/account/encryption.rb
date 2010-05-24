module Account::Encryption
  def self.included(base)
    base.class_eval do
      attr_encrypted :email, :key => '1710d78515ea0f308ed10f5edc0888ee2b893d4def678849b073b703cc678ac4'
      attr_encrypted :name, :key => '1710d78515ea0f308ed10f5edc0888ee2b893d4def678849b073b703cc678ac4'
      attr_encrypted :born_on_string, '1710d78515ea0f308ed10f5edc0888ee2b893d4def678849b073b703cc678ac4'
      attr_encrypted :gender, :key => '1710d78515ea0f308ed10f5edc0888ee2b893d4def678849b073b703cc678ac4'
    end
  end
end
