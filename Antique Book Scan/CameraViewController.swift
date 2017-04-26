//
//  ViewController.swift
//  Antique Book Scan
//
//  Created by Dritani on 2017-03-14.
//  Copyright © 2017 AquariusLB. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController, CACameraSessionDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {

    var image:UIImage! = UIImage(named:"leap.jpg")
    var cameraView: CameraSessionView!
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        cameraView = CameraSessionView(frame: self.view.frame)
        cameraView.delegate = self
        self.view.addSubview(cameraView)
    }
    
    override func viewWillAppear(_ animated: Bool) {

        ref.observeSingleEvent(of:.value, with: { snapshot in
            if !snapshot.exists() { return }
            let value = snapshot.value as! [String:AnyObject]
            
            if let keys = value["keys"] as? [String:AnyObject] {
                ocrSpaceKey = keys["ocrspace"] as! String
                DTApiKey = keys["directtextbook"] as! String
                eBayApiKey = keys["ebay"] as! String
                AWSAccessKeyId = keys["amazonaccess"] as! String
                AWSSecretKey = keys["amazonsecret"] as! String
                AmazonAssociatesTag = keys["amazonassociate"] as! String
                let cloudsight = keys["cloudsight"] as! [String:AnyObject]
                
                UserDefaults.standard.set(ocrSpaceKey, forKey: "ocrspace")
                UserDefaults.standard.set(DTApiKey, forKey: "directtextbook")
                UserDefaults.standard.set(eBayApiKey, forKey: "ebay")
                UserDefaults.standard.set(AWSAccessKeyId, forKey: "amazonaccess")
                UserDefaults.standard.set(AWSSecretKey, forKey: "amazonsecret")
                UserDefaults.standard.set(AmazonAssociatesTag, forKey: "amazonassociate")

                var maxRemaining = 7
                var maxI = 0
                
                for i in 1...cloudsight.count {
                    
                    let key = cloudsight["key\(i)"] as! [String:AnyObject]
                    let remaining = key["remaining"] as! Int
                    
                    if remaining > maxRemaining {
                        maxRemaining = remaining
                        maxI = i
                    }
                }
                
                if maxRemaining > 7 {
                    let keyToUse = cloudsight["key\(maxI)"] as! [String:AnyObject]
                    cloudsightKey = keyToUse["key"] as! String
                    cloudsightSecret = keyToUse["secret"] as! String
                    UserDefaults.standard.set(cloudsightKey, forKey: "cloudsightkey")
                    UserDefaults.standard.set(cloudsightSecret, forKey: "cloudsightsecret")
                } else {
                    UserDefaults.standard.set(2, forKey: "speed")
                    self.cameraView.hideSnailRabbitButtons()
                }
                
                //self.goToLoadingViewController(image:self.image)
            }
        })
    }
    
    func goToLoadingViewController(image:UIImage) {
        
        let loadingVC = LoadingViewController()
        loadingVC.image = image
        navigationController?.pushViewController(loadingVC, animated: true)
        print("pushed to nextVC")
    }
    
    

    
    // MARK: Camera
    func didCapture(_ image: UIImage) {
        print("image captured")
        goToLoadingViewController(image:image)
    }
    
    // MARK: Photo Album
    func didTapPhotoLibrary() {
        // if iPad, use popover controller?
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("image picked")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("image exists")
            dismiss(animated: true, completion: nil)
            goToLoadingViewController(image: image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("image picker dismissed")
        dismiss(animated: true, completion: nil)
    }
    
}


