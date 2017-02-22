//
//  NoActivitySelectedViewController.swift
//  lfg
//
//  Created by Wim Haanstra on 22/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit
import PureLayout

class NoActivitySelectedViewController: UIViewController, PureLayoutSetup {

	var imageView = UIImageView()
	var titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.addSubview(imageView)
		self.view.addSubview(titleLabel)

		self.setupConstraints()
		self.configureViews()

		self.titleLabel.text = "No game selected"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	public func setupConstraints() {
		self.imageView.autoMatch(.width, to: .width, of: self.view, withMultiplier: 0.6)
		self.imageView.autoMatch(.height, to: .width, of: self.view, withMultiplier: 0.6)

		self.imageView.autoAlignAxis(.horizontal, toSameAxisOf: self.view)
		self.imageView.autoAlignAxis(.vertical, toSameAxisOf: self.view)

		self.titleLabel.autoPinEdge(.left, to: .left, of: self.view)
		self.titleLabel.autoPinEdge(.right, to: .right, of: self.view)
		self.titleLabel.autoPinEdge(.top, to: .bottom, of: self.imageView, withOffset: 0)
		self.titleLabel.autoSetDimension(.height, toSize: 22)

	}

	public func configureViews() {
		self.view.backgroundColor = UIColor(netHex: 0xC8C8C9)
		self.imageView.image = UIImage(named: "white-logo")

		self.titleLabel.textAlignment = .center
		self.titleLabel.textColor = UIColor.white
		self.titleLabel.font = UIFont.latoBoldWithSize(size: 18)
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
