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

typealias DoneHandler = (Error?, [NewsItem]) -> Void

let rssURLStr = "https://www.everydayhealth.com.tw/upload/all_rss.xml"

class RSSParserManager: NSObject, XMLParserDelegate {
    var currentNewsItem: NewsItem?
    var resultsArray = [NewsItem]()
    var currentElementValue: String?
    var parser = XMLParser()

    var newsReach = Reachability(hostName: rssURLStr)

    var isConnect: Bool {
        guard let reach = newsReach else {
            return false
        }
        return reach.checkInternetFunction()
    }

    func downloadList(completion: @escaping DoneHandler) {
        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config)

        if let url = URL(string: rssURLStr) {
            let task = session.dataTask(with: url) { data, _, error in

                if error != nil {
                    SHLog(message: error.debugDescription)

                    return
                }

                self.parser = XMLParser(data: data!)
                self.parser.delegate = self

                if self.parser.parse() {
                    completion(nil, self.getResult())
                }
            }

            task.resume()
        }
    }

    func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes _: [String: String] = [:]) {
        if elementName == "item" {
            currentNewsItem = NewsItem()

        } else if elementName == "title" {
            currentElementValue = nil

        } else if elementName == "link" {
            currentElementValue = nil

        } else if elementName == "g:image_link" {
            currentElementValue = nil

        } else if elementName == "pubDate" {
            currentElementValue = nil
        }
    }

    func parser(_: XMLParser, didEndElement elementName: String, namespaceURI _: String?, qualifiedName _: String?) {
        guard let currentValue = currentElementValue else {
            return
        }

        if elementName == "item" {
            guard let currentItem = currentNewsItem else {
                return
            }

            resultsArray.append(currentItem)

            currentNewsItem = nil

        } else if elementName == "title" {
            currentNewsItem?.title = currentValue

        } else if elementName == "link" {
            currentNewsItem?.link = currentValue

        } else if elementName == "g:image_link" {
            currentNewsItem?.imageURL = currentValue

        } else if elementName == "pubDate" {
            let date = currentValue.replacingOccurrences(of: "+0800", with: "")

            currentNewsItem?.pubDate = date
        }

        currentElementValue = nil
    }

    func parser(_: XMLParser, foundCharacters string: String) {
        if currentElementValue == nil {
            currentElementValue = String()
        }

        currentElementValue?.append(string)
    }

    func getResult() -> [NewsItem] {
        return resultsArray
    }
}
