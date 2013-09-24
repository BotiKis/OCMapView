Pod::Spec.new do |s|
  s.name         = 'OCMapView'
  s.version      = '1.1'
  s.platform     = :ios
  s.summary      = 'Simple, easy and fast class for clustering in MKMapViews.'
  s.homepage     = 'https://github.com/XBeg9/OCMapView'
  s.authors      = { 'Botond Kis' => 'boti.kis@gmx.at', 'Markus Emrich' => 'markus@nxtbgthng.com' }
  s.source       = { :git => 'https://github.com/XBeg9/OCMapView.git', :tag => "#{s.version}" }
  s.requires_arc = true
  s.source_files = 'OCMapView'
  s.frameworks   = 'MapKit', 'CoreLocation'
  s.license      = "LICENSE.txt"

  s.description  = 'OpenClusterMapView is a simple and easy to use extension of MKMapView for iOS. If ' \
                   'you are displaying a lot of annotations on the map, this class is made for you. ' \
                   'OCMapView automatically creates clusters by combining annotations super fast. It ' \
                   'works with any iOS application.'
end
