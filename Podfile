# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'


def commonPods
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for a target
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Messaging'
  pod 'GoogleSignIn'
  pod 'FBSDKLoginKit'
  pod 'SwaggerClient', :path => 'SwaggerClient/'

end

target 'MaldikaBileto' do
  commonPods
end

target 'MaldikaBileto staging' do
  commonPods
  target 'MaldikaBiletoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MaldikaBiletoUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end


