#
# Be sure to run `pod lib lint BYHttpTool.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BYHttpTool'
  s.version          = '0.0.1'
  s.summary          = '一款基于Alamofire-4.9.1，和codeable封装的网络请求库BYHttpTool.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: 一款基于Alamofire-4.9.1，和codeable封装的网络请求库BYHttpTool,只有get和post请求，后续还会更近.
                       DESC

  s.homepage         = 'https://github.com/byshenliuan/BYHttpTool.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'baoyuanshen' => '779822644@qq.com' }
  s.source           = { :git => 'https://github.com/byshenliuan/BYHttpTool.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'BYHttpTool/Classes/**/*'
  
  # s.resource_bundles = {
  #   'BYHttpTool' => ['BYHttpTool/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Alamofire', "~> 4.9.1"
end
