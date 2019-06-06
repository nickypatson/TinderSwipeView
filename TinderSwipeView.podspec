Pod::Spec.new do |s|
  s.name             = 'TinderSwipeView'
  s.version          = '1.1.8'
  s.summary          = 'Swipe view inspired from tinder'

  s.description      = <<-DESC
        Inspired animation from Tinder and Potluck with random undo feature!
                       DESC

  s.homepage         = 'https://github.com/nickypatson/TinderSwipeView'
  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
LICENSE
}


  s.author           = { 'nickypatson' => 'mail.nickypatson@gmail.com' }
  s.source           = { :git => 'https://github.com/nickypatson/TinderSwipeView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'
  s.source_files = 'TinderSwipeView/Classes/**/*'
  s.resource_bundles = {
    'TinderSwipeView' => ['TinderSwipeView/Resources/*']
    }

  s.resources = 'TinderSwipeView/Resources/**/*.{png,storyboard}'


end
