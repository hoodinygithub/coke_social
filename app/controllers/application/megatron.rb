module Application::Megatron
  def self.included(base)
    base.class_eval do
      def self.is_megatron?(user_agent)
        user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i
      end
    end
  end
end
