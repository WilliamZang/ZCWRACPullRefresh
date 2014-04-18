
Pod::Spec.new do |s|

  s.name         = "ZCWRACPullRefresh"
  s.version      = "0.1.1"
  s.summary      = "A pull refresh control with RAC"

  s.description  = <<-DESC
		   A pull refresh control with RAC
                   DESC

  s.homepage     = "https://github.com/WilliamZang/ZCWRACPullRefresh"


  s.license      = 'MIT'

  s.author             = { "zangcw" => "chengwei.zang.1985@gmail.com" }

  s.platform     = :ios, '6.0'

  s.source       = { :git => "https://github.com/WilliamZang/ZCWRACPullRefresh.git", :tag => "0.1.1" }

  s.source_files  = 'ZCWTableViewPullRefresh/*.{h,m}'

  s.requires_arc = true

  s.dependency 'ReactiveCocoa', '~> 2.3'

end
