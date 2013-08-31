platform :ios, '6.0'
pod 'SIAlertView'
pod 'MMDrawerController'
pod 'RETableViewManager'
pod 'AFNetworking'
pod 'Facebook-iOS-SDK'
pod 'google-plus-ios-sdk'
pod 'SVProgressHUD'
pod 'NewRelicAgent'
pod 'TSMiniWebBrowser'
Pod::Spec.new do |s|
  s.name         =  'Facebook-iOS-SDK'
  s.version      =  '3.6.0'
  s.platform     =  :ios
  s.license      =  'Apache License, Version 2.0'
  s.summary      =  'The iOS SDK provides Facebook Platform support for iOS apps.'
  s.description  =  'The Facebook SDK for iOS enables you to access the Facebook Platform APIs including the Graph API, FQL, and Dialogs.'
  s.homepage     =  'http://developers.facebook.com/docs/reference/iossdk'
  s.author       =  'Facebook'
  s.source       =  { :git => 'https://github.com/facebook/facebook-ios-sdk.git', :tag => 'sdk-version-3.6.0' }
  s.source_files =  'src/*.{h,m}', 'src/Base64/*.{h,m}', 'src/Cryptography/*.{h,m}'
  s.resources    =  'src/FacebookSDKResources.bundle', 'src/FBUserSettingsViewResources.bundle'
  s.header_dir   =  'FacebookSDK'
  s.framework = 'CoreLocation'
  # simulate the build rule that converts PNG files to objective-c classes in 3.6.0
  s.pre_install do |pod, target_definition|
    Dir.chdir(pod.root){ `find src -name \\*.png | grep -v @ | grep -v -- - | sed -e 's|\\(.*\\)/\\([a-zA-Z0-9]*\\).png|python scripts/image_to_code.py -i \\1/\\2.png -c \\2 -o src|' | sh` }
  end
end
Pod::Spec.new do |s|
  s.name          = "google-plus-ios-sdk"
  s.version       = "1.3.0"
  s.summary       = "Google+ Platform for iOS."
  s.description   = "Create a more engaging experience and connect with more users by integrating social into your app. Extend your app in new and creative ways using these Google+ platform features."
  s.homepage      = "https://developers.google.com/+/mobile/ios/getting-started"
  s.license       = {
    :type => 'Copyright',
    :text => 'Copyright 2013 Google Inc.'
  }
  s.author         = 'Google Inc.'
  s.source         = { :http => "https://developers.google.com/+/mobile/ios/sdk/google-plus-ios-sdk-1.3.0.zip" }
  s.platform       = :ios
  s.public_header_files = 'google-plus-ios-sdk-1.3.0/GoogleOpenSource.framework/Headers/GoogleOpenSource.h', 'google-plus-ios-sdk-1.3.0/GooglePlus.framework/Headers/GooglePlus.h'
  s.preserve_paths = 'google-plus-ios-sdk-1.3.0/GoogleOpenSource.framework', 'google-plus-ios-sdk-1.3.0/GooglePlus.framework'
  s.resource       = 'google-plus-ios-sdk-1.3.0/GooglePlus.bundle'
  s.framework      = 'Security', 'SystemConfiguration', 'GoogleOpenSource', 'GooglePlus'
  s.xcconfig       =  { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/google-plus-ios-sdk/google-plus-ios-sdk-1.3.0"' }
end
Pod::Spec.new do |s|
  s.name         		= 'NewRelicAgent'
  s.version      		= '1.354'
  s.platform     		= :ios, '5.0'
  s.license      		= { :type => "Commercial", :file => "NewRelic_iOS_Agent_#{s.version}/LICENSE" }
  s.summary      		= "Real-time performance data with your next iOS app release."
  s.homepage     		= "http://newrelic.com/mobile-monitoring"  
  s.authors      		= {'New Relic, Inc.' => 'support@newrelic.com'}
  s.source       		= { :http => "https://download.newrelic.com/ios_agent/NewRelic_iOS_Agent_#{s.version}.zip" }
  s.framework    		= 'SystemConfiguration', 'CoreTelephony'
  s.library      		= 'z'
  s.preserve_paths      = "NewRelic_iOS_Agent_#{s.version}/*.framework"  
  s.public_header_files = "NewRelic_iOS_Agent_#{s.version}/NewRelicAgent.framework/**/*.h"
  s.vendored_frameworks = "NewRelic_iOS_Agent_#{s.version}/NewRelicAgent.framework"
  s.documentation 		= { :appledoc => ['--company-id', 'com.newrelic'] }
end