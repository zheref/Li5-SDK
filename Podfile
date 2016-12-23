# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

abstract_target 'Li5Base' do
  pod 'CocoaLumberjack'
  pod 'Li5Api', :path => '../li5-api-ios'
  pod 'GCDWebServer', :git => 'git@github.com:lifive/GCDWebServer.git', :branch => 'custom-dev'
  pod 'BCVideoPlayer', :path => '../BCPlayerView'
  pod 'SDWebImage', '~>3.7'
  pod 'Masonry'
  pod 'SMPageControl'
  pod 'TSMessages', :git => 'git@github.com:KrauseFx/TSMessages.git'
  pod "MMMaterialDesignSpinner"
  pod 'FXBlurView'
  pod 'Heap'
  pod 'pop', '~> 1.0'
  pod 'YYImage'
  pod 'YYImage/WebP'
  pod 'VMaskTextField'
  pod 'MBProgressHUD'
  pod 'Branch'
  pod 'Instabug'
  pod 'FBNotifications'
  
  target 'li5' do
    pod 'Fabric'
    pod 'Digits'
    pod 'TwitterCore'
    pod 'Crashlytics'
    pod 'CardIO'
    pod 'Stripe'
    pod 'Intercom'
    pod 'JSBadgeView'
  end
  
  target 'li5-Test' do
    pod 'Fabric'
    pod 'Digits'
    pod 'TwitterCore'
    pod 'Crashlytics'
    pod 'CardIO'
    pod 'Stripe'
    pod 'Intercom'
    pod 'JSBadgeView'
  end
  
  target 'li5Tests' do
  end
  
  target 'li5UITests' do
  end

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
