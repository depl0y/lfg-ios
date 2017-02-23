//
//  ActivityResponse.swift
//  lfg
//
//  Created by Wim Haanstra on 09/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation

import ObjectMapper

public class ActivityResponse: Mappable {

    public var fieldGroups = [FieldGroup]()

    public required init?(map: Map) {
    }

    public func mapping(map: Map) {
        fieldGroups <- map["fields"]
    }

}
