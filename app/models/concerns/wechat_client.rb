module WechatClient
  extend self

  def oauth_client(scope = [])
    # FIXME: RailsCom.config.wechat_app
    @oauth_client ||= OmniAuth::Strategies::Wechat.new(nil, # App - nil seems to be ok?!
                                                       RailsCom.config.wechat_app.appid,
                                                       RailsCom.config.wechat_app.secret,
                                                       scope: scope)
  end

  def client
    @client ||= OAuth2::AccessToken.new(self.class.oauth_client, access_token)
  end
end
