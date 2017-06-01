# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'Li5SDK' do
    pod 'CocoaLumberjack'
    pod 'Li5Api', :path => '../api'
    pod 'GCDWebServer', :git => 'https://github.com/lifive/GCDWebServer.git', :branch => 'master'
    pod 'BCVideoPlayer', :path => '../player'
    pod 'SDWebImage', '~>3.7'
    pod 'Masonry'
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
    pod 'FXBlurView'
    pod 'YYImage'
    pod 'YYImage/WebP'
    pod 'Applanga'
    pod 'SnapKit', '0.22.0'
    
    pod 'Fabric'
    pod 'Crashlytics'
end

target 'DemoSDK' do
    
end

# post install
post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
