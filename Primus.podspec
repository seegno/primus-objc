Pod::Spec.new do |s|
  s.name                  = "Primus"
  s.version               = "0.0.1"
  s.summary               = "Primus is a simple abstraction around real-time frameworks. It allows you to easily switch between different frameworks without any code changes."
  s.homepage              = "https://github.com/seegno/primus-objc"
  s.author                = "Nuno Sousa"
  s.license               = { :type => 'MIT', :file => 'LICENSE'}
  s.source                = { :git => 'https://github.com/seegno/primus-objc.git', :tag => "#{s.version}" }
  s.requires_arc          = true
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.7'
  s.default_subspec       = 'All'

  s.subspec 'All' do |ss|
    ss.dependency 'Primus/Core'
    ss.dependency 'Primus/Parsers'
    ss.dependency 'Primus/Transformers'
  end

  s.subspec 'Core' do |ss|
    ss.source_files = "Primus/*.{h,m}", "Primus/Core/**/*.{h,m}"

    ss.dependency 'BlocksKit/DynamicDelegate'
    ss.dependency 'Emitter'
    ss.dependency 'NSTimer-Blocks'
  end

  s.subspec 'Parsers' do |ss|
    ss.source_files = "Primus/Parsers/**/*.{h,m}"
  end

  s.subspec 'Transformers' do |ss|
    ss.source_files = "Primus/Transformers/**/*.{h,m}"
  end
end
