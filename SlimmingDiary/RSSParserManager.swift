//
//  RSSParserDelegate.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/9.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation

struct NewsItem {
    var title = String()
    var link = String()
    var imageURL = String()
    var pubDate = String()
    
}

typealias  DoneHandler = (Error?,[NewsItem])->Void


class RSSParserManager:NSObject,XMLParserDelegate {
    
    var currentNewsItem:NewsItem?
    var resultsArray = [NewsItem]()
    var currentElementValue:String?
    var parser = XMLParser()
    
    
    
    func downloadList(completion: @escaping DoneHandler){
        
        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config)
        
        let url = URL(string:"https://www.everydayhealth.com.tw/upload/all_rss.xml")
        let task = session.dataTask(with:url!) { (data, respone, error) in
            
            if error != nil{
                print(error.debugDescription)
                
                return
            }
            
            self.parser = XMLParser(data: data!)
            self.parser.delegate = self
            
            if self.parser.parse(){
                
                 completion(nil,self.getResult())
                
            }
            
        }
        
        task.resume()

    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        
        
        
        if elementName == "item"{
            
            currentNewsItem = NewsItem()
            
            
        }else if elementName == "title"{
            
            currentElementValue = nil
            
            
        }else if  elementName ==  "link"{
            
            currentElementValue = nil
            
        }else if  elementName ==  "g:image_link"{
            
            currentElementValue = nil
            
        }else if  elementName ==  "pubDate"{
            
            currentElementValue = nil
            
        }
        
        
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        
        guard let currentValue = currentElementValue else{
            return
        }
        
        if elementName == "item"{
            
            
            guard let currentItem = currentNewsItem else{
                return
            }
            
            resultsArray.append(currentItem)
            
            currentNewsItem = nil
            
            
            
        }else if elementName == "title"{
            
            
            currentNewsItem?.title = currentValue
            
            
        }else if  elementName ==  "link"{
            
            currentNewsItem?.link = currentValue
            
        }else if  elementName ==  "g:image_link"{
            
            currentNewsItem?.imageURL = currentValue
            
            
        }else if  elementName ==  "pubDate"{
            
            
            
            
            
         
            
       let date = currentValue.replacingOccurrences(of:"+0800", with:"")
            
            currentNewsItem?.pubDate = date
            
           
        }
        
        currentElementValue = nil
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        
        
        
        if currentElementValue == nil{
            currentElementValue = String()
        }
        
        currentElementValue?.append(string)
        
        
        
    }
    
    func getResult()->[NewsItem]{
        return resultsArray
    }
    
}
