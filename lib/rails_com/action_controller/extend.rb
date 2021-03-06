module RailsCom::ActionController
  module Extend
    # if whether_filter(:require_login)
    #   skip_before_action :require_login
    # end
    def whether_filter(filter)
      get_callbacks(:process_action).map(&:filter).include?(filter.to_sym)
    end

    def raw_view_paths
      view_paths.paths.map(&:path)
    end
  end
end

ActiveSupport.on_load :action_controller do
  extend RailsCom::ActionController::Extend
end
