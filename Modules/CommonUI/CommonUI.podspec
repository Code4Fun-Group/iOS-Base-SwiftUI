Pod::Spec.new do |spec|
  spec.name         = "CommonUI"
  spec.version      = "1.0"
  spec.summary      = "CommonUI Framework"
  spec.description  = <<-DESC
	Common	
DESC

  spec.homepage     = "https://www.code4fun.group"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { "Code4Fun" => "namnh.code4fun@gmail.com" }
  spec.ios.deployment_target = "13.0"

  spec.source       = { :git => "https://github.com/Code4Fun-Group/CommonUI.git", :tag => spec.version.to_s }
	spec.source_files = 'CommonUI/**/*.{swift,h}'
	spec.resource_bundles = {
		'CommonUI' => ['CommonUI/**/*.{xib,storyboard}']
	}
	
	spec.dependency 'Common'
	spec.dependency 'Kingfisher'
	spec.dependency 'FloatingPanel'
	spec.dependency 'IQKeyboardManagerSwift'
end
