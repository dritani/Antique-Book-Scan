//
//  resultTableViewCell.swift
//  Antique Book Scan
//
//  Created by Dritani on 2017-03-28.
//  Copyright © 2017 AquariusLB. All rights reserved.
//

import Foundation
import UIKit

class resultTableViewCell: UITableViewCell {
    static let reuseIdentifier = "resultTableViewCell"
    
    var marketImage:UIImageView!
    var marketLabel:UILabel!
    var priceLabel:UILabel!
    
    init() {
        super.init(style: .default, reuseIdentifier: resultTableViewCell.reuseIdentifier)
        setup()
        
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            let frame = CGRect(origin: newFrame.origin, size: CGSize(width:UIScreen.main.bounds.width,height:newFrame.height))
            super.frame = frame
        }
    }
    
    private func setup() {
        self.backgroundColor = UIColor.black
        
        marketImage = UIImageView()
        let marketImageSize = CGSize(width: self.frame.height * 0.7, height: self.frame.height * 0.7)
        marketImage.frame = CGRect(origin: CGPoint(x:0,y:0),size:marketImageSize)
        marketImage.center = CGPoint(x:10+marketImage.frame.width/2,y:self.frame.height/2)
        self.addSubview(marketImage)
        
        priceLabel = UILabel()
        priceLabel.isOpaque = false
        priceLabel.text = "sample"
        priceLabel.font = UIFont(name: "AvenirNext-Regular", size: 15)
        priceLabel.textColor = UIColor.white
        priceLabel.sizeToFit()
        priceLabel.textAlignment = .right
        priceLabel.center = CGPoint(x:self.frame.width - 10 - priceLabel.frame.width/2,y:self.frame.height/2)
        self.addSubview(priceLabel)
        
        let dollarLabel = UILabel()
        dollarLabel.text = "$"
        dollarLabel.font = UIFont(name: "AvenirNext-Regular", size: 15)
        dollarLabel.textColor = UIColor.white
        dollarLabel.textAlignment = .right
        dollarLabel.sizeToFit()
        dollarLabel.center = CGPoint(x:priceLabel.center.x-5-priceLabel.frame.width/2,y:priceLabel.center.y)
        self.addSubview(dollarLabel)
        
        marketLabel = UILabel()
        marketLabel.isOpaque = false
        marketLabel.textAlignment = .left
        marketLabel.text = "sample"
        marketLabel.font = UIFont(name: "AvenirNext-Regular", size: 15)
        marketLabel.textColor = UIColor.white
        marketLabel.frame = CGRect(origin:CGPoint.zero,size:CGSize(width:self.frame.width-marketImage.frame.width-dollarLabel.frame.width-25,height:self.frame.height))
        marketLabel.center = marketImage.center
        marketLabel.center.x += (marketImage.frame.width + marketLabel.frame.width/2-5)
        self.addSubview(marketLabel)
    }
    
}

