# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'gps4camera' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for gps4camera

  def common_pods
    pod 'PluggableAppDelegate'
    pod 'Swinject'
    pod 'ReactiveKit'
    pod 'Bond'
    pod 'FontAwesome.swift'
    pod 'InAppSettingsKit'
  end

  common_pods

  target 'gps4cameraTests' do
    inherit! :search_paths

  end

  target 'gps4cameraUITests' do
    inherit! :search_paths
    
    common_pods
  end

end
