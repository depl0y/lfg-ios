//
//  RequestViewController.swift
//  lfg
//
//  Created by Wim Haanstra on 14/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit

public class RequestViewController: UIViewController, PureLayoutSetup {

	private var request: Request!

	public init(request: Request) {
		super.init(nibName: nil, bundle: nil)
		self.request = request

		self.setupConstraints()
		self.configureViews()
	}

	public func setupConstraints() {
	}

	public func configureViews() {
		self.title = self.request.title
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override public func viewDidLoad() {
		super.viewDidLoad()
	}

	override public var preferredStatusBarStyle: UIStatusBarStyle {
		return UIStatusBarStyle.default
	}
}
