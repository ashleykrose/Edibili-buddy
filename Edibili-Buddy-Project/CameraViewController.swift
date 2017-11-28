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

class CameraViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, holdImagesToSendToAI {
    
    @IBOutlet weak var captureButton: SwiftyRecordButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var cameraRollButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    
    var delegate: holdImagesToSendToAI?
    var imageArray: [UIImage] = []
    var sendToAI: Bool = false
    var imagePicked: Bool = false
    
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
        print("imagePicked: ", imagePicked)
        if imagePicked {
            imagePicked = false
            let alert = UIAlertController(title: "From Camera Roll", message: "Picture Added To List", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Add More Pictures", style: UIAlertActionStyle.default, handler: nil))
            alert.addAction(UIAlertAction(title: "Send Pictures", style: UIAlertActionStyle.default, handler: { action in
                self.sendPicturesToAI()
            }))
            self.present(alert, animated: true, completion: nil)
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
        print("Array Size: ", imageArray.count)
        if imageArray.count != 0 {
            let alert = UIAlertController(title: "Cancel Clicked", message: "If you leave page you will lose all your pictures", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Stay", style: UIAlertActionStyle.default, handler: nil))
            alert.addAction(UIAlertAction(title: "Leave", style: UIAlertActionStyle.cancel, handler: { action in
                self.imageArray = []
                
                self.tabBarController?.tabBar.isHidden = false
                
                self.tabBarController?.selectedIndex = 0
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.imageArray = []
            
            self.tabBarController?.tabBar.isHidden = false
            
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    //adds image from camera roll to list of images to send to AI
    @IBAction func openPhotoLibraryButton(sender: AnyObject) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("can't open photo library")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageArray.append(image)
            self.imagePicked = true
        } else{
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendPicturesToAI() {
        //this is where we are sending the image to the AI.
        //backgroundImage is the image to send to the AI
        //empty imageArray after sending them to the AI
        for picture in imageArray {
            myImageUploadRequest(myImage: picture)
        }
        imageArray = []
        //pass delegate back
        self.tabBarController?.tabBar.isHidden = false
        //after it is sent to the ai we need to go to the gallary
        tabBarController?.selectedIndex = 2
    }
    
    func myImageUploadRequest(myImage: UIImage) {
        let param = [
            "Confidence" : "2",
            "Decision" : "1",
        ]
        let myUrl = NSURL(string: "http://18.221.34.112/connectApp.php");
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST";
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //changed!!!
        let imageData = UIImageJPEGRepresentation(myImage, 1)
        if(imageData==nil)  { return; }
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary)
//        myActivityIndicator.startAnimating();
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                return
            }
            // You can print out response object
            print("******* response = \(response)")
            // Print out reponse body
            print("-------DATA: \(data)")
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                print(json)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        var body = Data();
        if parameters != nil {
            for (key, value) in parameters! {
                body.append(Data("--\(boundary)\r\n".utf8))
                body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
                body.append(Data("\(value)\r\n".utf8))
            }
        }
        let filename = "user-profile.jpg"
        let mimetype = "image/jpg"
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".utf8))
        body.append(Data("Content-Type: \(mimetype)\r\n\r\n".utf8))
        body.append(imageDataKey as Data)
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundary)--\r\n".utf8))
        return body
    }
}

