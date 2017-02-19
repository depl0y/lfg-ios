//
//  Object+Detach.swift
//  lfg
//
//  Created by Wim Haanstra on 17/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class ObjectDetacher<T: Object> {

	/// Detach an object from the current Realm, using the right schema
	///
	/// - Parameter object: The object to detach
	/// - Returns: A detached object
	static func detach(object: T) -> T {
		return T(value: object, schema:  RLMSchema(objectClasses: [
			Field.self,
			FieldGroup.self,
			Activity.self,
			FieldOption.self,
			ActivityGroup.self
		]))
	}
}
