Pod::Spec.new do |s|
  s.name             = 'TinderSwipeView'
  s.version          = '0.2.0'
  s.summary          = 'Swipe view inspired by tinder'

  s.description      = <<-DESC
Inspired animation from Tinder and Potluck with random undo feature!
                       DESC

  s.homepage         = 'https://github.com/nickypatson/TinderSwipeView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nickypatson' => 'mail.nickypatson@gmail.com' }
  s.source           = { :git => 'https://github.com/nickypatson/TinderSwipeView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.source_files = 'TinderSwipeView/Classes/**/*'


end
