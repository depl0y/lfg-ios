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

/// Class for managing calls to the API
class API {

	/// The base URL used to talk to the LFG API
	let baseUrl = "https://lfg.pub/api/v2/"

	/// Fetches the activities and stores them in the database
	///
	/// - Parameters:
	///   - completed: A callback, which is performed when the request is complete (or fails)
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
						_ = result.languages.map { $0.createOrUpdate(realm: realm) }
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

	/// Gets the field configuration for an activity and stores it in the database
	///
	/// - Parameters:
	///   - activity: The activity to get the configuration for
	///   - completed: A callback, which is performed when the request is complete (or fails)
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
						activity.lastConfigUpdate = Date()
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

	/// Query the requests for an activity
	///
	/// - Parameters:
	///   - activity: The activity to find requests for
	///   - filters: The filters the user has set up
	///   - completed: A callback, which is performed when the request is complete, containing the requests for that activity
	public func query(activity: Activity, page: Int, perPage: Int, filters: [Int: Any],
	                  completed: @escaping (_ success: Bool, _ requests: [Request]?) -> Void) {

		let url = "\(baseUrl)requests/\(activity.permalink)/query"

		var parameters: [String: Any] = [
			"page": page,
			"per_page": perPage
		]

		filters.forEach { (key, value) in
			var realKey = "\(key)"
			if key == -1 {
				realKey = "group"
			} else if key == -2 {
				realKey = "lf_mode"
			} else if key == -3 {
				realKey = "language"
			}
			parameters[realKey] = value
		}

		log.debug("POST \(url) \(parameters)")

		Alamofire.request(url, method: .post, parameters: parameters).responseObject { (response: DataResponse<QueryResponse>) in
			if let result = response.result.value {
				result.requests.forEach({ (request) in
					request.activity = activity
				})
				completed(true, result.requests)
			} else {
				completed(false, nil)
			}
		}
	}

}
