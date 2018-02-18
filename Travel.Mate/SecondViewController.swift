//
//  SecondViewController.swift
//  Travel.Mate
//
//  Created by George Huang on 2/17/18.
//  Copyright © 2018 GeorgeHuang. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import Firebase



class SecondViewController: UIViewController {
    var cRef: String?
    var ref: DatabaseReference!
    @IBOutlet weak var destSearch: UIButton!
    @IBOutlet weak var stopSearch: UIButton!
    @IBOutlet weak var resume: UIButton!
    @IBOutlet weak var tID: UILabel!
    @IBOutlet weak var tPC: UILabel!
    var labelText:String = "Search"
    var des: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        resume.setTitle("", for: [])
        // Do any additional setup after loading the view, typically from a nib.
       
        if(!(Trip.dAddress == "")){
            destSearch.setTitle(Trip.dAddress, for: [])
        }
        if(!(Trip.sAddress == "")){
            stopSearch.setTitle(Trip.sAddress, for: [])
            resume.setTitle("resume", for: [])
        }
        tID.text = Trip.iD
        tPC.text = Trip.passcode
        GMSServices.provideAPIKey("AIzaSyDLB8eAlbSRf50WqR8nvg8svNZK8ebOyA0")
        GMSPlacesClient.provideAPIKey("AIzaSyDLB8eAlbSRf50WqR8nvg8svNZK8ebOyA0")
        
        //set firebase reference
        ref = Database.database().reference().child("Trip").child(Trip.iD)
        //retrieve post and listen to change
        ref?.observe(.childChanged, with: {(snapshot) in
            let s = snapshot.value as? String!
            if(!(s==nil)){
                if(self.des){
                    if(!(s=="")){
                        Trip.dAddress = s!
                    }
                }else{
                    if(!(s=="")){
                        Trip.sAddress = s!
                    }
                }
            }
            self.updateLocal()
            
            self.reroute()
        })
    }
    
    func setButton(){
        if(des){
        destSearch.setTitle(labelText,  for: [])
        }
        else{
            stopSearch.setTitle(labelText,  for: [])
            resume.setTitle("resume", for: [])
        }
    }
    
    @IBAction func resumeTrip(sender:UIButton){
        Trip.sAddress = ""
        Trip.sLat = 0
        Trip.sLong = 0
        updateFB()
        
        stopSearch.setTitle("Search", for: [])
        resume.setTitle("", for: [])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
        
        // TODO: Add a button to Main.storyboard to invoke onLaunchClicked.
        
        // Present the Autocomplete view controller when the button is pressed.
        @IBAction func onLaunchClicked(sender: UIButton) {
            des = true
            let acController = GMSAutocompleteViewController()
            acController.delegate = self as GMSAutocompleteViewControllerDelegate
            present(acController, animated: true, completion: nil)
        }
    
    @IBAction func onLaunchClicked2(sender:UIButton){
        des = false
        let acController = GMSAutocompleteViewController()
        acController.delegate = self as GMSAutocompleteViewControllerDelegate
        present(acController, animated: true, completion: nil)
    }
    }
    
    extension SecondViewController: GMSAutocompleteViewControllerDelegate {
        
        // Handle the user's selection.
        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            var temp:String = ""
            print("Place name: \(place.name)")
            print("Place address: \(String(describing: place.formattedAddress))")
            print("Place attributions: \(String(describing: place.attributions))")
            temp += (place.name)
            if(des){
                Trip.dAddress = place.name
                Trip.dLat = place.coordinate.latitude
                Trip.dLong = place.coordinate.longitude
            }else{
                Trip.sAddress = place.name
                Trip.sLat = place.coordinate.latitude
                Trip.sLong = place.coordinate.longitude
            }
            updateFB()
            
            //temp += ("Place address: \(String(describing: place.formattedAddress))")
            //temp += ("Place attributions: \(String(describing: place.attributions))")
            //temp += (String)(place.coordinate.latitude)
            
            labelText = temp
            setButton()
            dismiss(animated: true, completion: nil)
        }
        
        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
            // TODO: handle the error.
            print("Error: \(error)")
            dismiss(animated: true, completion: nil)
        }
        
        // User cancelled the operation.
        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            print("Autocomplete was cancelled.")
            dismiss(animated: true, completion: nil)
        }
        

        
        func updateFB(){
            ref = Database.database().reference().child("Trip").child(Trip.iD)
            
            ref.child("TripID").setValue(Trip.iD)
            ref.child("passcode").setValue(Trip.passcode)
            ref.child("dAddress").setValue(Trip.dAddress)
            ref.child("dLatitude").setValue(Trip.dLat)
            ref.child("dLongitude").setValue(Trip.dLong)
            ref.child("sAddress").setValue(Trip.sAddress)
            ref.child("sLatitude").setValue(Trip.sLat)
            ref.child("sLongitude").setValue(Trip.sLong)
        }
        
        //var trips2 = [Trips2]()
        func updateLocal(){
            fetchUsers()
            //for t in trips{
                /*if(t.iD == Trip.iD){
                    Trip.iD = t.iD
                    Trip.passcode = t.passcode
                    Trip.dAddress = t.dAddress
                    Trip.dLat = t.dLat
                    Trip.dLong = t.dLong
                    Trip.sAddress = t.sAddress
                    Trip.sLat = t.sLat
                    Trip.sLong = t.sLong
                }*/
            //}
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
                        //trips2.append(t)
                    }
                }
            }
            
        }
        func reroute(){
            
        }
        
    }



