# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

abstract_target 'Li5Base' do
  pod 'CocoaLumberjack'
  pod 'Li5Api', :path => '../li5-api-ios'
  pod 'BCVideoPlayer', :path => '../BCPlayerView'
  pod 'SDWebImage', '~>3.7'
  pod 'Masonry'
  
  target 'li5' do
    pod 'Fabric'
    pod 'Crashlytics'
  end
  
  target 'li5-Dev' do
    pod 'Fabric'
    pod 'Crashlytics'
  end
  
  target 'li5-Test' do
    pod 'Fabric'
    pod 'Crashlytics'
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
        end
    end
end