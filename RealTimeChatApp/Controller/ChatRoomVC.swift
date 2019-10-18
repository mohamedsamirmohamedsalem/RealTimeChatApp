//
//  ChatRoomVC.swift
//  RealTimeChatApp
//
//  Created by Mohamed Samir on 10/1/19.
//  Copyright © 2019 Mohamed Samir. All rights reserved.
//

import UIKit
import Firebase

class ChatRoomVC: UIViewController {
    
    var room:Room?
    var chatMessage = [Message]()
    
    @IBOutlet weak var chatTF: UITextField!
    @IBOutlet weak var chatTableView: UITableView!{
        didSet{
            self.chatTableView.separatorStyle = .none
            self.chatTableView.allowsSelection = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        title = room?.roomName // thats equal to --> navigationController?.title = room?.roomName
        observeMessages()
        
        
    }
    //////////////////////////////////////////////////////////////////////////////////
    @IBAction func sendBUT(_ sender: UIButton) {
        if let chatText = chatTF.text , !chatText.isEmpty , let userID = Auth.auth().currentUser?.uid {
            sendMessage(chatText, userID) { (isSuccess) in
                if (isSuccess){
                    self.chatTF.text = ""
                    print("message added to database successfully")
                }else{
                    print("can not add message to database successfully")
                }
            }
        }else{
            print("Empty ChatText")
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////
    func sendMessage(_ chatText:String,_ userID:String,completion : @escaping (_ isSuccess:Bool)->Void ){
        let databaseRef = Database.database().reference()
        guard let userID = Auth.auth().currentUser?.uid else {return}
        getUserNameWithId(userID) { (UserName, error) in
            if (error == false){
                print("failed to get username")
            }else{
                guard let userName = UserName else {return}
                let dataArray : [String:Any] = ["senderName":userName,"text":chatText,"senderId":userID]
                guard let roomId = self.room?.roomID else {return}
                let room = databaseRef.child("Rooms").child(roomId)
                room.child("Messages").childByAutoId().setValue(dataArray, withCompletionBlock: { (error, databaseRef) in
                    if error == nil {
                        completion(true)
                    }else {
                        completion(false)
                    }
                })
            }
        }
    }
    /////////////////////////////////////////////////////////////////////////
    func getUserNameWithId(_ userID:String,_ completion: @escaping(_ userName:String?,_ error:Bool)->Void){
        let databaseRef = Database.database().reference()
        let user = databaseRef.child("Users").child(userID)
        user.child("username").observeSingleEvent(of: .value) { (snapshot) in
            if let userName = snapshot.value as? String{
                completion(userName,true)
            } else{
                completion(nil,false)
            }
        }
    }
    /////////////////////////////////////////////////////////////////////////////
    func observeMessages(){
        guard let roomId = room?.roomID else {return}
        let databaseRef = Database.database().reference()
        databaseRef.child("Rooms").child(roomId).child("Messages").observe(.childAdded) { (snapshot) in
            guard let dataArray = snapshot.value as? [String:Any] else {return}
            if let userName = dataArray["senderName"] as? String , let thisMessageText = dataArray["text"] as? String , let userId = dataArray["senderId"] as? String{
                let message = Message.init(messageKey: snapshot.key, messageSender: userName, messageText: thisMessageText, userId: userId)
                self.chatMessage.append(message)
                self.chatTableView.reloadData()
                
            }
            
            
        }
    }
}
/////////////////////////////////////////////////////////////////////////////////
extension ChatRoomVC : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessage.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        
        let message = chatMessage[indexPath.row]
        cell.setMessageData(message: message)
        if let currentUser = Auth.auth().currentUser?.uid {
            if(message.userId == currentUser){
                cell.setBubbleType(type: .outgoing)
            }else{
                cell.setBubbleType(type: .incoming)
            }
        }
        
        return cell
    }
}
