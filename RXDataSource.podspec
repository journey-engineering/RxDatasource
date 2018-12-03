Pod::Spec.new do |s|
  s.name = 'RxDataSource'
  s.version = '0.1'
  s.summary = 'A Swift framework that helps to deal with sectioned collections of collection items in an MVVM fashion. With RxSwift'
  s.homepage = 'https://github.com/thib4ult/RxDataSource'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.authors = 'Vadim Yelagin, Thibault Gauche'
  s.ios.deployment_target = '10.0'
  s.source = { :git => 'https://github.com/thib4ult/RxDataSource.git', :tag => s.version }
  s.source_files = 'RxDataSource/**/*.swift'
  s.dependency 'RxSwift', '~> 4.4.0'
end