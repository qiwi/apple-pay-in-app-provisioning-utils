Pod::Spec.new do |s|
  s.platform = :ios
  s.ios.deployment_target = '10.3'
  s.name = 'InAppProvisioningUtils'
  s.summary = 'Helpers for Apple Pay In-app Provisioning + button logic (Add card to apple pay)'
  s.requires_arc = true
  s.version = '1.0'
  s.license = { :type => 'MIT' }
  s.author   = { 'QIWI' => 's.petruk@qiwi.com' }
  s.homepage = 'https://github.com/qiwi'
  s.source = { :git => 'https://github.com/qiwi/apple-pay-in-app-provisioning-utils' }
  s.framework = "PassKit"
  s.source_files = 'InAppProvisioningUtils/Classes/*'
end
