//
//  ListTransformer.swift
//  lfg
//
//  Created by Wim Haanstra on 09/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

public struct ListTransform<T: RealmSwift.Object>: TransformType where T: Mappable {

    public init() { }

    public typealias Object = List<T>
    public typealias JSON = [Any]

    public func transformFromJSON(_ value: Any?) -> List<T>? {
        if let objects = Mapper<T>().mapArray(JSONObject: value) {
            let list = List<T>()
            list.append(objectsIn: objects)
            return list
        }
        return nil
    }

    public func transformToJSON(_ value: Object?) -> JSON? {
        return value?.flatMap { $0.toJSON() }
    }

}
