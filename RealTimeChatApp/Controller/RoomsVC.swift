//
//  RoomsVC.swift
//  RealTimeChatApp
//
//  Created by Mohamed Samir on 9/30/19.
//  Copyright © 2019 Mohamed Samir. All rights reserved.
//

import UIKit
import Firebase

class RoomsVC: UIViewController {
    
    var rooms = [Room]()
    
    @IBOutlet weak var RoomsTV: UITableView!
    @IBOutlet weak var RoomNameTF: UITextField!
    ///////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        observeRooms()
        
        
    }
    ////////////////////////////////////////////////////////
    func observeRooms(){
        let reference = Database.database().reference()
        reference.child("Rooms").observe(.childAdded) { (snapshot) in
            guard let dataArray = snapshot.value as? [String : Any]  else {return}
            guard let thisRoomName = dataArray["roomName"] as? String else {return}
            let room = Room.init(roomName: thisRoomName, roomID: snapshot.key)
            self.rooms.append(room)
            self.RoomsTV.reloadData()
        }
    }
    //////////////////////////////////////////////////////////
    @IBAction func logoutBut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.setValue("", forKey: "api_token")
        } catch  {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
    ////////////////////////////////////////////////////////////
    @IBAction func CreatNewRoomBUT(_ sender: UIButton) {
        
        if let roomName = RoomNameTF.text , !roomName.isEmpty {
            let reference = Database.database().reference()
            let room = reference.child("Rooms").childByAutoId()
            let dataArray : [String:Any] = ["roomName":roomName]
            room.setValue(dataArray) { (error, databaseRef) in
                if error == nil {
                    self.RoomNameTF.text = ""
                     print("room added successfully")
                }
            }
        }else{
            print("room is empty")
        }
        
    }
    
}
///////////////////////////////////////////////////////////////
extension RoomsVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomsTableViewCell", for: indexPath) as! RoomsTableViewCell
        cell.roomLB.text = rooms[indexPath.row].roomName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRoom = rooms[indexPath.row]
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatRoomVC") as! ChatRoomVC
        vc.room = selectedRoom
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
