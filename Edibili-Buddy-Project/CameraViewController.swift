/*Copyright (c) 2016, Andrew Walz.

Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */


import UIKit
import SwiftyCam

protocol holdImagesToSendToAI {
    func pass(uiImageArray: [UIImage], sendImages: Bool)
}

class CameraViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate, holdImagesToSendToAI {
    
    @IBOutlet weak var captureButton: SwiftyRecordButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var cameraRollButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    
    var delegate: holdImagesToSendToAI?
    var imageArray: [UIImage] = []
    var sendToAI: Bool = false
    
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tabBarController?.tabBar.isHidden = true
        cameraDelegate = self
		maximumVideoDuration = 10.0
        shouldUseDeviceOrientation = true
        allowAutoRotate = true
        audioEnabled = true
	}
    
    init(delegate: holdImagesToSendToAI) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func pass(uiImageArray: [UIImage], sendImages: Bool) { //conforms to protocol
        imageArray = uiImageArray
        sendToAI = sendImages
    }

	override var prefersStatusBarHidden: Bool {
		return true
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        captureButton.delegate = self
        self.tabBarController?.tabBar.isHidden = true
        if sendToAI {
            sendToAI = false
            self.tabBarController?.tabBar.isHidden = false
            //after it is sent to the ai we need to go to the gallary
            tabBarController?.selectedIndex = 2
        }
	}

	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        let newVC = PhotoViewController(image: photo, delegate: self, imageArray: imageArray)
		self.present(newVC, animated: true, completion: nil)
	}

	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
		let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
		focusView.center = point
		focusView.alpha = 0.0
		view.addSubview(focusView)

		UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
			focusView.alpha = 1.0
			focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
		}, completion: { (success) in
			UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
				focusView.alpha = 0.0
				focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
			}, completion: { (success) in
				focusView.removeFromSuperview()
			})
		})
	}

	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
		print(zoom)
	}

	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
		print(camera)
	}

    @IBAction func cameraSwitchTapped(_ sender: Any) {
        switchCamera()
    }
    
    @IBAction func toggleFlashTapped(_ sender: Any) {
        flashEnabled = !flashEnabled
        
        if flashEnabled == true {
            flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControlState())
        } else {
            flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControlState())
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        //make sure the know their images will disappear
        let alert = UIAlertController(title: "Cancel Clicked", message: "If you leave page you will lose all your pictures", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Stay", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Leave", style: UIAlertActionStyle.cancel, handler: { action in
            self.imageArray = []
            
            self.tabBarController?.tabBar.isHidden = false
            
            self.tabBarController?.selectedIndex = 0
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

