//
//  ChatCell.swift
//  RealTimeChatApp
//
//  Created by Mohamed Samir on 10/2/19.
//  Copyright © 2019 Mohamed Samir. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    enum bubbleType{
        case   incoming
        case  outgoing
    }
    /////////////////////////////////////////////////////////////////
    @IBOutlet weak var userNameLB: UILabel!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var chatStackView: UIStackView!
    @IBOutlet weak var chatView: UIView!{
        didSet{
            self.chatView.layer.cornerRadius = 7
        }
    }
    /////////////////////////////////////////////////////////////////
    func setMessageData(message:Message){
        userNameLB.text = message.messageSender
        chatTextView.text = message.messageText
        
    }
    ////////////////////////////////////////////////////////////////
    
    func setBubbleType(type:bubbleType){
        if (type == .incoming){
            chatView.backgroundColor = #colorLiteral(red: 0.7371893525, green: 0.7372968793, blue: 0.7371658683, alpha: 1)
            chatTextView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            chatStackView.alignment = .leading
        }else if (type == .outgoing){
            chatView.backgroundColor = #colorLiteral(red: 0.09122894358, green: 0.247854527, blue: 0.2640752378, alpha: 1)
            chatTextView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            chatStackView.alignment = .trailing
        }
    }
    /////////////////////////////////////////////////////////////
}
