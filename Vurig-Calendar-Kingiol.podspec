Pod::Spec.new do |s|
  s.name         = "Vurig-Calendar-Kingiol"
  s.version      = "1.0"
  s.summary      = "Easy to use, simple, clean calendar view, forked from Vurig-Calendar. kingiol"
  s.description  = <<-DESC
                   Easy to use, simple, clean calendar view, forked from Vurig-Calendar. kingiol
                   DESC
  s.homepage     = "https://github.com/kingiol/Vurig-Calendar"
  s.license      = 'MIT'
  s.author       = { "kingiol" => "kingxiaokang@gmail.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/kingiol/Vurig-Calendar.git", :tag => "1.0" }
  s.source_files  = 'VurigCalendarKingiol/Classes/*.{h,m}'
  s.requires_arc = true
end
