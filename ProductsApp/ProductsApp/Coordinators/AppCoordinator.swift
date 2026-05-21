//
//  AppCoordinator.swift
//  ProductsApp
//
//  Created by Kapil Khedkar on 21/05/26.
//
import Foundation
import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
    func mockStart()
}

final class AppCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    
    init(
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    func start() {
        
        let viewModel = ProductListViewModel()
        let vc = ProductListViewController(
            viewModel: viewModel
        )
        vc.coordinator = self
        navigationController.pushViewController(
            vc,
            animated: false
        )
    }
    
    func mockStart() {
        let viewModel = ProductListViewModel(networkService: MockNetworkService())
        let vc = ProductListViewController(
            viewModel: viewModel
        )
        vc.coordinator = self
        navigationController.pushViewController(
            vc,
            animated: false
        )
    }
    
    func showDetail(product: Product) {
        let vc = ProductDetailViewController(
            product: product
        )
        
        navigationController.pushViewController(
            vc,
            animated: true
        )
    }
}
