# frozen_string_literal: true

module QrcodeHelper
  extend self
  OPTIONS = {
    resize_gte_to: false,
    resize_exactly_to: false,
    fill: 'white',
    color: 'black',
    size: 300,
    border_modules: 1,  # 二维码图片padding
    module_px_size: 6,
    file: nil
  }.freeze

  def code_file(url, **options)
    png = code_png url, options
    tmp = Tempfile.new
    tmp.binmode
    tmp.write png.to_s
    tmp.rewind
    tmp
  end

  def code_png(url, **options)
    qrcode = RQRCode::QRCode.new(url)
    qrcode.as_png(**OPTIONS.merge(options))
  end
end
