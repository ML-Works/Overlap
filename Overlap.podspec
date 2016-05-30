Pod::Spec.new do |s|
  s.name             = "Overlap"
  s.version          = "0.1.2"
  s.summary          = "Tiny iOS library to achieve overlap visual effect"

  s.description      = <<-DESC
                       Allows you to overlay any possible UI elements like UILabels,
                       UIButtons and even UIToolbars. Just create 2 views or both states
                       and update overlap region from scrollViewDidScroll or panGestureHandler
                       DESC

  s.homepage         = "https://github.com/ML-Works/Overlap"
  s.license          = 'MIT'
  s.author           = { "Anton Bukov" => "k06a@mlworks.com" }
  s.source           = { :git => "https://github.com/ML-Works/Overlap.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/k06a'

  s.ios.deployment_target = '7.0'

  s.source_files = 'Overlap/Classes/**/*'

  s.frameworks = 'UIKit'
end
