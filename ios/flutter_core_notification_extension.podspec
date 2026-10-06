#
# CoreCloudNotification Notification Service Extension pod'u. Flutter'a bağımlı değildir; uygulamanın
# Podfile'ında extension target'ına eklenir:
#
#   target 'NotificationServiceExtension' do
#     use_frameworks!
#     pod 'flutter_core_notification_extension', :path => '.symlinks/plugins/flutter_core/ios'
#   end
#
Pod::Spec.new do |s|
  s.name             = 'flutter_core_notification_extension'
  s.version          = '1.0.0'
  s.summary          = 'CoreCloudNotification Notification Service Extension'
  s.description      = 'Uygulama kapaliyken received event, bildirim gorseli.'
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ozveri Mobile' => 'mobile@ozdilek.com.tr' }
  s.source           = { :path => '.' }
  s.source_files     = 'CloudNotificationShared/**/*.swift', 'CloudNotificationExtension/**/*.swift'
  s.platform         = :ios, '12.0'
  s.swift_version    = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }
end
