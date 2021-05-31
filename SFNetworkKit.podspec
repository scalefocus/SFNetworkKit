#
# Be sure to run `pod lib lint NetworkKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SFNetworkKit'
  s.version          = '1.0.0'
  s.summary          = 'SFNetworkKit: Core networking and API functionality for Scalefocus iOS apps.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  SFNetworkKit is a library that includes, networking and API functionality for Scalefocus iOS projects.
                       DESC

  s.homepage         = 'https://github.com/scalefocus/SFNetworkKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ASPetrov' => 'aleksandar.spetrov@scalefocus.com' }
  s.source           = { :git => 'https://github.com/scalefocus/SFNetworkKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'SFNetworkKit/Classes/**/*'
  
  s.dependency "Alamofire", "~> 5.2.0"

  s.swift_versions = ['5.1', '5.2']
end
