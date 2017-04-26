//
//  Google Books.swift
//  CloudSightExample
//
//  Created by Dritani on 2017-03-26.
//  Copyright © 2017 CloudSight, Inc. All rights reserved.
//

import Foundation


// MARK: Google Books

enum BookIdentifier {
    case ISBN_13
    case ISBN_10
    case EAN
    case UPC
    case REFERENCEID
    case OCLC
    case LCCN
}

struct BookData {

    var bookTitle:String!
    var subTitle:String?
    var authors:[String]?
    var coverURL:String?

    init(bookTitle:String,subTitle:String?,authors:[String]?,coverURL:String?) {
        self.bookTitle = bookTitle
        self.subTitle = subTitle
        self.authors = authors
        self.coverURL = coverURL!
    }
}

func callGoogleBooks(finalText:String,completion:@escaping (_ status:String,_ bookData:BookData?)->Void) {
    
    let googleURL = "https://www.googleapis.com/books/v1/volumes?q="+finalText
    print(googleURL)
    let url = URL(string: googleURL)

    let request = URLRequest(url: url!)
    
    print("calling google books")
    
    let task = sharedSession.dataTask(with: request) { (data, response, error) in
        
        guard (error == nil) else {
            print("There was an error with your request: \(error)")
            completion("No internet",nil)
            return
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            print("Your request returned a status code other than 2xx!")
            completion("Bad text",nil)
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
        
        
        guard parsedResult["totalItems"] as! Int != 0 else {
            completion("No results",nil)
            return
        }
        
        let items = parsedResult["items"]! as! [[String:AnyObject]]
 
        let ocrWords = finalText.characters.split{$0 == "+"}.map(String.init)
        
        var similarityScores:[Int] = [0,0,0,0,0]
        
        
        for i in 0..<5  {
            let item = items[i]
            
            var similarityScore = 0
            var ocrWords2:[String] = ocrWords
            
            var volumeInfo = item["volumeInfo"] as! [String:AnyObject]
            
            var trimmedString:String
            var lowercasedWords:[String]
            var words:[String]
            
            if volumeInfo["title"] != nil {
                let bookTitle = volumeInfo["title"] as! String
                trimmedString = bookTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                words = trimmedString.characters.split{$0 == " "}.map(String.init)
                lowercasedWords = words.map {$0.lowercased()}
                
                for word in lowercasedWords {
                    if ocrWords2.contains(word) {
                        similarityScore += 1
                        ocrWords2.remove(at: ocrWords2.index(of: word)!)
                    }
                }
            }
            
            if volumeInfo["subtitle"] != nil {
                let subTitle = volumeInfo["subtitle"] as! String
                trimmedString = subTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                words = trimmedString.characters.split{$0 == " "}.map(String.init)
                lowercasedWords = words.map {$0.lowercased()}
                
                for word in lowercasedWords {
                    if ocrWords2.contains(word) {
                        similarityScore += 1
                        ocrWords2.remove(at: ocrWords2.index(of: word)!)
                    }
                }
            }
            
            if volumeInfo["authors"] != nil {
                let authors = volumeInfo["authors"] as! [String]
                
                lowercasedWords = []
                
                for author in authors {
                    trimmedString = author.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    words = trimmedString.characters.split{$0 == " "}.map(String.init)
                    lowercasedWords += words.map {$0.lowercased()}
                }
                
                
                for word in lowercasedWords {
                    if ocrWords2.contains(word) {
                        similarityScore += 1
                        ocrWords2.remove(at: ocrWords2.index(of: word)!)
                    }
                }
            }

            similarityScores[i] = similarityScore
            //print(similarityScore)
        }
        
        print(similarityScores)
        // do a linear search. find biggest values. pick one with smallest index (i.e. closest to the top, and check if ebook)
        var maxScoreIndices:[Int] = []
        var maxScore = -1
        for index in 0..<5 {
            if (similarityScores[index]>maxScore) {
                maxScore = similarityScores[index]
                maxScoreIndices = [index]
            } else if (similarityScores[index] == maxScore) {
                maxScoreIndices.append(index)
            }
        }

        var trueIndex = 0
        
        for index in maxScoreIndices {
            let item = items[index]
            let saleInfo = item["saleInfo"] as! [String:AnyObject]
            let isEbook = saleInfo["isEbook"] as! Bool
            if isEbook == false {
                trueIndex = index
                break
            }
        }
        
        
        let trueItem = items[trueIndex]
        
        let volumeInfo = trueItem["volumeInfo"] as! [String:AnyObject]
        let industryIdentifiers = volumeInfo["industryIdentifiers"] as! [[String:AnyObject]]
        let imageLinks = volumeInfo["imageLinks"] as! [String:AnyObject]

        
        //completion: bookTitle, subTitle, authors[0], all words separated by space
        //let identifier:BookIdentifier = .ISBN_13
        //let identifierString = industryIdentifiers[0]["identifier"]! as! String
        
        
        let bookTitle = volumeInfo["title"] as! String
        let subTitle:String? = volumeInfo["subtitle"] != nil ? volumeInfo["subtitle"] as! String? : nil
        let authors:[String]? = volumeInfo["authors"] != nil ? volumeInfo["authors"] as! [String]? : nil
        var coverURL:String? = imageLinks["thumbnail"] != nil ? imageLinks["thumbnail"] as! String? : nil
    
        let index = coverURL?.index((coverURL?.startIndex)!, offsetBy: 4)

        if coverURL?[index!] == ":" {
            coverURL = "https" + (coverURL?.substring(from: index!))!
        }
        
        let bookData = BookData(bookTitle:bookTitle,subTitle:subTitle,authors:authors,coverURL:coverURL)

        completion("success",bookData)
        print("success google books")
        return
    }
    
    task.resume()
    
}
