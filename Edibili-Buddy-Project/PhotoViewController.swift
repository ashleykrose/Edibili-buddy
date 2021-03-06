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

class PhotoViewController: UIViewController, holdImagesToSendToAI {
    
    var delegate: holdImagesToSendToAI
    var imageArray: [UIImage]

	override var prefersStatusBarHidden: Bool {
		return true
	}

	private var backgroundImage: UIImage

    init(image: UIImage, delegate: holdImagesToSendToAI, imageArray: [UIImage]) {
		self.backgroundImage = image
        self.delegate = delegate
        self.imageArray = imageArray
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    func pass(uiImageArray: [UIImage], sendImages: Bool) { //conforms to protocol
        imageArray = uiImageArray
    }

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.gray
		let backgroundImageView = UIImageView(frame: view.frame)
		backgroundImageView.contentMode = UIViewContentMode.scaleAspectFit
		backgroundImageView.image = backgroundImage
		view.addSubview(backgroundImageView)
		let cancelButton = UIButton(frame: CGRect(x: 30.0, y: 30.0, width: 30.0, height: 30.0))
		cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControlState())
		cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
		view.addSubview(cancelButton)
        let checkButton = UIButton(frame: CGRect(x: view.frame.width - 70.0, y: view.frame.height - 70.0, width: 30.0, height: 30.0))
        checkButton.setImage(#imageLiteral(resourceName: "check"), for: UIControlState())
        checkButton.addTarget(self, action: #selector(check), for: .touchUpInside)
        view.addSubview(checkButton)
        imageArray.append(backgroundImage)
	}

	func cancel() {
		dismiss(animated: true, completion: nil)
	}
    
    func check() {
        //check if there will be more images to send or if these are the only ones to send
        let alert = UIAlertController(title: "Send Clicked", message: "Picture Added To List", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Add More Pictures", style: UIAlertActionStyle.default, handler: { action in
            self.dismiss(animated: true, completion: nil)
            self.addMorePictures()
        }))
        alert.addAction(UIAlertAction(title: "Send Pictures", style: UIAlertActionStyle.default, handler: { action in
            self.dismiss(animated: true, completion: nil)
            self.sendPicturesToAI()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendPicturesToAI() {
        //this is where we are sending the image to the AI.
        //backgroundImage is the image to send to the AI
        //empty imageArray after sending them to the AI
        print("SEND PICTURES TO AI")
        for picture in imageArray {
            print("IN ARRAY")
            myImageUploadRequest(myImage: picture)
        }
        imageArray = []
        //pass delegate back
        delegate.pass(uiImageArray: imageArray, sendImages: true)
    }
    
    func addMorePictures() {
        delegate.pass(uiImageArray: imageArray, sendImages: false)
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
