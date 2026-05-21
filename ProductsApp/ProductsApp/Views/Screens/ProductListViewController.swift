//
//  ProductListViewController.swift
//  ProductsApp
//
//  Created by Kapil Khedkar on 21/05/26.
//

import UIKit

final class ProductListViewController: UIViewController {
    
    weak var coordinator: AppCoordinator?

    private let viewModel: ProductListViewModel

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .none
        tv.estimatedRowHeight = ProductTableViewCell.estimatedHeight
        tv.rowHeight = UITableView.automaticDimension
        tv.showsVerticalScrollIndicator = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(ProductTableViewCell.self, forCellReuseIdentifier: ProductTableViewCell.reuseIdentifier)
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    private let loadingSpinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .large)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private lazy var errorView: ErrorView = {
        let ev = ErrorView()
        ev.isHidden = true
        ev.translatesAutoresizingMaskIntoConstraints = false
        ev.onRetry = { [weak self] in self?.viewModel.fetchInitialProducts() }
        return ev
    }()

    private lazy var emptyView: EmptyView = {
        let ev = EmptyView()
        ev.isHidden = true
        ev.translatesAutoresizingMaskIntoConstraints = false
        return ev
    }()

    private let loadingFooter = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 52))

    init(viewModel: ProductListViewModel = ProductListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLayout()
        viewModel.delegate = self
        viewModel.fetchInitialProducts()
    }

    private func setupNavigationBar() {
        title = "Electronics"
        navigationController?.navigationBar.prefersLargeTitles = false

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func setupLayout() {
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        view.addSubview(loadingSpinner)
        view.addSubview(errorView)
        view.addSubview(emptyView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func apply(state: ProductListState) {
        tableView.isHidden = true
        loadingSpinner.stopAnimating()
        errorView.isHidden = true
        emptyView.isHidden = true
        tableView.tableFooterView = nil

        switch state {

        case .idle:
            break

        case .loading:
            loadingSpinner.startAnimating()

        case .loaded(let products):
            tableView.isHidden = false
            reloadTable(with: products)

        case .loadingMore(let products):
            tableView.isHidden = false
            reloadTable(with: products)
            tableView.tableFooterView = loadingFooter

        case .empty:
            emptyView.isHidden = false

        case .error(let error):
            errorView.configure(error: error)
            errorView.isHidden = false
        }
    }

    private func reloadTable(with products: [Product]) {
        tableView.reloadData()
    }
}

extension ProductListViewController: ProductListViewModelDelegate {
    func viewModelDidUpdateState(_ state: ProductListState) {
        apply(state: state)
    }
}

extension ProductListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        viewModel.products.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.reuseIdentifier, for: indexPath) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.products[indexPath.row])
        return cell
    }
}

extension ProductListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = viewModel.products[indexPath.row]
        coordinator?.showDetail(product: product)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastIndex = viewModel.products.count - 1
        if indexPath.row == lastIndex {
            viewModel.fetchNextPageIfNeeded()
        }
    }
}
