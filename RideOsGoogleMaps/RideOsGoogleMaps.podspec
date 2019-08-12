Pod::Spec.new do |s|
  s.name             = 'RideOsGoogleMaps'
  s.version          = '0.1.0'
  s.summary          = 'Implementation of RideOS''s maps abstractions that uses Google Maps and Places'

  s.description      = <<-DESC
  Implementation of RideOS's maps abstractions that uses Google Maps
                       DESC

  s.homepage         = 'https://github.com/rideOS/rideos-sdk-ios'
  s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author           = { 'rideOS' => 'support@rideos.ai' }
  s.source           = { :git => 'git@github.com:rideOS/rideos-sdk-ios.git', :tag => '0.1.0' }

  s.ios.deployment_target = '11.0'
  
  # Note: this Pod must be built as a static framework because some of its dependencies (GoogleMaps and GooglePlaces)
  # are also static frameworks
  s.static_framework = true
  
  s.dependency 'RideOsCommon'
  s.dependency 'RxSwift', '~> 4.4'
  s.dependency 'GoogleMaps', '~> 3.2'
  s.dependency 'GooglePlaces', '~> 3.2'
  
  s.source_files = 'RideOsGoogleMaps/**/*.{swift, h, m}'
  
  # This is needed by all pods that depend on Protobuf:
  s.pod_target_xcconfig = {
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
  }  
end
