//
//  StockService.swift
//  StockPort
//
//  Created by ArturZaharov on 09.02.2021.
//

import Foundation

class StockService: ApiClient {
    
    //MARK:- Properties
    public static let shared = StockService()
    
    //MARK:- init
    private init() {}
    
    //MARK:- Function
    public func getStock(stockSymbol: String, completion: @escaping (CurrencyValue) -> Void){
        guard let url = URL(string: "https://apidojo-yahoo-finance-v1.p.rapidapi.com/stock/get-detail?symbol=\(stockSymbol)&region=US")else {
            print("Error creating url object")
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        let headers = [
            "x-rapidapi-key": "4d4114900cmsh656b2fed922b26dp189e9djsnb78a32225697",
            "x-rapidapi-host": "apidojo-yahoo-finance-v1.p.rapidapi.co"
        ]
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
//            let httpUrlResponse = response as? HTTPURLResponse
//
//            if httpUrlResponse?.statusCode == 503 {
//                print("response code: 503 Service Unavailable")
//            } else {
//                if error == nil, let data = data {
//                    do {
//                        let jsonData = try JSONDecoder().decode(CurrencyValue.self, from: data)
//                        completion(jsonData)
//                    } catch {
//                        print("Error parsing data: \(error)")
//                    }
//                } else {
//                    print("Error: \(String(describing: error))")
//                }
//            }
            if error == nil, let data = data {
                
                // Try to parse out the data
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                    let jsonObjectString = String(data: jsonData, encoding: String.Encoding.utf8) ?? ""
                    print(jsonObjectString)
                } catch {
                    print("Error parsing data!")
                }
            }
        }
        dataTask.resume()
    }
}
