#
# Be sure to run `pod lib lint FRSwitch.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FRSwitch'
  s.version          = '0.1.1'
  s.summary          = 'Highly customizable UISwitch replacement'

  s.description      = <<-DESC
UISwitch is great, but unfortunately, it is hard to customize it. This control is created as a replacement with more possiblities to customize every detail of the switch. Developers will not have to think of the ways how to make the control with every new UI design :)
                       DESC

  s.homepage         = 'https://github.com/johnny12000/FRSwitch'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'johnny12000' => 'ristic.nikola@icloud.com' }
  s.source           = { :git => 'https://github.com/johnny12000/FRSwitch.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'FRSwitch/Classes/**/*'

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
