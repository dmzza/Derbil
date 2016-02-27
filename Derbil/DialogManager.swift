//
//  DialogManager.swift
//  Chubbyy
//
//  Created by David Mazza on 12/15/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import Foundation
import ObjectMapper

let kUserDefaultsDialogHistory = "DialogHistory" // an array of ID's of dialogs had in reverse chronological order

class DialogManager {
  let delegate: DialogManagerDelegate
  var dialogs: [Dialog]
  var currentDialog: Dialog?
  
  init(delegate: DialogManagerDelegate) {
    self.delegate = delegate
    if let dialogArray = Mapper<DialogArray>().map(stringOfJSONFile("dialogs")) {
      self.dialogs = dialogArray.dialogs!
    } else {
      self.dialogs = [Dialog]()
    }
    self.popNextDialog()
  }
  
  func popNextDialog() {
    if self.dialogs.count > 0 {
      let nextDialog = self.dialogs.removeAtIndex(0)
      if self.meetsRequirementsForDialog(nextDialog) {
        if let lastDialog = self.currentDialog {
          var newHistory: [UInt] = [lastDialog.id!]
          if let dialogHistory: [UInt] = NSUserDefaults().arrayForKey(kUserDefaultsDialogHistory) as? [UInt] {
            newHistory.appendContentsOf(dialogHistory)
          }
          NSUserDefaults().setObject(newHistory, forKey: kUserDefaultsDialogHistory)
        }
        self.currentDialog = nextDialog
        popNextSentence()
      } else {
        self.popNextDialog()
      }
    }
  }
  
  func popNextSentence() {
    if self.currentDialog!.sentences != nil && self.currentDialog!.sentences!.count > 0 {
      let nextSentence = self.currentDialog!.sentences!.removeAtIndex(0)

      if nextSentence.isResponse! {
        
        
        self.delegate.dialogManager(self, wantsUserToRespond: nextSentence, completion: { (didRespond, response) -> () in
          if didRespond {
            if let responseType = nextSentence.responseType  {
              switch responseType {
              case .Number:
                let _ = response as! Int
                break
              case .Boolean:
                let _ = response as! Bool
                break
              case .String:
                let _ = response as! String
                break
              }
            
              //TODO: handle response
            }
            self.popNextSentence()
          } else {
            //for testing
            self.popNextSentence()
          }
        })
      } else {
        self.delegate.dialogManager(self, wantsChubbyyToSpeak: nextSentence, completion: { (didSpeak) -> () in
          if didSpeak {
            self.popNextSentence()
          }
        })
      }
    } else {
      self.popNextDialog()
    }
  }
  
  func meetsRequirementsForDialog(dialog: Dialog) -> Bool {
    if let dialogHistory: [UInt] = NSUserDefaults().arrayForKey(kUserDefaultsDialogHistory) as? [UInt] {
      if(dialogHistory.contains(dialog.id!) ) {
        return false
      }
    }
    return true
  }
  
}

protocol DialogManagerDelegate {
  func dialogManager(manager: DialogManager, wantsChubbyyToSpeak sentence:Sentence, completion:(didSpeak: Bool)->())
  func dialogManager(manager: DialogManager, wantsUserToRespond sentence:Sentence, completion:(didRespond: Bool, response: Any?)->() )
}
