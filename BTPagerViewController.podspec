Pod::Spec.new do |s|
  s.name         = "BTPagerViewController"
  s.version      = "1.0.3"
  s.summary      = "BTPagerViewController is an easy to customize Pager View Controller"
  s.homepage     = "https://github.com/BrodJP/BTPagerViewController"
  s.license      = "MIT"
  s.author       = { "BrodJP" => "bjhp1990@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/BrodJP/BTPagerViewController.git", :tag => "1.0.3" }
  s.source_files = "Content Tabs Slide/PodFiles/*.swift"
  s.resources    = "Content Tabs Slide/PodFiles/*.{png,bundle,xib,nib,storyboard}"
  s.requires_arc = true
  s.swift_version = "4.0"
end