#
# Be sure to run `pod lib lint MZTimePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MZTimePicker'
  s.version          = '0.1.0'
  s.summary          = 'A flexible time picker for iOS written in Swift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A flexible time picker for iOS written in Swift.
                       DESC

  s.homepage         = 'https://github.com/mineschan/MZTimePicker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mineschan' => 'mineschan@gmail.com' }
  s.source           = { :git => 'https://github.com/mineschan/MZTimePicker.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.2'

  s.source_files = 'MZTimePicker/Classes/**/*'
end
