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
    let myGroup = DispatchGroup()
    
    @IBOutlet var collectionView: UICollectionView!
    
    var imageArray: [UIImage] = []
    var foodArray: [String] = []
    var confidenceArray: [String] = []
    var idArray: [String] = []
    
    override func viewDidLoad() {
        print("view Did Load")
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        //call class to get images from server
        self.retrieveImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view Will Appear")
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.retrieveImages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CustomCellClass
        cell.myImage.image = imageArray[indexPath.row]
        cell.myImage.contentMode = .scaleAspectFit
        cell.myImage.contentMode = .scaleAspectFill
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
        print("retrieve image")
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
                    let food:String = (images[i] as! NSDictionary)["Decision"] as! String!
                    let confidence:String = (images[i] as! NSDictionary)["AIconfidence"] as! String!
                    let id:String = (images[i] as! NSDictionary)["id"] as! String!
                    
                    //displaying the data
                    print("imageURL -> ", imageURL)
                    print("food -> ", food)
                    print("confidence -> ", confidence)
                    print("id -> ", id)
                    print("===================")
                    
                    //change url to image
                    let url = URL(string: imageURL)
                    print("url")
                    let data = try? Data(contentsOf: url!)
                    print("data")
                    let image: UIImage! = UIImage(data: data!)
                    print("image")
                    
                    //check if image is already in array
                    var addData = false
                    print("ARRAY SIZE: ", self.imageArray.count)
                    if self.idArray.count > 0 {
                        for info in self.idArray {
                            print("info: ",info)
                            print("id: ",id)
                            if info == id {
                                addData = false
                                break
                                print("DONT ADD DATA TO ARRAY")
                            } else {
                                //add to array
                                addData = true
                                print("ADD DATA TO ARRAY")
                            }
                        }
                    } else {
                        //add to array
                        addData = true
                        print("ADD DATA TO ARRAY")
                    }
                    
                    //check if data is to be added
                    if addData == true {
                        //add to array
                        self.imageArray.append(image)
                        self.foodArray.append(food)
                        self.confidenceArray.append(confidence)
                        self.idArray.append(id)
                        print("DATA IS ADDED TO ARRAY")
                    } else {
                        print("DATA WAS NOT ADDED")
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.collectionView.reloadData()
                    self.collectionView.collectionViewLayout.invalidateLayout()
                })
                print("FINISHED")
                
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
                nextView.image = imageArray[currentIndex]
                nextView.food = foodArray[currentIndex]
                nextView.confidence = confidenceArray[currentIndex]
            }
        }
    }
}
