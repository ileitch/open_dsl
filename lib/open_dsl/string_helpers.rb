module OpenDsl
  module StringHelpers
    def constant_or_constant_name?(str_or_class)
      return true if str_or_class.is_a?(Class)
      !!(str_or_class.to_s =~ /^[A-Z]/)
    end

    def attribute_name(const_name)
      const_name.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end

    def plural?(str)
      !!(str.to_s =~ /s$/)
    end
  end
end
