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
  var id: UInt?
  var sentences: [Sentence]?
  
  init?(_ map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    id     <- map["id"]
    sentences     <- map["sentences"]
  }
}

enum ResponseType: String {
  case Number = "number"
  case Boolean = "boolean"
  case String = "string"
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
  var isResponse: Bool!
  var responseType: ResponseType?
  
  init?(_ map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    id     <- map["id"]
    text  <- map["text"]
    isResponse <- map["is_response"]
    responseType <- map["response_type"]
  }
}
