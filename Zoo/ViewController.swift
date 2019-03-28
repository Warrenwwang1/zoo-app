//
//  ViewController.swift
//  MapandPin
//
//  Created by Kris on 6/28/17.
//  Copyright © 2017 Kris. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate
    {
    //let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var mapView: MKMapView!
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    var coordinatePins = [coordinatePin]()
    var currentPin:coordinatePin!
    //currentPin.name = "pin "+ coordinatePins.count]
    
    var locationManager:CLLocationManager!
    //var checkZoom: Bool = false;
    var currentZoom: Double = 61;
    var zoom: Double = 100;
    var zoomSlider: Double = 61
    var latitude: Double?
    var longitude: Double?
    var leave: Bool = false
    
    var currentLocation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //retrieve()
       // print("Found this many pins upon load: "+String(results.count))
        
    
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create and Add MapView to our main view
       // createMapView()
        //retrieve()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        determineCurrentLocation()
        retrieve()
    }
    
    @IBAction func clearPins(_ sender: Any) {
        // confirming the clear all pins
        let alertController = UIAlertController(title: "Confirm", message: "Are you sure you'd like to clear all your pins?", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            print("Cancel")
        }
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            
            // deletes all images and pin info from CoreData
            let moc = self.getContext()
            let fetchRequestPin = NSFetchRequest<NSFetchRequestResult>(entityName: "Coord")
            
            let resultPins = try? moc.fetch(fetchRequestPin)
            let resultDataPins = resultPins as! [Coord]
            
            for object in resultDataPins {
                
             //   print("Found a pin here at \(object.id), and deleted it")
                moc.delete(object)
                
            }
            
            let fetchRequestImage = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
            let resultImages = try? moc.fetch(fetchRequestImage)
            let resultDataImages = resultImages as! [Image]
            
            for object in resultDataImages {
                
               // print("Found an image here at \(object.id), and deleted it")
                moc.delete(object)
                
            }
            
            do {
                try moc.save()
                print("saved!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
            }
            
            // displays another alert saying it needs to reload map, segues to home page
            let alertController2 = UIAlertController(title: "Done", message: "All pins have been cleared. The map will now be updated.", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction2 = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                // leave is used in locationManager b/c this was being weird about the sender
                self.leave = true;
            }
            
            alertController2.addAction(okAction2)
            self.present(alertController2, animated: true, completion: nil)
        }
        
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
    
    //autopopulate so that pins come back
    func retrieve () {
        print("retrieve called")
        var lon: Double?
        var lat: Double?
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Coord", in: managedObjectContext)
        
        let request: NSFetchRequest<Coord> = Coord.fetchRequest()
        
        request.entity = entityDescription
        
        do {
            var results = try managedObjectContext.fetch(request as!
                NSFetchRequest<NSFetchRequestResult>)
            print(results)
            if results.count > 0 {
                var i = 0
                print("Found this many pins upon return: "+String(results.count))
                while (i <= results.count-1) {
                    let match = results[i] as! NSManagedObject
                    
                    lon = match.value(forKey: "long") as? Double
                    lat = match.value(forKey: "lat") as? Double
                    let annotation: MKPointAnnotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2DMake(lat!, lon!);
                  
                    annotation.title = match.value(forKey: "title") as? String
                    annotation.subtitle = match.value(forKey: "descrip") as? String
                    self.mapView.addAnnotation(annotation)
                    var x:coordinatePin = coordinatePin(name: annotation.title!, notes: annotation.subtitle!, pinID: (match.value(forKey: "pinid") as? String)!, new: false, longitude: lon!, latitude: lat!)
                    coordinatePins.append(x)
                    i+=1
                }
          }else {
                return
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    
    //determine users current location
    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
    }
    var userCurrentLocation:CLLocation?

    
    // manages location of map view
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if leave {
            print("inside if loop for leave")
            performSegue(withIdentifier: "reload", sender: self)
        }

        
        let userLocation:CLLocation = locations[0] as CLLocation
        
        self.mapView.showsUserLocation = true

        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude);//location of center (user)
        
        let centerCurrent = CLLocationCoordinate2D(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude); // current center
        
        //let center = CLLocationCoordinate2D(latitude: 1, longitude: 1);//location of center
        
        //zoom = Double("\(sliderValue.value)")! // does not work
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom))//zoom
        
        let regionCurrent = MKCoordinateRegion(center: centerCurrent, span: MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom))
        //print(zoom)
        
        if zoom != 1000000 {
            mapView.setRegion(regionCurrent, animated: true)
        }
        
        if currentLocation == true{
            
            mapView.setRegion(region, animated: true) //zooms in ot the current location with selected rectangle size
            
            currentLocation = false
            
        }else{
        }
        
        userCurrentLocation = userLocation
    }
    
    @IBAction func center(_ sender: Any) {
        currentLocation = true
    }
    
    
    //Drop a pin at user's Current Location
    @IBAction func pinButton(_ sender: Any) {
        
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userCurrentLocation!.coordinate.latitude, userCurrentLocation!.coordinate.longitude);
       
        var newPin = coordinatePin(name: "pin " + String(coordinatePins.count), notes: "notes", pinID: "00", new: true, longitude: 0, latitude: 0)
        myAnnotation.title = newPin.name
        myAnnotation.subtitle = newPin.notes
        mapView.addAnnotation(myAnnotation)
        
        latitude = userCurrentLocation!.coordinate.latitude
        longitude = userCurrentLocation!.coordinate.longitude
        newPin.pinID = String(describing: latitude!) + String(describing: longitude!)
        newPin.longitude = longitude!
        newPin.latitude = latitude!
        coordinatePins.append(newPin)

        print(newPin.pinID)
        print("this pin is new? " + String(newPin.new))
        

    }
