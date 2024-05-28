//
//  CorneredView.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 28.05.2024.
//

import UIKit

final
class CorneredView: UIView {

  override func layoutSubviews() {
    super.layoutSubviews()
    roundBottomRightCorner()
  }

  private func roundBottomRightCorner() {
    let path = UIBezierPath(roundedRect: self.bounds,
                            byRoundingCorners: [.bottomRight, .topRight],
                            cornerRadii: CGSize(width: 25, height: 25))

    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
  }
}
