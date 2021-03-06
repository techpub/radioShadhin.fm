//
//  TitleRefresher.swift
//  domradio-ios
//
//  Created by Steffen Tröster on 02/09/15.
//  Copyright © 2015 Steffen Tröster. All rights reserved.
//

import Foundation
import SWXMLHash
import SwiftHTTP


class TitleRefresher {
    
    let url = "https://www.domradio.de/sites/all/themes/domradio/playlist/Export.xml"

    var timer:NSTimer?
    var target:TitleRefresherDelegate?
    
    init(target:TitleRefresherDelegate){
        self.target = target
        self.timer = NSTimer.scheduledTimerWithTimeInterval(20.0,
            target: self,
            selector: "loadTitle",
            userInfo: nil,
            repeats: true)

        self.loadTitle()
    }
    
    @objc func loadTitle(){
        do {
            let opt = try HTTP.GET(self.url, parameters: nil)
            opt.start { response in
                if let _ = response.error {
                    return
                }
                if let text = response.text{
                    self.parseXML(text)
                }
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
        
    }
    
    func parseXML(text:String){
        let xml = SWXMLHash.parse(text)
        let title = xml["station"]["onair"]["title"].element?.text
        let artist = xml["station"]["onair"]["artist"].element?.text
        if let title = title, let artist = artist{
            if let target = self.target{
                target.updateTitle("\(self.flipArtist(artist)) - \(title)")
            }
        }
    }
    
    func flipArtist(str:String) -> String{
        if(str.containsString(",")){
            let range = str.rangeOfString(",")!
            let first = str.substringToIndex(range.startIndex)
            let last = str.substringFromIndex(range.endIndex)
            return "\(last) \(first)"
        }
        return str
    }
    
    func stop(){
        if let timer = timer{
            timer.invalidate()
        }
    }
}
