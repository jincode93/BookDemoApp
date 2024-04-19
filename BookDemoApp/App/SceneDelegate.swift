//
//  SceneDelegate.swift
//  BookDemoApp
//
//  Created by Zerom on 4/18/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let rootVC = HomeViewController()
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
    }
}

