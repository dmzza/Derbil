//
//  Dialog.swift
//  Chubbyy
//
//  Created by David Mazza on 12/12/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import Foundation
import ObjectMapper

struct DialogArray: Mappable {
  var dialogs: [Dialog]?
  
  init?(_ map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    dialogs <- map["dialogs"]
  }
}

struct Dialog: Mappable {
  var sentences: [Sentence]?
  
  init?(_ map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    sentences     <- map["sentences"]
  }
}

enum ResponseType: String {
  case Text = "text"
  case Number = "number"
  case Boolean = "boolean"
  case Day = "day"
  case Time = "time"
  
}

enum DayOfWeek {
  case Monday
  case Tuesday
  case Wednesday
  case Thursday
  case Friday
  case Saturday
  case Sunday
}

struct Sentence: Mappable {
  var id: UInt?
  var text: String?
  var responseType: ResponseType?
  
  init?(_ map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    id     <- map["id"]
    text  <- map["text"]
    responseType <- map["response_type"]
  }
}
