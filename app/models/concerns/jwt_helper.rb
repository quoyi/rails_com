require 'jwt'

module JwtHelper
  extend self

  # 模型需要定义属性
  # iss(issuer) 比如鉴权唯一标识 id,  AppID
  # key 比如 password_digest, AppSecret
  # sub: 'User'
  # column: 'password_digest'
  # exp: auth_token_expire_at, should be int
  # algorithm: 默认HS256
  def generate_jwt_token(iss, key, options = {})
    payload = {
      iss: iss
    }

    payload.merge! options

    JWT.encode(payload, key.to_s)
  end

  def decode_without_verification(token)
    payload, = JWT.decode(token, nil, false, verify_expiration: false)
    payload
  rescue StandardError => e
    puts nil, e.full_message(highlight: true, order: :top)
  end
end
