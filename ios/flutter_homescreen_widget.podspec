Pod::Spec.new do |s|
  s.name             = 'flutter_homescreen_widget'
  s.version          = '0.1.1'
  s.summary          = 'Update iOS WidgetKit home screen widgets using Flutter widgets as the UI.'
  s.description      = <<-DESC
    flutter_homescreen_widget lets you render any Flutter widget tree to a PNG and push
    it to an iOS WidgetKit home screen widget. Define tappable action areas and
    receive callbacks in Dart — no Swift required from the host app.
  DESC
  s.homepage         = 'https://github.com/leejia324/flutter_homescreen_widget'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'leejia' => 'leejia0324@dsm.hs.kr' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency         'Flutter'
  s.platform           = :ios, '14.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.9'
end
