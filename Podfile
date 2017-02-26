source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'lfg' do
  pod 'Alamofire', '~> 4.3'
  pod 'ObjectMapper'
  pod 'AlamofireObjectMapper', '~> 4.0'
  pod 'SwiftLint'
  pod 'RealmSwift'
  pod 'PureLayout'
  pod 'ActionCableClient'
  pod 'SwiftyBeaver'
  pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka.git', :branch => 'master'
  pod 'SwiftMessages'
  pod 'FontAwesome.swift'
  pod 'TTRangeSlider'
  pod 'DateToolsSwift', :git => 'https://github.com/MatthewYork/DateTools.git'
  pod 'ionicons'
  pod 'SDWebImage', '~>3.8'
  pod 'Fakery'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
