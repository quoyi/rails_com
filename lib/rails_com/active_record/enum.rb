# frozen_string_literal: true

module RailsCom::ActiveRecord::Enum
  def options_i18n(attribute)
    h = I18n.t enum_key(attribute), default: {}
    h.compact!

    return h.invert if h.is_a?(Hash) && h.present?

    if h.blank?
      name = attribute.to_s.pluralize
      if respond_to?(name)
        enum_hash = public_send(name)
        h = enum_hash.keys.map { |i| [i.humanize, i] }.to_h
      end
    end

    h
  end

  def help_i18n(attribute)
    return nil if attribute.blank?

    help_key = RailsCom.config.help_key.call(self, attribute)
    I18n.t help_key, default: nil
  end

  def enum_i18n(attribute, value)
    h = I18n.t enum_key(attribute), default: {}
    h.compact!

    v = nil
    v = h[value] || h[value.to_s.to_sym] if h.is_a?(Hash)

    v = value.to_s if v.nil? && value.blank?

    v = human_attribute_name(value) if v.nil?

    v
  end

  def enum_key(attribute)
    RailsCom.config.enum_key.call(self, attribute)
  end

  def self.extended(mod)
    mod.attribute_method_suffix '_i18n'

    mod.class_exec do
      def attribute_i18n(attr)
        if %i[json jsonb].include? self.class.columns_hash[attr]&.type
          send(attr)&.transform_keys! { |key| self.class.human_attribute_name(key) }
        else
          self.class.enum_i18n attr, send(attr)
        end
      end
    end
  end
end

ActiveSupport.on_load :active_record do
  extend RailsCom::ActiveRecord::Enum
end
