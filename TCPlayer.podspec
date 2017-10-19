Pod::Spec.new do |s|
  s.name         = "TCPlayer"
  s.version      = "1.0.2"
  s.summary      = "ctc's video player."
  s.description  = <<-DESC
  A player based on AVPlayer.
                   DESC

  s.homepage     = "https://github.com/ctc1991/TCPlayer"
  s.license      = "MIT"
  s.author       = { "ctc" => "ctc1991@foxmail.com" }
  s.platform     = :ios
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/ctc1991/TCPlayer.git", :tag => s.version.to_s} 
  s.source_files = 'TCPlayer/**/*'
  s.framework = "Foundation","UIKit","MediaPlayer","AVFoundation"
  s.requires_arc = true
end