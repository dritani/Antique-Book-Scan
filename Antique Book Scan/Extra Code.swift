//
//  Extra Code.swift
//  Antique Book Scan
//
//  Created by Dritani on 2017-03-28.
//  Copyright © 2017 AquariusLB. All rights reserved.
//





/*
 import AVFoundation
 AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
 if (authStatus == AVAuthorizationStatusDenied)
 {
 // Denies access to camera, alert the user.
 // The user has previously denied access. Remind the user that we need camera access to be useful.
 
 
 UIAlertController *alertController =
 [UIAlertController alertControllerWithTitle:@"Unable to access the Camera"
 message:@"To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app."
 preferredStyle:UIAlertControllerStyleAlert];
 UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
 [alertController addAction:ok];
 
 [self presentViewController:alertController animated:YES completion:nil];
 }
 else if (authStatus == AVAuthorizationStatusNotDetermined)
 // The user has not yet been presented with the option to grant access to the camera hardware.
 // Ask for it.
 [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
 // If access was denied, we do not set the setup error message since access was just denied.
 if (granted)
 {
 // Allowed access to camera, go ahead and present the UIImagePickerController.
 [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera fromButton:sender];
 }
 }];
 else
 {
 // Allowed access to camera, go ahead and present the UIImagePickerController.
 [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera fromButton:sender];
 }
 
 
 
 if UIImagePickerController.isSourceTypeAvailable(.camera) {
 
 cameraView = CameraSessionView(frame: self.view.frame)
 cameraView.delegate = self
 self.view.addSubview(cameraView)
 
 } else {
 print("Simulator sux. Use a real device")
 let img = UIImageView()
 img.frame = self.view.bounds
 
 
 img.image = UIImage(named:"title.jpg")
 self.view.addSubview(img)
 
 let label = UILabel()
 label.text = "No Camera on Device."
 label.frame = CGRect(origin: CGPoint(x:0,y:0),size: CGSize(width:200,height:100))
 label.textColor = UIColor.red
 label.center = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/2)
 print(self.view.bounds, label.center)
 self.view.addSubview(label)
 }
 
 
 */





/*
 class ParseDTSearchXML : NSObject, XMLParserDelegate {
 
 var parser: XMLParser!
 var priceUrl:String = ""
 var foundUrl:Bool = false
 
 init(data: Data) {
 super.init()
 
 parser = XMLParser(data: data)
 parser.delegate = self
 }
 
 func execute() {
 parser.parse()
 }
 
 func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
 if elementName == "url" {
 foundUrl = true
 }
 }
 
 func parser(_ parser: XMLParser, foundCharacters string: String) {
 if foundUrl {
 priceUrl += string
 }
 }
 
 func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
 
 if elementName == "url" {
 parser.abortParsing()
 }
 }
 
 }
 
 */





/*
 
 
 
 // MARK: Search: DONE
 func callDTSearch(title:String) {
 //let mysteryBook = "the leap the psychology of spiritual awakening steve taylor"
 
 let DTBaseString = "http://www.directtextbook.com/xml_search.php"
 let methodArguments = [
 "key": DTApiKey,
 "query": title,
 ]
 
 let urlString = DTBaseString + formatParameters(parameters: methodArguments as [String : AnyObject])
 print(urlString)
 let url = URL(string: urlString)
 let request = URLRequest(url: url!)
 
 let task = sharedSession.dataTask(with: request) { (data, response, error) in
 
 guard (error == nil) else {
 print("There was an error with your request: \(error)")
 return
 }
 
 guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
 print("Your request returned a status code other than 2xx!")
 return
 }
 
 guard let data = data else {
 print("No data was returned by the request!")
 return
 }
 
 print(data)
 print("success search")
 
 let parser = ParseSearchXML(data: data)
 parser.execute()
 // self.priceUrl is now filled with the next Url
 callDTPrice(identifier:nil,identifierString: nil, priceUrl:parser.priceUrl)
 
 }
 
 task.resume()
 }

 */

/*
 func callDTPrice(identifier:BookIdentifier?,identifierString:String?,priceUrl: String?)
 
 else if priceUrl != nil {
 // have to revamp this to use ISBN and make an actual API call instead of just browsing there
 let url = URL(string: priceUrl!)
 let request = URLRequest(url: url!)
 runRequestDTPrice(request: request)
 }
 */




