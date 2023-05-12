//
//  API Control.swift
//  FairTask
//
//  Created by xin weng on 12/5/2023.
//

import Foundation
struct ApiManager {
    
    // Update the appid with your API Key
    let apiURL = "https://type.fit/api/quotes"
    
    func fetchApi(quote: String) {
        let urlString = "https://type.fit/api/quotes"
        
        performRequest(urlString: urlString)
    }
    
    
    func performRequest(urlString: String) {
        // step1: create URL
        if let url = URL(string: urlString) {
            // step 2: create a URL session
            let session = URLSession(configuration: .default)
            // step 3: give URLSession a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data {
                    let dataString = String(data: safeData, encoding: .utf8)
                    self.parseJSON(apiData: safeData)
                }
            }
            
            // step 4: start a task
            task.resume()
        }
    }
    
    func parseJSON(apiData: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([ApiData].self, from: apiData)
            
            var motivationDict = MotivationDict(quotes: [])
            motivationDict.quotes.append(contentsOf: decodedData)
            
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(motivationDict) {
                // Save the encoded data to UserDefaults
                UserDefaults.standard.set(encoded, forKey: MOTIVATION_KEY)
            }
        } catch {
            print(error)
        }
    }







    
    
    
}
