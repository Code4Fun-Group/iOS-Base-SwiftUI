Pod::Spec.new do |spec|
  spec.name         = "Common"
  spec.version      = "1.0"
  spec.summary      = "Common Framework"
  spec.description  = <<-DESC
	Common	
DESC

  spec.homepage     = "https://www.code4fun.group"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { "Code4Fun" => "namnh.code4fun@gmail.com" }
  spec.ios.deployment_target = "13.0"

  spec.source       = { :git => "https://github.com/Code4Fun-Group/Common.git", :tag => spec.version.to_s }
  spec.source_files = 'Common/**/*.{swift,h}'
	
	spec.dependency 'KeychainAccess'
end
