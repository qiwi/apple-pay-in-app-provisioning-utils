Pod::Spec.new do |s|
  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.name = 'InAppProvisioningUtils'
  s.summary = 'Helpers for beautiful life :)'
  s.requires_arc = true
  s.version = '1.0.1'
  s.license = { :type => 'BSD' }
  s.author   = { 'QIWI' => 's.petruk@qiwi.com' }
  s.homepage = 'https://github.qiwi.com/client-dev-ios'
  s.source = { :git => 'git@github.qiwi.com:client-dev-ios/InAppProvisioningUtils.git'}

  s.framework = "PassKit"
  s.source_files = 'InAppProvisioningUtils/Classes/*'
end