/*
 // MARK: Search
 func callEBayAPISearch(title:String) {
 /*
 http://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsByKeywords
 &SERVICE-VERSION=1.0.0
 &SECURITY-APPNAME=YourAppID
 &RESPONSE-DATA-FORMAT=XML
 &REST-PAYLOAD
 &keywords=harry%20potter%20phoenix
 
 
 https://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsByProduct&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=JimmyJoh-TestApp-PRD-845f8a2bd-0d3a4b30&RESPONSE-DATA-FORMAT=XML&REST-PAYLOAD&productId.@type=ISBN&productId=9780439785969
 */
 
 // In Response, after Parsing JSON:
 // self.callEBayAPIPrice(identifier: <#T##ViewController.BookIdentifier?#>, identifierNumber: <#T##Int?#>, title: <#T##String?#>)
 
 
 
 // findItemsByKeywords & findItemsByProduct
 
 
 var baseURL = "https://svcs.ebay.com/services/search/FindingService/v1"
 baseURL += "?OPERATION-NAME=findItemsAdvanced"
 baseURL += "&SERVICE-VERSION=1.0.0"
 baseURL += "&SECURITY-APPNAME=\(eBayApiKey)"
 baseURL += "&RESPONSE-DATA-FORMAT=XML"
 baseURL += "&REST-PAYLOAD"
 baseURL += "&keywords="
 baseURL += "&categoryId=267"
 baseURL += title.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
 
 print(baseURL)
 
 
 let url = URL(string:baseURL)
 
 // ISBN UPC, EAN
 // ...&productId.@type=ISBN&productId=1234567890...
 print("success eBay")
 
 
 let request = URLRequest(url: url!)
 let task = sharedSession.dataTask(with: request) { (data, response, error) in
 
 guard (error == nil) else {
 print("There was an error with your request: \(error)")
 return
 }
 
 guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
 print("Your request returned a status code other than 2xx!")
 
 return
 }
 
 guard let data = data else {
 print("No data was returned by the request!")
 return
 }
 
 print(data)
 print("success eBay Search")
 
 // <productId type="ReferenceID">78413115</productId> get the type and the number. make type uppercase, convert to enum BookIdentifier, callebayapiprice
 
 
 }
 
 task.resume()
 
 }
 
 
 */



/*
 // MARK: Search
 func callAmazonAPISearch(title:String) {
 // itemSearch & itemLookup
 
 
 let regionURL =  "webservices.amazon.com"
 let onca = "/onca/xml"
 
 let date = Date()
 let AWSDateISO8601DateFormat3 = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
 let dateFormatter = DateFormatter()
 dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
 dateFormatter.dateFormat = AWSDateISO8601DateFormat3 //"YYYY-MM-dd'T'HH:mm:ss'Z'"
 dateFormatter.locale = Locale(identifier: "en_US_POSIX")
 var timeString = dateFormatter.string(from: date)
 timeString = timeString.replacingOccurrences(of: ":", with: "%3A")
 
 
 /*
 http://webservices.amazon.com/onca/xml?AWSAccessKeyId=AKIAIMOBACH47QDU3L2Q&AssociateTag=lithiumlover2-20&Keywords=harry%20potter%20sorcerer&Operation=ItemSearch&SearchIndex=Books&Service=AWSECommerceService&Timestamp=2017-03-26T13%3A57%3A54.000Z&Signature=euDZVjjyj0s6vTUh3P5MGvuJU7Tal00Vf%2BR4TU36Ne0%3D
 */
 
 let allowedString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_.~"
 let charSet = CharacterSet(charactersIn:allowedString)
 
 let title2 = title.addingPercentEncoding(withAllowedCharacters: charSet)!
 print(title2)
 
 let array = ["AWSAccessKeyId=\(AWSAccessKeyId)",
 "AssociateTag=\(AmazonAssociatesTag)",
 "Keywords=\(title2)",
 "Operation=ItemSearch",
 "SearchIndex=Books",
 "Service=AWSECommerceService",
 "Timestamp=\(timeString)",
 "Version=2013-08-01"]
 
 let string = array.joined(separator: "&")
 var canonicalString = "GET\n"
 canonicalString += regionURL + "\n"
 canonicalString += onca + "\n"
 canonicalString += string
 
 let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
 let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
 
 CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), AWSSecretKey, AWSSecretKey.characters.count, canonicalString, canonicalString.characters.count, result)
 
 let encodedSignatureData = NSData(bytes: result, length: digestLen)
 var encodedSignatureString = encodedSignatureData.base64EncodedString()
 
 
 
 encodedSignatureString = encodedSignatureString.addingPercentEncoding(withAllowedCharacters: charSet)!
 
 let finalURL = "https://" + regionURL + onca + "?" + string + "&Signature=" + encodedSignatureString
 print(finalURL)
 
 
 
 // In Response, after Parsing XML:
 
 }
 
 
 */


