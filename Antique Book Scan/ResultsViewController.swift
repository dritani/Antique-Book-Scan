//
//  ResultsViewController.swift
//  Antique Book Scan
//
//  Created by Dritani on 2017-03-25.
//  Copyright © 2017 AquariusLB. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import DZNEmptyDataSet
import MBProgressHUD

struct BookResult {
    
    var market:String
    var price:Float
    var condition:String
    var buyLink:String?
    
    init(market:String,price:Float,condition:String,buyLink:String?) {
        self.market = market
        self.price = price
        self.condition = condition
        self.buyLink = buyLink
    }
}

class ResultsViewController: UIViewController {
    
    var bookData:BookData!
    
    var completionAmazon:([BookResult]?)->Void = {_ in }
    var completionEBay:([BookResult]?)->Void = {_ in }
    var completionDT:([BookResult]?)->Void = {_ in }
    
    var apisCalled:Int = 0
    var maxAPIs = 2
    var bookCoverImageView:UIImageView!
    var bookTitle:UILabel!
    var authorsLabel:UILabel!
    var backButton:UIButton!
    var resultsTableView:UITableView!
    
    var newResults:[BookResult] = []
    var usedResults:[BookResult] = []
    var eBookResults:[BookResult] = []
    
    // Beginning
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = []
        navigationController?.navigationBar.isHidden = true
        
        setupContents()
        setupCompletionHandlers()
        callAPIs()
        
    }
    
    func setupContents() {
        view.backgroundColor = UIColor.black
        
        bookCoverImageView = UIImageView(image: UIImage(named:"default cover.png"))
        let bookCoverImageSize = CGSize(width:100,height:150)
        bookCoverImageView.frame = CGRect(origin:CGPoint(x:0,y:0),size: bookCoverImageSize)
        bookCoverImageView.center = CGPoint(x:10+bookCoverImageView.frame.width/2, y:20+bookCoverImageView.frame.height/2)
        if (bookData.coverURL != nil) {
            getCoverImage()
        }
        view.addSubview(bookCoverImageView)

        
        
        bookTitle = UILabel()
        bookTitle.isOpaque = false

        let title:String = bookData.subTitle != nil ? bookData.bookTitle + ": " + bookData.subTitle! : bookData.bookTitle
        let authors = bookData.authors?.joined(separator: ", ")
        
        var myString:String = title + "\n" + "by " + authors!
        
        let myMutableString = NSMutableAttributedString(string: myString, attributes: [NSFontAttributeName:UIFont(name: "AvenirNext-Regular", size: 15)!])
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: yellowColor, range: NSRange(location:0,length:title.characters.count+4))
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location:title.characters.count+1,length:authors!.characters.count+3))
        bookTitle.attributedText = myMutableString

        let bookTitleSize = CGSize(width: self.view.frame.width - bookCoverImageView.frame.width - 30, height: 75)
        bookTitle.frame = CGRect(origin:CGPoint(x:0,y:0),size: bookTitleSize)
        //bookTitle.sizeToFit()
        bookTitle.lineBreakMode = .byWordWrapping
        bookTitle.numberOfLines = 0
        bookTitle.adjustsFontSizeToFitWidth = true
        bookTitle.center = CGPoint(x:bookCoverImageView.frame.width + 20 + bookTitleSize.width/2, y:20 + bookTitle.frame.height/2)
        view.addSubview(bookTitle)

        backButton = UIButton()
        backButton.setImage(UIImage(named: "backButton.png"), for: .normal)
        let backButtonSize = CGSize(width:50,height:27)
        backButton.frame = CGRect(origin:CGPoint(x:0,y:0),size: backButtonSize)
        backButton.center = CGPoint(x:view.frame.width-10-backButton.frame.width/2, y:bookCoverImageView.frame.height + 20 - backButton.frame.height/2)
        backButton.addTarget(self, action: #selector(self.returnToCamera), for: .touchUpInside)
        view.addSubview(backButton)

        resultsTableView = UITableView()
        resultsTableView.tableHeaderView = nil
        let resultsTableViewSize = CGSize(width:view.bounds.size.width,height:view.bounds.size.height-40-bookCoverImageView.frame.height)
        resultsTableView.frame = CGRect(origin:CGPoint.zero,size: resultsTableViewSize)
        resultsTableView.center = CGPoint(x:view.frame.size.width/2, y:20 + bookCoverImageView.frame.height + 20 + resultsTableView.frame.height/2)
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.backgroundColor = UIColor.black
        resultsTableView.register(resultTableViewCell.self, forCellReuseIdentifier: "resultTableViewCell")
        resultsTableView.emptyDataSetSource = self;
        resultsTableView.emptyDataSetDelegate = self;
        resultsTableView.tableFooterView = UIView()
        resultsTableView.separatorStyle = .none
        view.addSubview(resultsTableView)
        
        
    }
    
    func returnToCamera() {
        sharedSession.getAllTasks(completionHandler: { tasks in
            for task in tasks {
                task.cancel()
            }
        })
        navigationController?.popToRootViewController(animated: true)
    }
    
    func getCoverImage() {
        let url = URL(string: bookData.coverURL!)
        
        let request = URLRequest(url: url!)
        
        print("getting cover image")
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
            
            let image = UIImage(data: data)
            
            DispatchQueue.main.async {
                self.bookCoverImageView.image = image
            }
            
        }
        
        task.resume()

    }
    
    func setupCompletionHandlers() {
        completionAmazon = {bookResults in
            if bookResults == nil {
                //self.loadingIcon.stopAnimating()
                
            }
            self.checkBookResults(bookResults: bookResults)
        }
        
        completionEBay = {bookResults in
            self.checkBookResults(bookResults: bookResults)
        }
        
        completionDT = {bookResults in
            self.checkBookResults(bookResults: bookResults)
        }
    }
    
    
    func checkBookResults(bookResults:[BookResult]?) {
        if (bookResults != nil) {
            for bookResult in bookResults! {
                let condition:String = bookResult.condition
                
                switch condition {
                case "new":
                    var insertionIndex = 0
                    for result in self.newResults {
                        if (bookResult.price > result.price) {
                            insertionIndex += 1
                        }
                    }
                    self.newResults.insert(bookResult, at: insertionIndex)
                case "used":
                    var insertionIndex = 0
                    for result in self.usedResults {
                        if (bookResult.price > result.price) {
                            insertionIndex += 1
                        }
                    }
                    self.usedResults.insert(bookResult, at: insertionIndex)

                case "eBook":
                    var insertionIndex = 0
                    for result in self.eBookResults {
                        if (bookResult.price > result.price) {
                            insertionIndex += 1
                        }
                    }
                    self.eBookResults.insert(bookResult, at: insertionIndex)

                default:
                    break
                }
            }
            DispatchQueue.main.async {
                // reloadatindexpath???
                self.resultsTableView.reloadData()
                self.checkAPIsDone()
            }
        }
    }
    
    func checkAPIsDone() {
        apisCalled += 1
        if apisCalled == 2 {
            self.resultsTableView.reloadData()
        }
    }
    

    func callAPIs() {
        callAmazonAPIPrice(title:bookData.bookTitle,subTitle:bookData.subTitle,authors:bookData.authors,completion:completionAmazon)
        callEBayAPIPrice(title:bookData.bookTitle,subTitle:bookData.subTitle,authors:bookData.authors,completion:completionEBay)
        //callDTAPIPrice(identifier: bookData.identifier, identifierString: bookData.identifierString,completion:completionDT)
    }
}

