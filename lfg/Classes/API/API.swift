//
//  API.swift
//  lfg
//
//  Created by Wim Haanstra on 08/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import RealmSwift

class API {

    let baseUrl = "https://lfg.pub/api/v2/"

    public func activities(completed: @escaping (_ success: Bool) -> Void) {
        let command = "activities"

        let url = "\(baseUrl)\(command)"

        log.debug("GET \(url)")

        Alamofire.request(url).responseObject { (response: DataResponse<ActivitiesResponse>) in
            if let result = response.result.value {
                do {
                    let realm = try Realm()
                    try realm.write {
						let permalinks = result.activities.map { $0.permalink }
						Activity.removeExcept(realm: realm, activities: permalinks)
                        _ = result.activities.map { $0.createOrUpdate(realm: realm) }
                    }
                    completed(true)
                } catch {
                    log.debug("Error writing to realm")
                    completed(false)
                }
            } else {
                completed(false)
            }
        }
    }

    public func configuration(activity: Activity, completed: @escaping (_ success: Bool) -> Void) {
        let url = "\(baseUrl)activity/\(activity.permalink)"

        log.debug("GET \(url)")

        Alamofire.request(url).responseObject { (response: DataResponse<ActivityResponse>) in
            if response.result.value != nil {

                do {
                    let realm = try Realm()

                    try realm.write {
						let fieldGroupNames = response.result.value!.fieldGroups.map { $0.name }
						FieldGroup.removeExcept(realm: realm, activity: activity, names: fieldGroupNames)
						_ = response.result.value!.fieldGroups.map { $0.createOrUpdate(realm: realm, activity: activity) }
                    }
                    completed(true)
                } catch {
                    log.debug("Error writing to realm")
                    completed(false)
                }
            } else {
                completed(false)
            }
        }
    }

}
