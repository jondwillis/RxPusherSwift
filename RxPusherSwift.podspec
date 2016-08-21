#
# Be sure to run `pod lib lint RxPusherSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RxPusherSwift'
  s.version          = '0.1.0'
  s.summary          = 'Rx wrapper for PusherSwift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/jondwillis/RxPusherSwift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jon Willis' => 'jondwillis@gmail.com' }
  s.source           = { :git => 'https://github.com/jondwillis/RxPusherSwift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/jonjondwillis'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'


  s.source_files = 'RxPusherSwift/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RxPusherSwift' => ['RxPusherSwift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'PusherSwift', '~> 2.0'
  s.dependency 'RxSwift', '~> 2.6'
  s.dependency 'RxCocoa', '~> 2.6'
end
