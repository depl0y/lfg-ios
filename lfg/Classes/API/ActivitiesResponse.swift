//
//  ActivitiesResponse.swift
//  lfg
//
//  Created by Wim Haanstra on 08/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import ObjectMapper

public class ActivitiesResponse: Mappable {

    public var activities = [Activity]()

    public required init?(map: Map) {
    }

    public func mapping(map: Map) {
        activities <- map["activities"]
    }

}
