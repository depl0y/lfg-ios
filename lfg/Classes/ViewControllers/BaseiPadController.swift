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

			if let nc = self.viewControllers[1] as? UINavigationController {
				let activityController = ActivityViewController(activity: activity)
				nc.setViewControllers([activityController], animated: true)
			}

		}

		let nc = UINavigationController(rootViewController: activitiesController)

		self.viewControllers = [nc, UINavigationController(rootViewController: NoActivitySelectedViewController())]
		self.preferredDisplayMode = .allVisible
	}

	override public var preferredStatusBarStyle: UIStatusBarStyle {
		return UIStatusBarStyle.default
	}

	public func splitViewController(_ splitViewController: UISplitViewController, show vc: UIViewController, sender: Any?) -> Bool {
		return true
	}
	public func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
		return NoActivitySelectedViewController()
	}

}
