//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//  https://rest.coinapi.io/v1/exchangerate/BTC/USD?apikey=6d57567e-8f7b-489b-b7ed-d22ee665506f
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoin(_ coinManager: CoinManager, coin: Coin)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "6d57567e-8f7b-489b-b7ed-d22ee665506f"
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let coin = parseJSON(safeData) {
                        delegate?.didUpdateCoin(self, coin: coin)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(_ coinData: Data) -> Coin?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(Coin.self, from: coinData)
            
            let rate = decodedData.rate
            let asset_id_quote = decodedData.asset_id_quote
            
            let coin = Coin(rate: rate, asset_id_quote: asset_id_quote)
            return coin
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
