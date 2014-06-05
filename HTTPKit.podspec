Pod::Spec.new do |s|
  s.name         = "HTTPKit"
  s.version      = "0.2.0"
  s.summary      = "Simple HTTP Library in swift"
  s.homepage     = "https://github.com/daltoniam/HTTPKit"
  s.license      = 'Apache License, Version 2.0'
  s.author       = { "Dalton Cherry" => "daltoniam@gmail.com" }
  s.source       = { :git => "https://github.com/daltoniam/HTTPKit.git", :tag => "#{s.version}" }
  s.social_media_url = 'http://twitter.com/daltoniam'
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.source_files = '*.{swift}'
  s.requires_arc = true
end
