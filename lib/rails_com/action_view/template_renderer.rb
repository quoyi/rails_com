# frozen_string_literal: true

module RailsCom
  module TemplateRenderer
    def render(context, options)
      return super if defined?(WebConsole) && context.is_a?(WebConsole::View)

      request = context.request
      request_formats = if request&.format&.symbol
                          [context.request.format.symbol]
                        else
                          @lookup_context.formats[0..0].presence || [:html]
                        end

      # TODO: better implement
      @lookup_context.send :_set_detail, :formats, request_formats

      # 支持在views/:controller 目录下，用 _action 开头的子目录进一步分组，会优先查找该目录下文件
      context_prefix = @lookup_context.prefixes[0]
      action = (request&.params || {})['action']
      if context_prefix && context_prefix.split('/')[-1].start_with?('_') && action
        @lookup_context.prefixes[0] = [@lookup_context.prefixes[1], "_#{action}"].join('/')
      elsif context_prefix && action
        @lookup_context.prefixes.prepend [context_prefix, "_#{action}"].join('/')
      end

      context.instance_variable_set(:@_rendered_template, options[:template])
      super
    end
  end
end

ActiveSupport.on_load :action_view do
  ActionView::TemplateRenderer.prepend RailsCom::TemplateRenderer
end
