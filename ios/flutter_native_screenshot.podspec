#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_native_screenshot.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_native_screenshot'
  s.version          = '1.2.0'
  s.summary          = 'A Flutter plugin to take screenshots using native platform APIs.'
  s.description      = <<-DESC
A Flutter plugin to take screenshots on Android & iOS using native code.
Captures the current screen and saves it as a PNG file.
                       DESC
  s.homepage         = 'https://github.com/nusanet/flutter-native-screenshot'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Nusanet' => 'https://github.com/nusanet' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
