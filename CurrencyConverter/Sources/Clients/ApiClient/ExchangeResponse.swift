//
//  ExchangeResponse.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import Foundation

struct ExchangeResponse: Decodable {

  let amount: Double
  let currency: String

  enum CodingKeys: String, CodingKey {
    case amount
    case currency
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    // Decode the amount as a String and convert it to a Double
    let amountString = try container.decode(String.self, forKey: .amount)

    guard let amountDouble = Double(amountString) else {
      throw DecodingError.dataCorruptedError(forKey: .amount,
                                             in: container,
                                             debugDescription: "Amount string could not be converted to Double")
    }
    amount = amountDouble

    // Decode the currency normally
    currency = try container.decode(String.self, forKey: .currency)
  }
}
