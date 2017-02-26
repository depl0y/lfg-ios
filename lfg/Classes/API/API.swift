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

			if let valueArray = value as? [Int], valueArray.count == 2 {
				let dict = [
					"from": valueArray[0],
					"to": valueArray[1]
				]
				parameters[realKey] = dict
			} else {
				parameters[realKey] = value
			}
		}

		log.debug("POST \(url) \(parameters)")

		Alamofire.request(url, method: .post, parameters: parameters).responseObject { (response: DataResponse<QueryResponse>) in
			if let result = response.result.value {

				var index: TimeInterval = 0
				result.requests.forEach({ (request) in
					request.activity = activity
					index += 1

					if AppDelegate.anonymize {
						request.timeStamp = Date(timeIntervalSinceNow: index * TimeInterval(-1))
					}

				})
				completed(true, result.requests)
			} else {
				completed(false, nil)
			}
		}
	}

	public func create(activity: Activity,
	                   parameters: [String: Any],
	                   completed: @escaping (_ success: Bool, _ uniqueId: String?, _ message: String?, _ diff: Int?) -> Void) {

		let url = "\(baseUrl)requests/\(activity.permalink)"

		log.debug("POST \(url) \(parameters)")

		Alamofire.request(url, method: .post, parameters: parameters).responseObject { (response: DataResponse<CreateRequestResponse>) in

			if let result = response.result.value, response.response?.statusCode == 200 {
				completed(true, result.lid, nil, nil)
			} else {
				if response.data != nil && response.data!.count > 0 {
					do {
						if let json = try JSONSerialization.jsonObject(with: response.data!,
						                                               options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
							log.debug("\(json)")
							completed(false, nil, json["message"] as? String, json["diff"] as? Int)
						}
					} catch {
						completed(false, nil, nil, nil)
					}
				} else {
					if response.response?.statusCode == 403 {
						completed(false, nil, "banned", nil)
					} else {
						completed(false, nil, nil, nil)
					}
				}
			}
			/*
			} else {
				completed(false, nil, nil, nil)
			}*/
		}
	}

	//https://lfg.pub/api/v2/requests/doom/bd02ff34-7c72-4352-bc5d-8cfb0db1dcec/remove

	public func remove(activity: Activity, uniqueId: String, completed: @escaping (_ success: Bool) -> Void) {
		let url = "\(baseUrl)requests/\(activity.permalink)/\(uniqueId)/remove"

		log.debug("POST \(url) ")

		Alamofire.request(url, method: .post, parameters: nil).responseObject { (response: DataResponse<RemoveRequestResponse>) in
			if let result = response.result.value {
				completed((result.status == "ok" || result.status == "record not found"))
			} else {
				completed(false)
			}
		}
	}

}
