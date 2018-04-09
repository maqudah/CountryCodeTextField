

Pod::Spec.new do |s|
  s.name             = 'CountryCodeTextField'
  s.version          = '1.0.0'
  s.summary          = 'CountryCodeTextField is a Subclass Of UITextField Allow User To Select his Country Code.'
  s.description      = <<-DESC
TODO: CountryCodeTextField is a Subclass Of UITextField Allow User To Select his Country Code. Selection From PickerView or TableView or Costume DataSource. Or Type it Via Keyboard. 
                       DESC
    
  s.homepage         = 'https://github.com/maqudah/CountryCodeTextField'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mustafa Alqudah' => 'maqudah@ymail.com' }
  s.source           = { :git => 'https://github.com/maqudah/CountryCodeTextField.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/maqudah'
  
  s.ios.deployment_target = '10.0'
  
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }

  s.source_files = 'Classes/**/*'
  
  s.resource_bundles = {
    'CountryCodeTextField' => ['Assets/Settings.bundle']
  }

end
