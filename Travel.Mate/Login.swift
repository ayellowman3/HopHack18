//
//  Login.swift
//  Travel.Mate
//
//  Created by George Huang on 2/17/18.
//  Copyright © 2018 GeorgeHuang. All rights reserved.
//

import UIKit
import Firebase

class Login: UIViewController {
    
    //reference firebase
    var cRef: String?
    var ref: DatabaseReference!
    var tripList = [Trips]()
    var trips = [Trips]()
    
    @IBOutlet weak var trip_id: UITextField!
    @IBOutlet weak var passcode: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ref = Database.database().reference()
        ref.child("Trip")
        fetchUsers()
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
    
    // after destination set from method above use direction api by writing a json file hard coding a given destination
    //then parse that json file and call the https into swift
    //idk how to any of that lol so
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //join trip
    @IBAction func buttonAction(sender: AnyObject) {
        if(validate(trip_id: trip_id.text!, passcode: passcode.text!)){
            successLogin()
        }
    }
    
    //create trip
    @IBAction func createTrip(sender: AnyObject){
        let nID:String = newID()
        let nPass:String = ran4()
        ref = Database.database().reference().child("Trip").child(nID)
        
        ref.child("TripID").setValue(nID)
        ref.child("passcode").setValue(nPass)
        ref.child("dAddress").setValue("")
        ref.child("dLatitude").setValue(0)
        ref.child("dLongitude").setValue(0)
        ref.child("sAddress").setValue("")
        ref.child("sLatitude").setValue(0)
        ref.child("sLongitude").setValue(0)
        Trip.iD = nID
        Trip.passcode = nPass
        Trip.dAddress = ""
        Trip.dLat = 0
        Trip.dLong = 0
        Trip.sAddress = ""
        Trip.sLat = 0
        Trip.sLong = 0
        
        successLogin()
    }
    
    func validate(trip_id: String, passcode: String) -> Bool{
        if(checkLogin(id: trip_id, pass: passcode)){
                return true
        }
        return false
    }
    
    func successLogin(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "logged") as! UITabBarController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func checkLogin(id:String, pass:String) -> Bool{
        for t in trips{
            if(t.iD == id){
                if(t.passcode == pass){
                    Trip.iD = t.iD
                    Trip.passcode = t.passcode
                    Trip.dAddress = t.dAddress
                    Trip.dLat = t.dLat
                    Trip.dLong = t.dLong
                    Trip.sAddress = t.sAddress
                    Trip.sLat = t.sLat
                    Trip.sLong = t.sLong
                    return true;
                }
            }
        }
        return false;
    }
    
    let letters:[Character] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9"]
    
    func newID() -> String{
        let s:String = ran4()
        if(dup(s: s)){
            return newID()
        }
        return s
    }
    
    func dup(s:String) -> Bool{
        for t in trips{
            if(t.iD == s){
                return true
            }
        }
        return false
    }
    
    func ran4() ->String{
        var s:String = ""
        for _ in 0...3{
            let n:Int = randRange(lower: 0, upper: 35)
            s = s + (String(letters[n]))
        }
        return s
    }
    func randRange (lower: Int , upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}
    

