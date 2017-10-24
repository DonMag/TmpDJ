//
//  ViewController.swift
//  TmpDJ
//
//  Created by Don Mag on 10/24/17.
//  Copyright © 2017 DonMag. All rights reserved.
//

import UIKit
import CoreLocation

class RequestLocationView: UIView {
	
	@IBOutlet weak var acceptButton: UIButton!
	@IBOutlet weak var rejectButton: UIButton!
	
	var lView: UIView!
	
	//weak
	var delegate: HandleLocationPermissionDelegate?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		xibSetup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		xibSetup()
	}
	
	private func xibSetup() {
		lView = loadViewFromNib()
		lView.frame = bounds
		lView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		lView.translatesAutoresizingMaskIntoConstraints = true
		addSubview(lView)
	}
	
	func loadViewFromNib() -> UIView {
		
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
		let nibView = nib.instantiate(withOwner: self, options: nil).first
		
		return nibView as! UIView
	}
	
	func setupView() {
		//		acceptButton.layer.cornerRadius = acceptButton.frame.height / 2
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		acceptButton.layer.cornerRadius = acceptButton.frame.height / 2
	}
	
	func fadeIn(completion: @escaping (Bool) -> Void) {
		UIView.animate(withDuration: 1.3, animations: {
			self.alpha = 1
		}, completion: completion)
	}
	
	func fadeOut(completion:  ((Bool) -> Void)?) {
		UIView.animate(withDuration: 1.3, animations: {
			self.alpha = 0
		}, completion: completion)
	}
	
	@IBAction func acceptPressed(_ sender: UIButton) {
		delegate?.allowPermissions()
	}
	
	@IBAction func rejecttPressed(_ sender: UIButton) {
		delegate?.denyPermissions()
	}
}

protocol HandleLocationPermissionDelegate {
	func allowPermissions()
	func denyPermissions()
}

class ViewController: UIViewController, HandleLocationPermissionDelegate, CLLocationManagerDelegate {
	
	var requestView = RequestLocationView()
	var locationManager = CLLocationManager()
	var beaconRegion: CLBeaconRegion?
	
	func allowPermissions() {
		requestView.fadeOut {(finished)  in
			if finished {
				self.locationManager.requestWhenInUseAuthorization()
				self.requestView.removeFromSuperview()
			}
		}
	}
	
	func denyPermissions() {
		requestView.fadeOut {(didFinish) in
			self.requestView.removeFromSuperview()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		initBeaconServices()
	}
	
	func initBeaconServices() {
		locationManager = CLLocationManager()
		if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
			requestView = RequestLocationView(frame: UIScreen.main.bounds)
			requestView.setupView()
			requestView.alpha = 0
			requestView.delegate = self
			self.navigationController?.view.addSubview(requestView)
			UIView.animate(withDuration: 0.5, delay : 1, options: .curveEaseOut, animations: {
				self.requestView.alpha = 1
			}, completion: nil)
		}
		locationManager.delegate = self
		locationManager.pausesLocationUpdatesAutomatically = true
		
		let uuid = UUID(uuidString: "869A6E2E-AE14-4CF5-8313-8D6976058A7A")
		
		// Create the beacon region to search for with those values.
		beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "com.dejordan.Capiche")
	}
	
}


