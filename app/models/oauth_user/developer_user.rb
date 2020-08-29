unless defined? DeveloperUser
  class DeveloperUser < OauthUser
    include RailsCom::OauthUser::DeveloperUser
  end
end
