source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
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
  pod 'Eureka', '~> 2.0.0-beta.1' #, :git => 'https://github.com/xmartlabs/Eureka.git', :branch => 'swift3.1'
  pod 'JKNotificationPanel'
  pod 'FontAwesome.swift'
  pod 'TTRangeSlider'
  pod 'DateToolsSwift', :git => 'https://github.com/MatthewYork/DateTools.git'
  pod 'ionicons'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
