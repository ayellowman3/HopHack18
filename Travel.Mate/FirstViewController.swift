//
//  FirstViewController.swift
//  Travel.Mate
//
//  Created by George Huang on 2/17/18.
//  Copyright © 2018 GeorgeHuang. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Firebase

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
    var cRef: String?
    let locationManager = CLLocationManager()
    var ref: DatabaseReference!


    var lat = 130.0
    var long = 130.0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        locationManager.requestAlwaysAuthorization()
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate=self
            locationManager.desiredAccuracy=kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        
        func setLat(num: Double){
            self.lat = num
        }
        func setLong(num: Double){
            self.long = num
        }
        func setLat(){
            print("hello")
        }
        GMSServices.provideAPIKey("AIzaSyDLB8eAlbSRf50WqR8nvg8svNZK8ebOyA0")
        
        
        refreshMap()
        ref = Database.database().reference().child("Trip").child(Trip.iD)
        //retrieve post and listen to change
        ref?.observe(.childChanged, with: {(snapshot) in
            self.updateLocal()
            self.reroute()
        })
    
        
    }
    var first: Bool = true
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            print(location.coordinate.latitude)
            self.lat = location.coordinate.latitude
            self.long = location.coordinate.longitude
        }
        if(first){
            refreshMap()
            first = false
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refreshMap(){
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 14)
        
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        let center = GMSCameraPosition.camera(withLatitude: lat,
                                              longitude: long,
                                              zoom: 14)
        mapView.camera = center
        mapView.isMyLocationEnabled = true;
        
        view = mapView
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: Trip.dLat, longitude: Trip.dLong)
        marker.title = "SFO airport"
        marker.map = mapView
    }
    
    var trips = [Trips]()
    func updateLocal(){
        fetchUsers()
        for t in trips{
            if(t.iD == Trip.iD){
                Trip.iD = t.iD
                Trip.passcode = t.passcode
                Trip.dAddress = t.dAddress
                Trip.dLat = t.dLat
                Trip.dLong = t.dLong
                Trip.sAddress = t.sAddress
                Trip.sLat = t.sLat
                Trip.sLong = t.sLong
            }
        }
    }
    
    func fetchUsers() {
        let ref = Database.database().reference()
        let query = ref.child("Trip").queryOrdered(byChild: "Trip")
        query.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let value = child.value as? NSDictionary {
                    let t:Trips = Trips()
                    let iD = value["TripID"] as? String ?? "Name not found"
                    let passcode = value["passcode"] as? String ?? "Email not found"
                    let dAddress = value["dAddress"] as? String ?? " not found"
                    let dLatitude = value["dLatitude"] as? Double ?? 0.0
                    let dLongitude = value["dLongitude"] as? Double ?? 0.0
                    let sAddress = value["sAddress"] as? String ?? " not found"
                    let sLatitude = value["sLatitude"] as? Double ?? 0.0
                    let sLongitude = value["sLongitude"] as? Double ?? 0.0
                    
                    t.iD = iD
                    t.passcode = passcode
                    t.dAddress = dAddress
                    t.dLat = dLatitude
                    t.dLong = dLongitude
                    t.sAddress = sAddress
                    t.sLat = sLatitude
                    t.sLong = sLongitude
                    self.trips.append(t)
                }
            }
        }
        
    }
    func reroute(){
        
    }
    
    
}

