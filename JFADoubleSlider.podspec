Pod::Spec.new do |s|
  s.name             = "JFADoubleSlider"
  s.version          = "1.0.0"
  s.summary          = "A custom control, inspired by UISlider, for selecting a range of values."
  s.homepage         = "https://github.com/vermont42/JFADoubleSlider"
  s.license          = "MIT"
  s.author           = "Josh Adams"
  s.source           = { :git => "https://github.com/vermont42/JFADoubleSlider.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/vermont42"
  s.source_files     = "JFADoubleSlider/JFADoubleSlider.h", "JFADoubleSlider/JFADoubleSlider.m"
  s.platform         = :ios, "8.0"
  s.requires_arc     = true
end
