## What is OCMapView?
**OpenClusterMapView** is a simple and easy to use extension of `MKMapView` for iOS. If you are displaying a lot of annotations on the map, this class is made for you.

OCMapView automatically creates clusters by combining annotations super fast.
It works with any iOS application.

## Screenshots:
![Screenshots](screenshots.jpg "Screenshots")

## Background:
You may already have encountered the problem: When adding a several hundred annotations to the `MKMapView`, it will get laggy and everything but user friendly.

Many developers believe that iOS can't handle a huge amount of annotations on a `MKMapView` due to the low memory capacities of iDevices. So they start to handle the annotation management themselves with pretty dumb filter methods which won't display all annotations and confuse users even more.  

The actual problem is not memory related. It rather occurs because *annotationViews* are `UIViews` and these are extremely slow. So if you scroll/zoom a `MKMapView` with many annotations, iOS has to redraw them all at once and that will take time.  

**OCMapView** combines multiple annotations in a specified range and displays them just as ***a single*** `annotationView` for the whole cluster. So you'll never have too many views which make your app slow and laggy. In addition to that forget to handle the annotations yourself! Just add them **all** to your **OCMapView** and it will do everything for you.
Even the iPhone 3G with iOS 3.1.x can handle a couple thousand annotations without lagging!

## Setup
**OCMapView** automatically handles annotations and combines them to **clusters** for you. Just add the **OCMapView** folder to your project and you are good to go. Set the class of your `MapView` in the Interface Builder/Storyboard from **MKMapView** to **OCMapView** or create it manually in code like a regular `MKMapView`. Don't forget to link the `MapKit` and `CoreLocation` frameworks to your project and import `OCMapView.h` into the viewController you are working on.  

The sample project is generated with *Xcode 4.1* and written for *iOS +4.0*.

## Usage
Use it just like a regular `MKMapView` by adding the annotations you want to display and implement the usual `MKMapViewDelegate` methods.  

The `MKAnnotationView` handling stays completely the same so you can use custom Views for your annotations and clusters. The `viewForAnnotation` delegate method will return `OCAnnotation` objects when it generates clusters. So you can provide your custom view:  


    - (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation{  
        // if it's a cluster  
        if ([annotation isKindOfClass:[OCAnnotation class]]) {  
            // create your custom cluster annotationView here!  
        }  
        // If it's a single annotation  
        else if([annotation isKindOfClass:[Your_Annotation class]]){  
            // create your custom annotationView  as regular here!  
        }  
        return Your_annotationView;  
    }

You can customize the behavior of the clusters by setting specific attributes. For more information take a look at the sample project or the [documentation](http://www.unet.univie.ac.at/~a0846794/OCMapView/ "OpenClusterMapView Documentation").

## Grouping

You can cluster different groups of annotations, as seen on the screenshots above, like this:

Implement the `OCGrouping` protocol on your annotation class, set its grouping-tag and set the `clusterByGroupTag` property of your `OCMapView` to `true`. Take a look at the sample project to see how it works.

## OCMapView provides
- Fast and easy to use class to handle **over 9000** annotations on the map at once.
- Very simple installation and usage like the standard `MKMapView`.
- Easy to upgrade! You can keep all of your `MKMapView` delegate methods as they are.
- Customize the `MKAnnotationViews` of generated clusters as of a regular `MKAnnotation`.
- 2 different clustering algorithms.
- Algorithm help functions are written in C to maximize performance.
- Customize behavior like cluster size.
- Manage clusters yourself by providing an ignore list of annotations.
- *NEW*: Create independent clusters by using groups.

## Contribute
Apps that use OCMapView:
- official Car2Go App
- cost control for Car2Go aka. aCar2Go
- AbHof
- and a lot of more who do not tell me ;)

If you are using OCMapView and want to contribute, please contact me to add your app to the list of supporting apps!

![OpenClusterMapView Logo](OClusterMapView+Sample/Images/Logo/ocmapview_logo@2x.png "OpenClusterMapView Logo")