// MARK: TableView Delegate and DataSource
extension ResultsViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int{
        
        switch section {
        case 0:
            return newResults.count
        case 1:
            return usedResults.count
        case 2:
            return eBookResults.count
        default:
            break
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerViewSize = CGSize(width:view.bounds.size.width,height:20)
        let headerViewRect = CGRect(origin:CGPoint.zero,size: headerViewSize)
        let headerView = UILabel(frame: headerViewRect)
        headerView.backgroundColor = yellowColor
        headerView.textColor = UIColor.black
        headerView.font = UIFont(name: "AvenirNext-Regular", size: 15)
        headerView.textAlignment = .center
        
        switch section {
        case 0:
            headerView.text = "New"
        case 1:
            headerView.text = "Used"
        case 2:
            headerView.text = "eBook"
        default:
            break
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
            case 0:
                if newResults.count == 0 {
                    return 0
                } else {
                    return 20
                }
            case 1:
                if usedResults.count == 0 {
                    return 0
                } else {
                    return 20
                }
            case 2:
                if eBookResults.count == 0 {
                    return 0
                } else {
                    return 20
                }
            default:
                break
        }
        
        return 20
    }
    
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:resultTableViewCell
        
        cell = tableView.dequeueReusableCell(withIdentifier: "resultTableViewCell")! as! resultTableViewCell

        var resultsArray:[BookResult]!
        switch indexPath.section {
            case 0:
                resultsArray = newResults
            case 1:
                resultsArray = usedResults
            case 2:
                resultsArray = eBookResults
        default:
            break
        }
        