// callAmazonAPISearch(title:title!)
// callEBayAPISearch(title:title!)
// http only; will need server-side
// callDTSearch(title:title!)





/*
 let title:String? = "book"
 // get title here
 var identifierNumber:Int?
 var identifier:BookIdentifier?
 
 // push to next screen with the tableview, and when THAT activates viewDidLoad, callMarketplaceAPIs
 for ii in industryIdentifiers {
 switch (ii["type"] as! String) {
 case "ISBN_13":
 identifier = BookIdentifier.ISBN_13
 identifierNumber = ii["identifier"] as? Int
 callMarketplaceAPIs(identifier:identifier,identifierNumber:identifierNumber,title:nil)
 case "ISBN_10":
 identifier = BookIdentifier.ISBN_10
 identifierNumber = ii["identifier"] as? Int
 callMarketplaceAPIs(identifier:identifier,identifierNumber:identifierNumber,title:nil)
 case "EAN":
 identifier = BookIdentifier.EAN
 identifierNumber = ii["identifier"] as? Int
 callMarketplaceAPIs(identifier:identifier,identifierNumber:identifierNumber,title:nil)
 case "UPC":
 identifier = BookIdentifier.UPC
 identifierNumber = ii["identifier"] as? Int
 callMarketplaceAPIs(identifier:identifier,identifierNumber:identifierNumber,title:nil)
 case "OCLC":
 identifier = BookIdentifier.OCLC
 identifierNumber = ii["identifier"] as? Int
 callMarketplaceAPIs(identifier:identifier,identifierNumber:nil,title:title)
 case "LCCN":
 identifier = BookIdentifier.LCCN
 identifierNumber = ii["identifier"] as? Int
 callMarketplaceAPIs(identifier:identifier,identifierNumber:nil,title:title)
 default:
 callMarketplaceAPIs(identifier:nil,identifierNumber:nil,title:title)
 }
 }
 */


/*
 func callMarketplaceAPIs(identifier:BookIdentifier?,identifierString:String?,title:String?) {
 if (identifier == BookIdentifier.ISBN_13 || identifier == BookIdentifier.ISBN_10 || identifier == BookIdentifier.EAN || identifier == BookIdentifier.UPC) {
 callAmazonAPIPrice(identifier:identifier,identifierString: identifierString)
 callEBayAPIPrice(identifier:identifier,identifierString:identifierString)
 // http only; will need server-side
 callDTAPIPrice(identifier:identifier,identifierString:identifierString)
 } else {
 print("damn")
 
 }
 }
 
 */



