# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'Li5SDK' do
    pod 'CocoaLumberjack'
    pod 'Li5Api', :path => '../api'
    pod 'BCVideoPlayer', :path => '../player'
    
    pod 'GCDWebServer', '~> 3.2.5'
    pod 'SDWebImage', '~>3.7'
    pod 'Masonry'
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git' #can be eliminated
    pod 'FXBlurView'
    pod 'YYImage'
    pod 'YYImage/WebP'
    pod 'SnapKit', '3.0.0'
    
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
        end
    end
end
