//
//  OCR.swift
//  CloudSightExample
//
//  Created by Dritani on 2017-03-26.
//  Copyright © 2017 CloudSight, Inc. All rights reserved.
//

import Foundation

// MARK: 1) Ocr.space

func imageWithImage(image:UIImage, newSize:CGSize) -> UIImage{
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0);
    image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
}


func callOCR(image:UIImage,completion:@escaping (_ status:String,_ googleURL:String?)->Void) {
    
    let baseURL = URL(string: "https://api.ocr.space/parse/image")
    
    var request = URLRequest(url:baseURL!)
    request.httpMethod = "POST"

    let name = "ttt.jpg"
    
    let boundary: String = "randomString"
    request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    var image2:UIImage! = image
    
    if (image2.size.width > 2590 || image2.size.height > 2590) {
        let maxDimension = [image2.size.width,image2.size.height].max()
        let factor = maxDimension! / 2590
        let newWidth = ceil((image2.size.width/factor))
        let newHeight = ceil((image2.size.height/factor))
        let newSize = CGSize(width: newWidth, height: newHeight)
        image2 = imageWithImage(image: image2, newSize:newSize)
    }
    
    let imageData: Data = UIImageJPEGRepresentation(image2, 0.25)!
    
    let parametersDictionary:[String:String] = ["apikey":ocrSpaceKey]
    
    let data: Data = createBodyWithBoundary(boundary: boundary, parameters: parametersDictionary, imageData: imageData, filename: name)
    request.httpBody = data
    
    completion("uploading",nil)
    print("uploading")
    
    let task = sharedSession.dataTask(with: request) { (data, response, error) in
        
        guard (error == nil) else {
            print("There was an error with your request: \(error)")
            completion("No internet",nil)
            return
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            print("Your request returned a status code other than 2xx!")
            // if image has no text, this is the response
            completion("Bad image",nil)
            return
        }
        
        guard let data = data else {
            print("No data was returned by the request!")
            completion("Server error",nil)
            return
        }
        
        let parsedResult: [String:AnyObject]
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        } catch {
            print("Could not parse the data as JSON: '\(data)'")
            completion("Bad response",nil)
            return
        }
        
        print(parsedResult)
        let exitCode = parsedResult["OCRExitCode"] as! Int
        
        if exitCode != 1 {
            completion("Bad image",nil)
            return
        }
        
        let parsedResults = parsedResult["ParsedResults"]! as! [[String:AnyObject]]
        
        let parsedText = parsedResults[0]["ParsedText"] as! String
        

        let finalText = cleanUpOCRText(text:parsedText)
        
        completion("success",finalText)
        print("success OCR.space")
        return
    }
    
    task.resume()
    
}

func createBodyWithBoundary(boundary: String, parameters: [String : String], imageData data: Data, filename: String) -> Data {
    let body:NSMutableData = NSMutableData()
    
    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
    body.append("Content-Disposition: form-data; name=\"\("file")\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
    body.append("Content-Type: image/jpeg\r\n\r\n".data(using:String.Encoding.utf8)!)
    body.append(data)
    body.append("\r\n".data(using: String.Encoding.utf8)!)
    
    
    for key in parameters.keys {
        body.append("--\(boundary)\r\n".data(using:String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using:String.Encoding.utf8)!)
        body.append("\(parameters[key])\r\n".data(using:String.Encoding.utf8)!)
    }
    
    body.append("--\(boundary)--\r\n".data(using:String.Encoding.utf8)!)
    
    return body as Data
}


/*
 divide by each line
 for each line in lines:
 if \n in front, remove it
 split according to space, strip space before and after, put in words array
 if array contains "new" and "york" and "times" or "bestseller"
 ignore
 if it contains symbols not in aA1-
 ignore
 else, add to words you will keep
 for word in words: unite with space bardivide by each line
 */
func cleanUpOCRText(text:String)->String {
    
    var toAdd:Bool = true
    var finalWordsArray:[String] = []
    let alphaNumerical = "abcdefghijklmnopqrstuvwxyz1234567890-"

    let lines = text.characters.split { $0 == "\n" || $0 == "\r\n" }.map(String.init)
    
    for line in lines {
        let trimmedString = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let words = trimmedString.characters.split{$0 == " "}.map(String.init)
        
        let lowercasedWords = words.map {$0.lowercased()}
        
        let bannedWords:[String] = ["bestseller","foreword","copyright","copyrighted","author","edition","•"]//"the","by","of","an"
        
        if (lowercasedWords.contains("new") && lowercasedWords.contains("york") && lowercasedWords.contains("times")) {
            
        } else {
            for word in lowercasedWords {
                toAdd = true
                
                for badWord in bannedWords {
                    if word == badWord {
                        toAdd = false
                    }
                }
                for char in word.characters {
                    if !alphaNumerical.contains(String(char)) {
                        toAdd = false
                    }
                }
                
                if word.characters.count == 1 && !(word.characters.first == "a" || word.characters.first == "i" ) {
                    toAdd = false
                }
                
                if toAdd {
                    finalWordsArray.append(word)
                }
            }
        }
    }
    
    
    // if too long (>8), take the middle words
    
    // looking at google's response, first 5 let's say, make a score of the one with the most similarity looking at author and title
    
    // if all else fails, do another google search and look for amazon top one
    // do a google search also, parse html, look at first result: if amazon, compare similarity of titles.
    // do another search with amazon, and THEN go to next screen
    
    var removalIndex:Int = 1
    
    while finalWordsArray.count > 8 {
        if removalIndex == 1 {
            finalWordsArray.remove(at: 0)
            removalIndex = 2
        } else {
            finalWordsArray.remove(at: finalWordsArray.count - 1)
            removalIndex = 1
        }
    }
    
    return finalWordsArray.joined(separator: "+")
    
    
}





