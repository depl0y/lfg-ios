//
//  BaseiPadController.swift
//  lfg
//
//  Created by Wim Haanstra on 22/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import UIKit

public class BaseiPadController: UISplitViewController, UISplitViewControllerDelegate, PureLayoutSetup {

	private var currentActivity: Activity?

	override public func viewDidLoad() {
		super.viewDidLoad()
		self.setupConstraints()
		self.configureViews()
		self.view.backgroundColor = UIColor.white
	}

	public func setupConstraints() {
	}

	public func configureViews() {
		let activitiesController = ActivitiesViewController()
		activitiesController.selectionChanged = { (activity) in
			if self.currentActivity != activity {
				self.currentActivity = activity
				if let nc = self.viewControllers[1] as? UINavigationController {


					let transition = CATransition()
					transition.duration = 0.5
					transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
					transition.type = kCATransitionFade
					nc.view.layer.add(transition, forKey: nil)

					let activityController = ActivityViewController(activity: activity)
					nc.setViewControllers([activityController], animated: false)

				}
			}

		}

		let nc = UINavigationController(rootViewController: activitiesController)

		self.viewControllers = [nc, UINavigationController(rootViewController: NoActivitySelectedViewController())]
		self.preferredDisplayMode = .allVisible
	}

	override public var preferredStatusBarStyle: UIStatusBarStyle {
		return UIStatusBarStyle.default
	}

	public func splitViewController(_ splitViewController: UISplitViewController,
	                                show viewController: UIViewController,
	                                sender: Any?) -> Bool {

		return true
	}
	public func splitViewController(_ splitViewController: UISplitViewController,
	                                separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {

		return NoActivitySelectedViewController()
	}


}
