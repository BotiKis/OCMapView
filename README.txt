* * * * * 
OCMapView is a simple and easy to use extension of the MKMapView for iOS.
If you have trouble to display a lot of annotations on the map, this class is for you.
It is written in Objective-C and C and works in all iOS applications.

The sample project is generated with Xcode 4.1 and written for iOS +4.0.

* * * * * 
Set up:
OCMapView automatically handles annotations and combines them to clusters for you. Just add the OCMapView folder to your project and you are good to go. Set the class of the MapView in the Interface Builder/Storyboard from MKMapView to OCMapView or create it manually in code like the MKMapView. Don't forget to link the MapKit and CoreLocation frameworks to your project and import OCMapView.h in the viewController you are working on.

* * * * * 
Usage:
Use it just like a normal MKMapView by adding the annotations you want to display and implement the usual MKMapViewDelegate methods. The viewForAnnotation delegate method will return OCAnnotation objects which represent clusters and contains all corresponding annotations in it. You can customize the behavior of the clusters by setting specific attributes. For more information take a look at the sample project or the documentation.

* * * * * 
OCMapView provides:
- Fast and easy to use class to handle over 9000 annotations on the map at once.
- Very simple installation and usage like the standard MKMapView.
- 2 different clustering algorithms. (Yet. More to come!)
- Algorithm help functions are written in C to maximize performance.
- Customize behavior like cluster size.
- Manage clusters yourself by providing an ignore list of annotations.