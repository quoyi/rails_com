# frozen_string_literal: true

module RailsCom::Application
  LOCALE_MAP = {
    'zh-CN' => 'zh',
    'zh-TW' => 'zh',
    'en-US' => 'en'
  }.freeze

  extend ActiveSupport::Concern

  included do
    before_action :set_locale, :set_timezone, :set_variant
    helper_method :current_title
  end

  def current_title
    t('.title', default: :site_name)
  end

  def set_variant
    request.variant = []
    request.variant << :phone if request.user_agent =~ /iPad|iPhone|iPod|Android/
    request.variant << :wechat if request.user_agent =~ /MicroMessenger/

    logger.debug "  ==========> Variant: #{request.variant}"
  end

  def set_timezone
    if session[:zone]
      Time.zone = session[:zone]
    elsif request.headers['HTTP_UTC_OFFSET'].present?
      zone = -(request.headers['HTTP_UTC_OFFSET'].to_i / 60)
      Time.zone = zone
      session[:zone] = zone
    end

    current_user.update timezone: Time.zone.name if current_user && current_user.timezone.blank?
    logger.debug "  ==========> Zone: #{Time.zone}"
  end

  # 设置语言
  def set_locale
    locale = available_locales.include?(I18n.default_locale.to_s) ? I18n.default_locale : available_locales[-1]
    session[:locale] = I18n.locale = [params[:locale], session[:locale], locale].compact[0]

    current_user.update(locale: I18n.locale) if current_user && current_user.locale.to_s != I18n.locale.to_s

    logger.debug "  ==========> Locale: #{I18n.locale}"
  end

  # 可用语言
  def available_locales
    # Accept-Language: "en,zh-CN;q=0.9,zh;q=0.8,en-US;q=0.7,zh-TW;q=0.6"
    request_locales = request.headers['Accept-Language'].to_s.split(',').map! { |l| l.split(';')[0] }
    I18n.available_locales.map(&:to_s) & LOCALE_MAP.select { |key| request_locales.include?(key) }.values.uniq
  end

  def set_country
    session[:country] = params[:country] || current_user.try(:country)

    logger.debug "  ==========> Country: #{session[:country]}"
  end

  def set_flash
    if response.successful?
      flash[:notice] = '操作成功！'
    elsif response.client_error?
      flash[:alert] = '请检查参数！'
    end
  end

  def default_params
    {}
  end

  def default_form_params
    {}
  end

  def json_format?
    request.format.json?
  end

  # after_action :process_js
  def process_js
    return unless request.xhr?

    response.body = Babel.transform(response.body)
  end
end
