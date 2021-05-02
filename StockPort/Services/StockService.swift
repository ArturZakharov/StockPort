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
    var dataTask: URLSessionDataTask?
    
    //MARK:- init
    private init() {}
    
    //MARK:- Function
    public func getStock(stockSymbol: String, completion: @escaping (Stock) -> Void){
        guard let url = URL(string: "https://apidojo-yahoo-finance-v1.p.rapidapi.com/stock/get-detail?symbol=\(stockSymbol)&region=US")else {
            print("Error creating url object")
            return
        }

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        let headers = [
            //from gmail acount
            //"x-rapidapi-key": "4d4114900cmsh656b2fed922b26dp189e9djsnb78a32225697",
            //from mail.ru acount
            //"x-rapidapi-key": "72bb964e46msh6e1ce213c5f1633p1da19djsn0bac3f4814ee",
            //from chibis_1988@hotmail.com
            "x-rapidapi-key": "518a248144mshbd909ca9a059877p192d60jsn397951a47d7f",
            "x-rapidapi-host": "apidojo-yahoo-finance-v1.p.rapidapi.co"

        ]

        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        dataTask = session.dataTask(with: request) { data, response, error in
            let httpUrlResponse = response as? HTTPURLResponse

            if httpUrlResponse?.statusCode == 503 {
                print("response code: 503 Service Unavailable")
            } else {
                if error == nil, let data = data {
                    do {
                        let jsonData = try JSONDecoder().decode(Stock.self, from: data)
//                        ******************************
//                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
//                        let jsonData1 = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
//                        let jsonObjectString = String(data: jsonData1, encoding: String.Encoding.utf8) ?? ""
//                        print("************************")
//                        print(jsonObjectString)
//                        print("************************")
//                        ******************************
                        completion(jsonData)
                    } catch {
                        print("Error parsing data: \(error)")
                    }
                } else {
                    print("Error: \(String(describing: error))")
                }
            }
        }
        dataTask?.resume()
    }
    
    
    
    func cancelPreviousRequest(){
        dataTask?.cancel()
    }
    
    func getStocksNames(completion: @escaping ([CompanyNames]) -> Void){
         guard let path = Bundle.main.path(forResource: "stocks_names.list", ofType: "json") else {return}
        let url = URL(fileURLWithPath: path)
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
            do {
                let stocks = try JSONDecoder().decode([CompanyNames].self, from: data)
                
                completion(stocks)
            } catch {
                print("error decoding data")
            }
        }.resume()
    }
}
