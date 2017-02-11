//
//  DatatypeTransformer.swift
//  lfg
//
//  Created by Wim Haanstra on 09/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import ObjectMapper

public class DatatypeTransformer: TransformType {

    public typealias Object = DataType
    public typealias JSON = String

    public func transformFromJSON(_ value: Any?) -> DataType? {
        if let v = value as? String {
            return DataType.fromString(name: v)
        }
        return DataType.Unknown
    }

    public func transformToJSON(_ value: DataType?) -> String? {
        return nil
    }

}
