//
//  Date+Ago.swift
//  lfg
//
//  Created by Wim Haanstra on 16/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation

extension Date {

	func timeAgo() -> String {
		let currentDate = Date()

		if currentDate < self {
			return "In da future?"
		} else {
			let flags: Set<Calendar.Component> = [ Calendar.Component.second ]
			let components = Calendar.current.dateComponents(flags, from: self, to: currentDate)

			var value = ""
			if let seconds = components.second {
				if seconds == 0 {
					value = "Just now"
				} else if seconds < 60 {
					value = (seconds == 1) ? "1 second" : "\(seconds) seconds"
				} else if seconds >= 60 && seconds < 3600 {
					let minutes = Int(seconds / 60)
					value = (minutes == 1) ? "1 minute" : "\(minutes) minutes"
				} else if seconds >= 3600 && seconds < 86400 {
					let hours = Int(seconds / 3600)
					value = (hours == 1) ? "1 hour" : "\(hours) hours"
				} else if seconds >= 86400 && seconds < 2592000 {
					let days = Int(seconds / 86400)
					value = (days == 1) ? "1 day" : "\(days) days"
				} else {
					let months = Int(seconds / 2592000)
					value = (months == 1) ? "1 month" : "\(months) months"
				}
			}

			return value
		}

	}

}

/*
if elapsed_seconds < 60
elsif elapsed_seconds >= 3600 && elapsed_seconds < 86400
result[:number] = ((elapsed_seconds / 60) / 60).to_i
result[:time_object] = (result[:number] == 1) ? I18n.t("request.item.time.hour") : I18n.t("request.item.time.hours")
elsif elapsed_seconds >= 86400
result[:number] = (((elapsed_seconds / 60) / 60) / 24).to_i
result[:time_object] = (result[:number] == 1) ? I18n.t("request.item.time.day") : I18n.t("request.item.time.days")
end
*/
