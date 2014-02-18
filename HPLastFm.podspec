Pod::Spec.new do |s|
  s.name     = 'HPLastFm'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = 'API LastFm'
  s.author   = { 'Herve Peroteau' => 'herve.peroteau@gmail.com' }
  s.description = 'LastFm API with blocks and JSON returns'
  s.platform = :ios
  s.source = { :git => "https://github.com/herveperoteau/HPLastFm.git"}
  s.source_files = 'HPLastFm'
  s.requires_arc = true
  s.dependency 'ISDiskCache'
end
