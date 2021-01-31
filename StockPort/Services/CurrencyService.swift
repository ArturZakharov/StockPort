//
//  CurrencyService.swift
//  StockPort
//
//  Created by ArturZaharov on 09.01.2021.
//

import Foundation

class CurrencyService: ApiClient {
    
    //MARK:- Properties
    public static let shared = CurrencyService()
    
    //MARK:- init
    private init() {}
    
    
    //MARK:- Function
    public func getCurrencyValue(completion: @escaping (CurrencyValue) -> Void){
        guard let url = URL(string: "https://currencyscoop.p.rapidapi.com/latest")else {
            print("Error creating url object")
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        let headers = [
            "x-rapidapi-key": "4d4114900cmsh656b2fed922b26dp189e9djsnb78a32225697",
            "x-rapidapi-host": "currencyscoop.p.rapidapi.com"
        ]
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
            let httpUrlResponse = response as? HTTPURLResponse
            
            if httpUrlResponse?.statusCode == 503 {
                print("response code: 503 Service Unavailable")
            } else {
                if error == nil, let data = data {
                    do {
                        let jsonData = try JSONDecoder().decode(CurrencyValue.self, from: data)
                        completion(jsonData)
                    } catch {
                        print("Error parsing data: \(error)")
                    }
                } else {
                    print("Error: \(String(describing: error))")
                }
            }
        }
        dataTask.resume()
    }
    
    
    
    public func getCurrencySimbols(completion: @escaping (CurrencyData) -> Void) {
        guard let path = Bundle.main.path(forResource: "currency", ofType: "json") else {return}
        let url = URL(fileURLWithPath: path)
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
            do {
                let currencyValues = try JSONDecoder().decode(CurrencyData.self, from: data)
                
                completion(currencyValues)
            } catch {
                print("error decoding data")
            }
        }.resume()
    }
}