        // set cell image and title
        let market = resultsArray[indexPath.row].market
        switch market {
        case "amazon":
            cell.marketImage.image = UIImage(named:"amazon logo.jpg")
            cell.marketLabel.text = "Amazon"
        case "ebay":
            cell.marketImage.image = UIImage(named:"ebay logo.png")
            cell.marketLabel.text = "eBay"
        case "alibris":
            cell.marketImage.image = UIImage(named:"alibris logo.png")
            cell.marketLabel.text = "Alibris"
        case "abebooks":
            cell.marketImage.image = UIImage(named:"abebooks logo.jpg")
            cell.marketLabel.text = "Abebooks"
        case "b&n":
            cell.marketImage.image = UIImage(named:"barnes and noble logo.png")
            cell.marketLabel.text = "Barnes & Noble"
        default:
            break
        }
        
        // set cell price
        cell.priceLabel.text = String(format: "%.02f", resultsArray[indexPath.row].price)
        
        return cell
    }

    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath){
        var resultsArray:[BookResult]!
        
        switch indexPath.section {
        case 0:
            resultsArray = newResults
        case 1:
            resultsArray = usedResults
        case 2:
            resultsArray = eBookResults
        default:
            break
        }
        
        if resultsArray.count != 0 {
            let buyLink:String? = resultsArray[indexPath.row].buyLink
            
            if buyLink != nil {
                //UIApplication.shared.open(URL(string:buyLink!)!, options: [:], completionHandler: nil)
                
                let hud = MBProgressHUD.showAdded(to: view, animated: true)
                hud.mode = .customView
                hud.customView = UIImageView(image: UIImage(named:"clipboard.png"))
                hud.label.text = "Copied link to clipboard"
                hud.center = view.center
                hud.isHidden = false
                _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {_ in
                    hud.hide(animated: true)
                })
                UIPasteboard.general.string = buyLink!
                
            }
        }
    }
}

extension ResultsViewController: DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
    
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        
        let viewToReturn = UIView(frame: resultsTableView.frame)

        var emptyImage:UIImage!
        var emptyText:String!
        
        if apisCalled == maxAPIs {
            emptyImage = imageWithImage(image: UIImage(named:"no books found.png")!, newSize:CGSize(width:viewToReturn.frame.width*0.5,height:viewToReturn.frame.height*0.5))
            emptyText = "No results found"
            
        } else {
            emptyImage = imageWithImage(image: UIImage(named:"getting books.png")!,newSize:CGSize(width:viewToReturn.frame.width*0.5,height:viewToReturn.frame.height*0.5))
            emptyText = "Fetching results"
        }
        
        // add ImageView
        let imageView = UIImageView(image: emptyImage)
        imageView.center = CGPoint(x:viewToReturn.frame.width/2,y:-viewToReturn.frame.height/7)
        viewToReturn.addSubview(imageView)
        
        let attributes:[String:Any] = [NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 20) as Any,NSForegroundColorAttributeName:yellowColor]
        let emptyTitle:NSAttributedString! = NSAttributedString(string: emptyText, attributes: attributes)

        // add UILabel
        let label = UILabel()
        label.textAlignment = .center
        label.attributedText = emptyTitle
        let labelSize = CGSize(width: 200, height: 40)
        label.frame = CGRect(origin:CGPoint.zero,size: labelSize)
        label.adjustsFontSizeToFitWidth = true
        label.center = CGPoint(x:viewToReturn.frame.width/2,y:imageView.center.y+imageView.frame.height/2+label.frame.height/2+10)
        viewToReturn.addSubview(label)
        
        
        //add Loading Indicator
        let loadingIcon2 = NVActivityIndicatorView(frame: CGRect(origin:CGPoint(x:0,y:0),size: CGSize(width:40,height:40)), type: .ballSpinFadeLoader, color: UIColor.yellow)
        let loadingIconSize = CGSize(width:40,height:40)
        loadingIcon2.frame = CGRect(origin:CGPoint.zero,size: loadingIconSize)
        loadingIcon2.center = CGPoint(x:viewToReturn.frame.width/2, y:label.center.y+label.frame.height/2+loadingIcon2.frame.height/2+10)
        loadingIcon2.startAnimating()
        if apisCalled != maxAPIs {
            viewToReturn.addSubview(loadingIcon2)
        }
        return viewToReturn
    }
    
    func imageWithImage(image:UIImage, newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.black
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}

