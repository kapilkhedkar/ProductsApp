//
//  ProductListViewModel.swift
//  ProductsApp
//
//  Created by Kapil Khedkar on 21/05/26.
//

import Foundation

enum ProductListState {
    case idle
    case loading
    case loaded([Product])
    case loadingMore([Product])
    case empty
    case error(NetworkError)
}

protocol ProductListViewModelDelegate: AnyObject {
    func viewModelDidUpdateState(_ state: ProductListState)
}


final class ProductListViewModel {

    private let category  = "electronics"
    private let pageLimit = 10
    private let startPage = 0

    private let networkService: NetworkServiceProtocol

    private(set) var products: [Product] = []
    private var currentPage: Int
    private var nextPage: Int?
    private var isFetching = false

   
    weak var delegate: ProductListViewModelDelegate?

    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
        self.currentPage    = startPage
    }

    func fetchInitialProducts() {
        guard !isFetching else { return }
        products    = []
        currentPage = startPage
        nextPage    = nil
        fetchPage(currentPage, isInitial: true)
    }

    func fetchNextPageIfNeeded() {
        guard !isFetching else { return }

        guard let page = nextPage else { return }
        fetchPage(page, isInitial: false)
    }

    private func fetchPage(_ page: Int, isInitial: Bool) {
        isFetching = true

        let state: ProductListState = isInitial
            ? .loading
            : .loadingMore(products)

        delegate?.viewModelDidUpdateState(state)

        networkService.fetchProducts(page: page,
                                     limit: pageLimit,
                                     category: category) { [weak self] result in
            guard let self else { return }
            self.isFetching = false

            switch result {
            case .success(let response):
                self.handle(response: response)

            case .failure(let error):
                self.delegate?.viewModelDidUpdateState(.error(error))
            }
        }
    }

    private func handle(response: ProductResponse) {
        products += response.data

        nextPage = response.pagination.nextPage

        if products.isEmpty {
            delegate?.viewModelDidUpdateState(.empty)
        } else {
            delegate?.viewModelDidUpdateState(.loaded(products))
        }
    }
}
