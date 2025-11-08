# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'QuickNextBox' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for QuickNextBox
  pod 'AFNetworking', '~> 4.0'
  pod 'SVProgressHUD'
  pod 'Masonry'
  pod 'GDataXMLNode2'
  
  
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
        # 可选：禁用 libarclite 相关警告
        config.build_settings['CLANG_ENABLE_OBJC_ARC_WEAK'] = 'NO'
      end
    end
  end
  
end
