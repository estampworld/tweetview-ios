//
//  WidgetsJSManager.swift
//
//
//  Created by Eduardo Irias on 1/19/21.
//

import Foundation

internal class WidgetsJSManager {
    static let shared = WidgetsJSManager()
    
    // The contents of https://platform.twitter.com/widgets.js
    private(set) var content: String?
    
    public func load() {
        guard content == nil else { return }
        let task = URLSession.shared.dataTask(with: URL(string: "https://platform.twitter.com/widgets.js")!) { (data, response, error) in
            guard let data = data else {
                return
            }
            self.content = String(data: data, encoding: .utf8)
        }
        task.resume()
    }
}

