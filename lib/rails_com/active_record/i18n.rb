module ActiveRecord::Type
  class I18n < Json
    def type
      :i18n
    end

    def deserialize(value)
      if super&.respond_to?(:[])
        super[::I18n.locale.to_s]
      else
        value
      end
    end
  end
end

ActiveRecord::Type.register(:i18n, ActiveRecord::Type::I18n)
