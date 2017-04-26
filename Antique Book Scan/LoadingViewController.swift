//
//  ViewController.swift
//  CloudSightExample
//

import UIKit
import CloudSight
import HGCircularSlider

class LoadingViewController: UIViewController, UINavigationControllerDelegate, CloudSightQueryDelegate {
    var image:UIImage!// = UIImage(named:"title.jpg")
    var rangeCircularSlider: RangeCircularSlider!
    var centerLabel:UILabel!
    var backButton:UIButton!
    var OCRspeed = 2
    var progressTimer: Timer!
    var endTimer: Timer!
    var start:Float!
    var limit:Float!
    var speed:Float!
    var cloudsightQuery: CloudSightQuery!

    
    // MARK: Beginning
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        checkAPIkeys()
    }
    
    func addViews() {
        view.backgroundColor = UIColor.black
        
        rangeCircularSlider = RangeCircularSlider()
        rangeCircularSlider.autoresizesSubviews = true
        rangeCircularSlider.isUserInteractionEnabled = false
        rangeCircularSlider.trackFillColor = yellowColor
        rangeCircularSlider.trackColor = UIColor(red: 25/255, green: 23/255, blue: 25/255, alpha: 1.0)
        rangeCircularSlider.endThumbTintColor = UIColor(red: 25/255, green: 23/255, blue: 25/255, alpha: 1.0)
        rangeCircularSlider.diskColor = UIColor.black
        rangeCircularSlider.diskFillColor = UIColor.black
        rangeCircularSlider.lineWidth = 40
        rangeCircularSlider.thumbLineWidth = 10
        var rangeCircularSliderSize = CGSize()
        rangeCircularSliderSize.width = view.bounds.size.width * 0.9
        rangeCircularSliderSize.height = view.bounds.size.width * 0.9
        rangeCircularSlider.frame = CGRect(origin:CGPoint(x:0,y:0),size:rangeCircularSliderSize)
        rangeCircularSlider.center = view.center
        rangeCircularSlider.startThumbImage = UIImage(named: "start")
        rangeCircularSlider.endThumbImage = UIImage(named: "cloud2")
        rangeCircularSlider.maximumValue = CGFloat(100)
        rangeCircularSlider.startPointValue = 0
        rangeCircularSlider.endPointValue = 0
        view.addSubview(rangeCircularSlider)
        
        centerLabel = UILabel()
        centerLabel.isOpaque = false
        centerLabel.text = "Starting"
        centerLabel.textAlignment = .center
        centerLabel.font = UIFont(name: "AvenirNext-Regular", size: 25)
        centerLabel.textColor = UIColor.white
        centerLabel.sizeToFit()
        centerLabel.adjustsFontSizeToFitWidth = true
        centerLabel.center = view.center
        view.addSubview(centerLabel)
        view.bringSubview(toFront: centerLabel)
        
        /*
        rangeCircularSlider.endThumbImage = UIImage(named: "eye")
        rangeCircularSlider.endPointValue = 35
        centerLabel.text = "Scanning"
        */
        
        backButton = UIButton()
        backButton.isHidden = true
        backButton.setImage(UIImage(named: "backButton.png"), for: .normal)
        let backButtonSize = CGSize(width:50,height:27)
        backButton.frame = CGRect(origin:CGPoint(x:0,y:0),size: backButtonSize)
        backButton.center = rangeCircularSlider.center
        backButton.center.y += rangeCircularSlider.frame.height/2 + backButton.frame.height/2 + 40
        backButton.addTarget(self, action: #selector(self.returnToCamera), for: .touchUpInside)
        view.addSubview(backButton)
        _ = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: false, block: {_ in
            self.backButton.isHidden = false
        })

    }
    
    func checkAPIkeys() {
        
        if ocrSpaceKey != "" {
            startProcess()
        } else if UserDefaults.standard.value(forKey:"ocrspace") != nil {
            ocrSpaceKey = UserDefaults.standard.value(forKey: "ocrspace") as! String
            DTApiKey = UserDefaults.standard.value(forKey: "directtextbook") as! String
            eBayApiKey = UserDefaults.standard.value(forKey: "ebay") as! String
            AWSAccessKeyId = UserDefaults.standard.value(forKey: "amazonaccess") as! String
            AWSSecretKey = UserDefaults.standard.value(forKey: "amazonsecret") as! String
            AmazonAssociatesTag = UserDefaults.standard.value(forKey: "amazonassociate") as! String
            cloudsightKey = UserDefaults.standard.value(forKey: "cloudsightkey") as! String
            cloudsightSecret = UserDefaults.standard.value(forKey: "cloudsightsecret") as! String
            // app done.
            startProcess()
        } else {
            rangeCircularSlider.endThumbImage = UIImage(named: "error2")
            rangeCircularSlider.endPointValue += 0.01
            centerLabel.text = "No internet"
            endTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {_ in
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func startProcess() {
        
        OCRspeed = UserDefaults.standard.integer(forKey: "speed")
        
        if (OCRspeed == 1) {
            updateUIStartedUploading()
            callCloudSight()
        } else if (OCRspeed == 2) {
            callOCR(image: image,completion:{status,googleURL in
                switch status {
                    case "uploading":
                        DispatchQueue.main.async {
                            self.updateUIStartedUploading()
                        }
                    case "success":
                        DispatchQueue.main.async {
                            self.updateUIFinishedIdentifying()
                        }
                        
                        callGoogleBooks(finalText:googleURL!,completion:{status,bookData in
                            if status == "success" {
                                DispatchQueue.main.async {
                                    self.updateUIFinishedBookName(status:status,bookData:bookData)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.updateUIerror(error: status)
                                }
                            }
                        })
                    case "No internet","Bad image","Server error","Bad reponse":
                        DispatchQueue.main.async {
                            self.updateUIerror(error:status)
                        }
                    default:
                        break
                } // end switch
            }) // end callOCR and its completion
        } // end if
    }
    
    func updateUIerror(error:String) {
        stopEverything()
        
        self.rangeCircularSlider.endThumbImage = UIImage(named: "error2")
        self.rangeCircularSlider.endPointValue += 0.01
        self.centerLabel.text = error
        
        self.endTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {_ in
            self.returnToCamera()
        })
    }
    
    func stopEverything() {
        if self.progressTimer != nil {
            self.progressTimer.invalidate()
            self.progressTimer = nil
        }
        
        if self.endTimer != nil {
            self.endTimer.invalidate()
            self.endTimer = nil
        }
        
        sharedSession.getTasksWithCompletionHandler({(datatasks,uploadtasks,downloadtasks) in
            for datatask in datatasks {
                datatask.cancel()
            }
            for uploadtask in uploadtasks {
                uploadtask.cancel()
            }
            for downloadtask in downloadtasks {
                downloadtask.cancel()
            }
        })
    }
    
    func returnToCamera() {
        stopEverything()
        navigationController?.popViewController(animated: true)
    }

    // MARK: UI
    func updateUIStartedUploading() {
        centerLabel.text = "Uploading"
        start = 0
        limit = 25
        if OCRspeed == 1 {
            speed = 0.25
        } else if OCRspeed == 2 {
            speed = 0.75
        }
        
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.increaseSlider), userInfo: nil, repeats: true)
        
    }
    
    func updateUIFinishedUploading() {
        if self.progressTimer != nil {
            centerLabel.text = "Scanning"
            rangeCircularSlider.endThumbImage = UIImage(named: "eye")
            rangeCircularSlider.endPointValue = 25
            self.progressTimer.invalidate()
            self.progressTimer = nil
            start = 25
            limit = 75
            if OCRspeed == 1 {
                speed = 0.1
            } else if OCRspeed == 2 {
                speed = 1.2
            }
            self.progressTimer = Timer.scheduledTimer(timeInterval: 0.025, target: self, selector: #selector(self.increaseSlider), userInfo: nil, repeats: true)
        } else {
            rangeCircularSlider.endThumbImage = UIImage(named: "error2")
        }
        
    }
    
    func updateUIFinishedIdentifying() {
        if self.progressTimer != nil {
            centerLabel.text = "Identifying"
            rangeCircularSlider.endThumbImage = UIImage(named: "book")
            rangeCircularSlider.endPointValue = 75
            self.progressTimer.invalidate()
            self.progressTimer = nil
            
            start = 75
            limit = 100
            speed = 0.3
            self.progressTimer = Timer.scheduledTimer(timeInterval: 0.025, target: self, selector: #selector(self.increaseSlider), userInfo: nil, repeats: true)
        } else {
            rangeCircularSlider.endThumbImage = UIImage(named: "error2")
        }
    }
    
    func updateUIFinishedBookName(status:String,bookData:BookData?) {
        centerLabel.text = "Done"
        rangeCircularSlider.endPointValue = 100
        if self.progressTimer != nil {
            self.progressTimer.invalidate()
            self.progressTimer = nil
        }
        
        print("done")
        
        if (bookData != nil) {
            let resultsVC = ResultsViewController()
            resultsVC.bookData = bookData
            navigationController?.pushViewController(resultsVC, animated: true)
        }
    }
    
    func increaseSlider() {
        
        if (limit == 25.0 && OCRspeed == 2) {
            if Float(rangeCircularSlider.endPointValue) >= limit {
                updateUIFinishedUploading()
            }
            rangeCircularSlider.endPointValue += CGFloat(speed)
            
        } else {
            if (Float(rangeCircularSlider.endPointValue)-start) >= 0.5 * (limit-start) {
                speed = speed/2.0
                start = Float(rangeCircularSlider.endPointValue)
            }
            
            if Float(rangeCircularSlider.endPointValue) >= limit {
                speed = 0.0
            }
            
            rangeCircularSlider.endPointValue += CGFloat(speed)
        }
    }
    
    // MARK: CloudSight
    func callCloudSight() {
        CloudSightConnection.sharedInstance().consumerKey = cloudsightKey
        CloudSightConnection.sharedInstance().consumerSecret = cloudsightSecret
        
        let imageData = UIImageJPEGRepresentation(image!, 1.0)
        
        cloudsightQuery = CloudSightQuery(image: imageData,
                                          atLocation: CGPoint.zero,
                                          withDelegate: self,
                                          atPlacemark: nil,
                                          withDeviceId: "device-id")
        cloudsightQuery.start()
        
        updateCloudSightKeyRemaining()

    }
    
    func updateCloudSightKeyRemaining() {
        ref.observeSingleEvent(of:.value, with: { snapshot in
            if !snapshot.exists() { return }

            let value = snapshot.value as! [String:AnyObject]
            
            if let keys = value["keys"] as? [String:AnyObject] {

                let cloudsight = keys["cloudsight"] as! [String:AnyObject]
                
                
                var maxRemaining = 0
                var maxI = 0
                
                for i in 1...cloudsight.count {
                    
                    print(i)
                    let key = cloudsight["key\(i)"] as! [String:AnyObject]
                    let remaining = key["remaining"] as! Int
                    
                    if remaining > maxRemaining {
                        maxRemaining = remaining
                        maxI = i
                    }
                }
                
                let keyToUse = cloudsight["key\(maxI)"] as! [String:AnyObject]
                cloudsightSecret = keyToUse["secret"] as! String
                
                ref.child("keys").child("cloudsight").child("key\(maxI)").child("remaining").setValue(maxRemaining-1)
                
            }
        })
    }

    func cloudSightQueryDidFinishUploading(_ query: CloudSightQuery!) {
        print("cloudSightQueryDidFinishUploading")
        DispatchQueue.main.async {
            self.updateUIFinishedUploading()
        }
    }
    
    func cloudSightQueryDidFinishIdentifying(_ query: CloudSightQuery!) {
        print("cloudSightQueryDidFinishIdentifying")
        // CloudSight runs in a background thread, and since we're only
        // allowed to update UI in the main thread, let's make sure it does.
        
        DispatchQueue.main.async {
            self.updateUIFinishedIdentifying()
        }
        
        if query.skipReason != nil {
            updateUIerror(error: "Bad image")
        }
        
        print(query.name())
        
        let finalText = cleanUpOCRText(text:query.name())
        
        callGoogleBooks(finalText:finalText,completion:{status,bookData in
            if status == "success" {
                DispatchQueue.main.async {
                    self.updateUIFinishedBookName(status:status,bookData:bookData)
                }
            } else {
                DispatchQueue.main.async {
                    self.updateUIerror(error: status)
                }
            }
        })
    }
    
    func cloudSightQueryDidFail(_ query: CloudSightQuery!, withError error: Error!) {
        print("CloudSight Failure: \(error)")
        updateUIerror(error: "Server error")
    }
}