/*
 import CoreImage
 import CoreGraphics
 import CocoaImageHashing
 
 
 typealias OSHashType = Int64
 typealias OSHashDistanceType = Int64
 typealias OSImageId = NSString
 
 
 
 let image2 = UIImage(named:"gtg")
 let image3 = UIImage(named:"5love.png")
 let image4 = UIImage(named:"gtg.png")
 
 
 var bookCoverProcessed: CIImage!
 let options: [String : AnyObject] = [CIDetectorAccuracy: CIDetectorAccuracyHigh as AnyObject]
 let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)
 let features = detector?.features(in: CIImage(image:image4!)!)
 
 var hash0:OSHashType!
 if features?.count != 0 {
 
 let rectangularFeature = features?.first as! CIRectangleFeature
 
 let imageAsCIImage = CIImage(image:image4!)
 
 print(rectangularFeature.bounds)
 bookCoverProcessed = imageAsCIImage!.applyingFilter(
 "CIPerspectiveTransformWithExtent",
 withInputParameters: [
 "inputExtent": CIVector(cgRect: imageAsCIImage!.extent),
 "inputTopLeft": CIVector(cgPoint: rectangularFeature.topLeft),
 "inputTopRight": CIVector(cgPoint: rectangularFeature.topRight),
 "inputBottomLeft": CIVector(cgPoint: rectangularFeature.bottomLeft),
 "inputBottomRight": CIVector(cgPoint: rectangularFeature.bottomRight)])
 bookCoverProcessed = (imageAsCIImage?.cropping(to: bookCoverProcessed.extent))!
 
 
 // take largest one, pass it on to amazon call, and compare the has for both  the rectangle and the main image.
 
 
 /*let resultImage:CIImage? = drawHighlightOverlayForPoints(image: imageAsCIImage!, topLeft: rectangularFeature.topLeft, topRight: rectangularFeature.topRight,
 bottomLeft: rectangularFeature.bottomLeft, bottomRight: rectangularFeature.bottomRight)
 */
 
 let imageView = UIImageView(frame: self.view.frame)
 imageView.image = UIImage(ciImage:bookCoverProcessed!)
 //self.view.addSubview(imageView)
 
 
 var cg:CGImage!
 let context = CIContext(options: nil)
 cg = context.createCGImage(bookCoverProcessed, from: bookCoverProcessed.extent)
 let ui = UIImage(cgImage: cg)
 hash0 = OSImageHashing<AnyObject>.sharedInstance().hashImage(ui)
 
 
 }
 
 
 let hash1 = OSImageHashing<AnyObject>.sharedInstance().hashImage(image!)
 let hash2 = OSImageHashing<AnyObject>.sharedInstance().hashImage(image2!)
 let hash3 = OSImageHashing<AnyObject>.sharedInstance().hashImage(image3!)
 let hash4 = OSImageHashing<AnyObject>.sharedInstance().hashImage(image4!)
 var wtf = OSImageHashing<AnyObject>.sharedInstance().hashDistance(hash1, to: hash2)
 print("leap & lilac ", wtf)
 wtf = OSImageHashing<AnyObject>.sharedInstance().hashDistance(hash1, to: hash0)
 print("leap & 5love ", wtf)
 //wtf = OSImageHashing<AnyObject>.sharedInstance().hashDistance(hash1, to: hash4)
 //print("leap & twisted leap ", wtf)
 // threshold should be 26? minimum distance, that is

 
 func drawHighlightOverlayForPoints(image: CIImage, topLeft: CGPoint, topRight: CGPoint,
 bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
 var overlay = CIImage(color: CIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5))
 overlay = overlay.cropping(to: image.extent)
 overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
 withInputParameters: [
 "inputExtent": CIVector(cgRect: image.extent),
 "inputTopLeft": CIVector(cgPoint: topLeft),
 "inputTopRight": CIVector(cgPoint: topRight),
 "inputBottomLeft": CIVector(cgPoint: bottomLeft),
 "inputBottomRight": CIVector(cgPoint: bottomRight)
 ])
 return overlay.compositingOverImage(image)
 }
 
 func processImage(inputImage:UIImage) {
 
 var outputImage:UIImage = UIImage()
 
 
 let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: nil)
 let features = detector?.features(in: CIImage(image:inputImage)!)
 print(features?.first)
 
 
 //goToLoadingViewController(image: outputImage)
 }

 
 
 
 
 let compressedImage = UIImageJPEGRepresentation(image, 0.3)
 var image2:UIImage! = UIImage(data:compressedImage!)
 
 if (image2.size.width > 2600 || image2.size.height > 2600) {
 let maxDimension = [image2.size.width,image2.size.height].max()
 let factor = maxDimension! / 2590
 let newWidth = ceil((image2.size.width/factor))
 let newHeight = ceil((image2.size.height/factor))
 let newSize = CGSize(width: newWidth, height: newHeight)
 image2 = imageWithImage(image: image2, newSize:newSize)
 }
 
 func imageWithImage(image:UIImage, newSize:CGSize) -> UIImage{
 UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
 image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
 let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
 UIGraphicsEndImageContext()
 return newImage
 }
 
 
 */


