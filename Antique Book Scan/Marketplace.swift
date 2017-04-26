//
//  Marketplace.swift
//  CloudSightExample
//
//  Created by Dritani on 2017-03-26.
//  Copyright © 2017 CloudSight, Inc. All rights reserved.
//

import Foundation

// TODO: Parse the XML results


// MARK: 1) Amazon

//func callAmazonAPIPrice(identifier:BookIdentifier?,identifierString:String?,completion:@escaping ([BookResult]?)->Void) {


func callAmazonAPIPrice(title:String!,subTitle:String?,authors:[String]?,completion:@escaping ([BookResult]?)->Void) {
    // Amazon Product advertising API requires you to log in to 2 Amazon services:
    // AWS - do not expire
    // Affiliates program - expire every 180 days if you don't drive any sales
    //https://affiliate-program.amazon.com/microsite/mobile
    

    /*
    var IdType = ""
    
    if (identifier != nil) {
        switch identifier! {
        case .ISBN_13:
            IdType = "ISBN"
        case .ISBN_10:
            IdType = "ISBN"
        case .UPC:
            IdType = "UPC"
        case .EAN:
            IdType = "EAN"
        default:
            break
        }
    }
     */
    
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
    
    
    // http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&Operation=ItemSearch&SubscriptionId=AKIAIEBWPIID5427ONVA&AssociateTag=lithiumlover2-20&SearchIndex=Books&Keywords=5 love languages&ResponseGroup=Images,ItemAttributes,Offers,OfferSummary
    
    // itemLookup
    /*
    let array = ["AWSAccessKeyId=\(AWSAccessKeyId)",
        "AssociateTag=\(AmazonAssociatesTag)",
        "IdType=\(IdType)",
        "ItemId=\(identifierString!)",
        "Operation=ItemLookup",
        "ResponseGroup=Images%2CItemAttributes%2COffers%2COfferSummary",
        "SearchIndex=Books",
        "Service=AWSECommerceService",
        "Timestamp=\(timeString)",
        "Version=2013-08-01"]
    */
    
    
    
    
    // &Keywords=5%20love%20languages
    // keywords -> convert to %20 and shit
    // itemSearch
    
    
    let subtitle = (subTitle != nil) ? " " + subTitle! : ""
    let author = (authors != nil) ? " " + authors![0] : ""
    var keywords = title + subtitle + author
    
    let allowedString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_.~"
    let charSet = CharacterSet(charactersIn:allowedString)
    keywords = keywords.addingPercentEncoding(withAllowedCharacters: charSet)!
    
    let array = ["AWSAccessKeyId=\(AWSAccessKeyId)",
        "AssociateTag=\(AmazonAssociatesTag)",
        "Keywords=\(keywords)",
        "Operation=ItemSearch",
        "ResponseGroup=ItemAttributes%2COffers%2COfferSummary",
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
    
    let url = URL(string: finalURL)
    let request = URLRequest(url: url!)
    
    print("Amazon URL\n", finalURL)
    
    let task = sharedSession.dataTask(with: request) { (data, response, error) in
        
        guard (error == nil) else {
            completion(nil)
            print("There was an error with your request: \(error)")
            return
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            print("Your request returned a status code other than 2xx!")
            completion(nil)
            return
        }
        
        guard let data = data else {
            print("No data was returned by the request!")
            completion(nil)
            return
        }
        
        
        print("success amazon price")
        
        
        // parsing: same as before, no need for isbn really
        let parser = ParseAmazonXML(data: data)
        parser.execute()
        print(parser.bookResults)
        completion(parser.bookResults)
        
        return
    }
    
    task.resume()
    
}

// MARK: 2) eBay

func callEBayAPIPrice(title:String!,subTitle:String?,authors:[String]?,completion:@escaping ([BookResult]?)->Void) {
    //findItemsByProduct
    
    /*
    var iden:String = ""
    
    if (identifier != nil) {
        switch identifier! {
            case .ISBN_13:
                iden = "ISBN"
            case .ISBN_10:
                iden = "ISBN"
            case .UPC:
                iden = "UPC"
            case .EAN:
                iden = "EAN"
            case .REFERENCEID:
                iden = "REFERENCEID"
            default:
                break
        }
    
    
    // look for category = book,
    // look for condition = 1000 or not
    // then take price
    
    var baseURL = "https://svcs.ebay.com/services/search/FindingService/v1"
    baseURL += "?OPERATION-NAME=findItemsByProduct"
    baseURL += "&SERVICE-VERSION=1.0.0"
    baseURL += "&SECURITY-APPNAME=\(eBayApiKey)"
    baseURL += "&RESPONSE-DATA-FORMAT=XML"
    baseURL += "&REST-PAYLOAD"
    baseURL += "&productId.@type=\(iden)"
    baseURL += "&productId=\(identifierString!)"
    
    */

    let subtitle = (subTitle != nil) ? " " + subTitle! : ""
    let author = (authors != nil) ? " " + authors![0] : ""
    var keywords = title + subtitle + author
    
    let allowedString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_.~"
    let charSet = CharacterSet(charactersIn:allowedString)
    keywords = keywords.addingPercentEncoding(withAllowedCharacters: charSet)!
    
    var baseURL = "https://svcs.ebay.com/services/search/FindingService/v1"
    baseURL += "?OPERATION-NAME=findItemsAdvanced"
    baseURL += "&SERVICE-VERSION=1.0.0"
    baseURL += "&SECURITY-APPNAME=\(eBayApiKey)"
    baseURL += "&RESPONSE-DATA-FORMAT=XML"
    baseURL += "&REST-PAYLOAD"
    baseURL += "&keywords=\(keywords)"
    baseURL += "&categoryId=267"
    
    print("eBay URL\n", baseURL)
    
    let url = URL(string:baseURL)

    let request = URLRequest(url: url!)
    let task = sharedSession.dataTask(with: request) { (data, response, error) in
        
        guard (error == nil) else {
            completion(nil)
            print("There was an error with your request: \(error)")
            return
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            completion(nil)
            print("Your request returned a status code other than 2xx!")
            return
        }
        
        guard let data = data else {
            completion(nil)
            print("No data was returned by the request!")
            return
        }
        
        print("success eBay Price")
        
        let parser = ParseEBayXML(data: data)
        parser.execute()
        completion(parser.bookResults)
        return
    }

    task.resume()

}



// MARK: 3) DT

// Use Heroku since only DT is http only

/*
    func callHeroku(image:UIImage) {
        let compressedImage = UIImageJPEGRepresentation(image, 0.25)
        let finalImage = UIImage(data:compressedImage!)
        
        //print(compressedImage)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        self.session = URLSession(configuration: configuration)
        
        let params = [
            "image": finalImage,
            ]
        
        let request = URLRequest.request(URL(string:backendURL)!, method: .POST, params: params as [String : AnyObject])
        
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if let error = self.decodeResponse(urlResponse, error: error as NSError?) {
                    print("DAMN")
                    return
                }
                
                print("success")
                
                //                do {
                //                    let res = try JSONSerialization.data(withJSONObject: data, options: [])
                //                    print(res)
                //                } catch {
                //                    print("Could not parse JSON")
                //                }
            }
        }
        
        task.resume()
    }
    
    func decodeResponse(_ response: URLResponse?, error: NSError?) -> NSError? {
        if let httpResponse = response as? HTTPURLResponse
            , httpResponse.statusCode != 200 {
            return error ?? NSError.networkingError(httpResponse.statusCode)
        }
        return error
    } 

*/



func callDTAPIPrice(identifier:BookIdentifier?,identifierString:String?,completion:@escaping ([BookResult]?)->Void) {
    
    
    if identifierString != nil {
        let DTBaseString = "http://www.directtextbook.com/xml.php"
        let parameters = [
            "key": DTApiKey,
            "isbn": identifierString!,
            ] as [String : Any]
        
        let urlString = DTBaseString + formatParameters(parameters: parameters as [String : AnyObject])
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
            
            print("success price")
            
            let parser = ParseDTXML(data: data)
            parser.execute()
            completion(parser.bookResults)
            
        }
        task.resume()
    }
    
}

func formatParameters(parameters: [String : AnyObject]) -> String {
    
    var urlVars = [String]()
    
    for (key, value) in parameters {
        
        let stringValue = "\(value)"
        let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        urlVars += [key + "=" + "\(escapedValue!)"]
    }
    
    return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
}
