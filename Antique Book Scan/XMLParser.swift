//
//  XMLParser.swift
//  CloudSightExample
//
//  Created by Dritani on 2017-03-25.
//  Copyright © 2017 CloudSight, Inc. All rights reserved.
//

//<Binding>
//Mass Market Paperback
//trade paperback
//Paperback
//Kindle Edition
//Hardcover

import Foundation

protocol VCDelegate {
    var priceUrl:String? { get set }
}

class ParseAmazonXML : NSObject, XMLParserDelegate {
    
    var parser: XMLParser!
    
    var bookResults:[BookResult]? = []
    var market:String = "amazon"
    var price:Float!
    var condition:String!
    var buyLink:String?

    var foundNew:Bool = false
    var foundUsed:Bool = false
    var foundURL:Bool = false
    var get:Bool = false
    var done:Int = 0
    
    init(data: Data) {
        super.init()
        
        parser = XMLParser(data: data)
        parser.delegate = self
        
    }
    
    func execute() {
        parser.parse()
    }
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "MoreOffersUrl" {
            foundURL = true
        }
        
        if elementName == "LowestNewPrice" {
            foundNew = true
        } else if elementName == "LowestUsedPrice" {
            foundUsed = true
        }
        
        if (foundNew == true || foundUsed == true) {
            if elementName == "FormattedPrice" {
                get = true
            }
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if foundURL == true {
            self.buyLink = string
            foundURL = false
            done += 1
            var newResults:[BookResult]? = []
            
            for bookResult in bookResults! {
                var newResult = bookResult
                newResult.buyLink = self.buyLink
                newResults?.append(newResult)
            }
            
            bookResults = newResults
        }
        
        if get == true {
            
            let startIndex = string.index(string.startIndex, offsetBy: 1)
            let endIndex = string.endIndex
            let priceString = string[Range(startIndex ..< endIndex)]
            self.price = Float(priceString)
            
            if foundNew == true {
                condition = "new"
                print("new price :", price)
                foundNew = false
            } else if foundUsed == true {
                condition = "used"
                print("used price :", price)
                foundUsed = false
            }
            
            let newBookResult = BookResult(market: self.market, price: self.price, condition: self.condition, buyLink: self.buyLink)
            bookResults?.append(newBookResult)
            done += 1
            get = false
        }

    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if done == 3 {
            parser.abortParsing()
        }
    }
    
}


class ParseEBayXML : NSObject, XMLParserDelegate {
    
    var parser: XMLParser!

    var bookResults:[BookResult]? = []
    var market:String = "ebay"
    var price:Float!
    var condition:String!
    var buyLink:String?
    
    var foundCondition:Bool = false
    var foundPrice:Bool = false
    var foundURL:Bool = false
    var done:Int = 0
    
    var newDone:Bool = false
    var usedDone:Bool = false
    
    init(data: Data) {
        super.init()
        
        parser = XMLParser(data: data)
        parser.delegate = self

    }
    
    func execute() {
        parser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "viewItemURL" {
            foundURL = true
        }
        
        if elementName == "conditionId" {
            foundCondition = true
        } else if elementName == "currentPrice" {
            foundPrice = true
        }

    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if foundURL == true {
            self.buyLink = string
            foundURL = false
        }
        
        if (foundCondition == true) {
            if string == "1000" {
                self.condition = "new"
                if !newDone {
                    let bookResult = BookResult(market: self.market, price: self.price, condition: self.condition, buyLink: self.buyLink)
                    bookResults?.append(bookResult)
                    done += 1
                    newDone = true
                }
            } else {
                self.condition = "used"
                if !usedDone  {
                    let bookResult = BookResult(market: self.market, price: self.price, condition: self.condition, buyLink: self.buyLink)
                    bookResults?.append(bookResult)
                    done += 1
                    usedDone = true
                }
            }
            foundCondition = false
        }
        
        if (foundPrice == true) {
            self.price = Float(string)
            foundPrice = false
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if done == 2 {
            parser.abortParsing()
        }
    }
    
}



class ParseDTXML : NSObject, XMLParserDelegate {
    
    var parser: XMLParser!
    var priceUrl:String = ""
    var bookResults:[BookResult]?
    var foundValidVendor:Bool = false
    
//    var market:String
//    var price:Float
//    var condition:String
//    var buyLink:String?
    
    init(data: Data) {
        super.init()
        
        parser = XMLParser(data: data)
        parser.delegate = self
    }
    
    func execute() {
        parser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        print(elementName)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print(string)

    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print(elementName)
    }
    
}














