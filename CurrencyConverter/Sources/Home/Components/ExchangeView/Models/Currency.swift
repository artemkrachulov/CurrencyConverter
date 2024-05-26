//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import Foundation

// ISO code and Symbol adapted from
// source from https://en.wikipedia.org/wiki/List_of_circulating_currencies

enum Currency: Int, CaseIterable {
  case EUR = 0
  case USD
  case UAH
}
