//
//  Dialog.swift
//  Chubbyy
//
//  Created by David Mazza on 12/12/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import Foundation
import ObjectMapper

struct Dialog: Mappable {
  var sentences: [Sentence]?
  
  init?(_ map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    sentences     <- map["sentences"]
  }
}

struct Sentence: Mappable {
  var id: UInt?
  var text: String?
  
  init?(_ map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    id     <- map["id"]
    text  <- map["text"]
  }
}