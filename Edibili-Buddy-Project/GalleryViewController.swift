//
//  GalleryViewController.swift
//  Edibili-Buddy-Project
//
//  Created by Ashley Roselius on 11/26/17.
//  Copyright © 2017 Ashley Roselius. All rights reserved.
//

import Foundation
import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var currentIndex = -1
    
    @IBOutlet var collectionView: UICollectionView!
    
    //delete!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    var items: [UIImage] = ["😀".image()!,"😁".image()!,"😂".image()!,"😃".image()!,"😄".image()!,"😅".image()!,"😆".image()!,"😇".image()!,"😈".image()!,"👿".image()!,"😉".image()!,"😊".image()!,"😋".image()!,"😌".image()!,"😍".image()!,"😎".image()!,"😏".image()!,"😐".image()!,"😑".image()!,"😒".image()!,"😓".image()!,"😔".image()!,"😕".image()!,"😖".image()!,"😗".image()!,"😘".image()!,"😙".image()!,"😚".image()!,"😛".image()!,"😜".image()!,"😝".image()!,"😞".image()!,"😟".image()!,"😠".image()!,"😡".image()!,"😢".image()!,"😣".image()!,"😤".image()!,"😥".image()!,"😦".image()!,"😧".image()!,"😨".image()!,"😩".image()!,"😪".image()!,"😫".image()!,"😬".image()!,"😭".image()!,"😮".image()!,"😯".image()!,"😰".image()!,"😱".image()!,"😲".image()!,"😳".image()!,"😴".image()!,"😵".image()!,"😶".image()!,"😷".image()!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        //call class to get images from server
        
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CustomCellClass
        cell.myImage.image = items[indexPath.row]
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("indexpath.row", indexPath.row)
        currentIndex = indexPath.row
        performSegue(withIdentifier: "toDetailViewController", sender: nil)
    }
    
    // MARK: - UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let picDimension = self.view.frame.size.width / 4.0
        return CGSize(width: picDimension, height: picDimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftRightInset = self.view.frame.size.width / 14.0
        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
    }
    
    func retrieveImages() {
        let URL_IMAGES:String = "http://18.221.34.112/sendImage.php"
        //created NSURL
        let requestURL = NSURL(string: URL_IMAGES)
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL! as URL)
        
        //setting the method to post
        request.httpMethod = "GET"
        
        //creating a task to send the post request
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            
            //exiting if there is some error
            if error != nil{
                print("error is \(error)")
                return;
            }
            
            //parsing the response
            do {
                //converting resonse to NSDictionary
                var imageJSON: NSDictionary!
                imageJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                //getting the JSON array teams from the response
                let images: NSArray = imageJSON["result"] as! NSArray
                
                //looping through all the json objects in the array teams
                for i in 0 ..< images.count{
                    
                    //getting the data at each index
                    let imageURL:String = (images[i] as! NSDictionary)["path"] as! String!
                    let food:String = (images[i] as! NSDictionary)["id"] as! String!
                    let confidence:Int = (images[i] as! NSDictionary)["AIconfidence"] as! Int!
                    
                    //displaying the data
                    print("imageURL -> ", imageURL)
                    print("food -> ", food)
                    print("confidence -> ", confidence)
                    print("===================")
                    print("")
                    
                }
                
            } catch {
                print(error)
            }
        }
        //executing the task
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailViewController" {
            if let nextView = segue.destination as? DetailViewController {
                nextView.image = items[currentIndex]
                nextView.food = "NO"
                nextView.confidence = 75
            }
        }
    }
}

//delete!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 30, height: 35)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.white.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 30)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
