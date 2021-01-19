//
//  File.swift
//  
//
//  Created by Eduardo Irias on 1/19/21.
//

import Foundation

public class WidgetsJsManager {
    public static let shared = WidgetsJsManager()
    
    // The contents of https://platform.twitter.com/widgets.js
    var content: String?
    
    public func load() {
        let task = URLSession.shared.dataTask(with: URL(string: "https://platform.twitter.com/widgets.js")!) { (data, response, error) in
            guard let data = data else {
                return
            }
            self.content = String(data: data, encoding: .utf8)
        }
        task.resume()
    }
    
    public func getScriptContent() -> String? {
        return content
    }
}
