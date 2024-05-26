//
//  SceneDelegate.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import UIKit

final
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

    guard let windowScene = (scene as? UIWindowScene) else { return }

    let window = UIWindow(windowScene: windowScene)
    let viewModel = HomeViewModel.live
    window.rootViewController = HomeViewController(viewModel: viewModel)
    window.makeKeyAndVisible()
    self.window = window
  }
}