//zoom level
    @IBAction func sliderValue(_ sender: UISlider) {
        zoomSlider = Double(sender.value)
        
        if(zoomSlider >= 0){
            if zoomSlider <= 1{
                zoom = 0.0001
            }
            else if zoomSlider <= 2{
                zoom = 0.01
            }
            else if zoomSlider <= 3{
                zoom = 0.1
            }
            else if zoomSlider <= 4{
                zoom = 0.3
            }
            else if zoomSlider <= 5{
                zoom = 0.5
            }
            else if zoomSlider <= 6{
                zoom = 1
            }
            else if zoomSlider <= 7{
                zoom = 2
            }
            else if zoomSlider <= 8{
                zoom = 5
            }
            else if zoomSlider <= 9{
                zoom = 10
            }
            else if zoomSlider <= 10{
                zoom = 20
            }
            else if zoomSlider <= 11{
                zoom = 26
            }
            else if zoomSlider <= 12{
                zoom = 30
            }
            else if zoomSlider <= 13{
                zoom = 40
            }
            else if zoomSlider <= 14{
                zoom = 60
            }
            else if zoomSlider <= 15{
                zoom = 80
            }
            else if zoomSlider <= 16{
                zoom = 100
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
           }
    
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    
//segue so that variables/values can be trasfered from view controller to view controller and entity is used to give the value/varibale back
    
        //USE NSPREDICATE??
    
    // MARK: - MKMapView delegate
    
    // Called when the region displayed by the map view is about to change
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print(#function)
    }
    
    // Called when the annotation was added
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.canShowCallout = true
            pinView?.isDraggable = true
            pinView?.pinColor = .green
            
            let rightButton: AnyObject! = UIButton(type: UIButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = rightButton as? UIView
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print(#function)
        var counter:Int = -1
        if control == view.rightCalloutAccessoryView {
            print(coordinatePins.count)
            for var i in coordinatePins
            {
                counter += 1
                let latit = view.annotation!.coordinate.latitude
                let longit = view.annotation!.coordinate.longitude
              //  print( String(describing: latit) + String(describing: longit))
               print (i.latitude)
                print(latit)
                print(i.longitude)
                print(longit)
               // print(if i.latitude == latit)
                if i.latitude == latit && i.longitude == longit
                {
                    print("i found pin")
                    
                    currentPin = i
                    break
                }
            }
            
            
            performSegue(withIdentifier: "editPinSeg", sender: self)
            print("counter: " + String(counter))
            print(coordinatePins)
            coordinatePins[counter].new = false;
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.ending {
            let droppedAt = view.annotation?.coordinate
            print(droppedAt!)
        }
    }
    
    // MARK: - Navigation
    /*
    @IBAction func didReturnToMapViewController(_ segue: UIStoryboardSegue) {
        print(#function)
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //print("preparing for segue... pin is new?" + String(currentPin.new))
        
        if segue.identifier == "editPinSeg" {
            print("successfully trasferred currentPin to next controller. this pin is new? " + String(currentPin.new))
            let secondScene = segue.destination as! TableViewController
            secondScene.currentPin = currentPin
            secondScene.lat = latitude
            secondScene.long = longitude
        
        }
    }
}
