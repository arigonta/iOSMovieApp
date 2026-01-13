# Podfile for iOSMovieApp
# https://guides.cocoapods.org/using/using-cocoapods.html

platform :ios, '15.0'

target 'iOSMovieApp' do
  use_frameworks!

  # Image loading and caching
  pod 'Kingfisher', '~> 7.0'
  
  # Network debugging (shake to open)
  pod 'netfox'

end

target 'iOSMovieAppTests' do
  inherit! :search_paths
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
  
  # Fix for Xcode 15+ sandbox issues
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      end
    end
  end
end
