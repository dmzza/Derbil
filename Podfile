
use_frameworks!

def shared_pods
  # Couldn't make Timepiece work as a cocoapod yet: https://github.com/naoty/Timepiece/pull/33#issuecomment-136288365
  # pod 'Timepiece', :git => 'https://github.com/dmzza/Timepiece/', :branch => 'patch-1'
end

target 'Derbil' do
  platform :ios, '9.0'
  shared_pods
end

target 'DerbilTests' do

end

target 'DerbilUITests' do
  platform :ios, '9.0'
end

target 'Derbil WatchKit App' do
  platform :watchos, '2.0'
  shared_pods
end

target 'Derbil WatchKit Extension' do
  platform :watchos, '2.0'
  shared_pods
end
