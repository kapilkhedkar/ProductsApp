//
//  ProductDetailViewController.swift
//  ProductsApp
//
//  Created by Kapil Khedkar on 21/05/26.
//

import UIKit

final class ProductDetailViewController: UIViewController {

    private let product: Product

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let heroImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .secondarySystemFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let gradientLayer = CAGradientLayer()

    private let categoryBadge: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .white
        l.backgroundColor = .systemBlue
        l.layer.cornerRadius = 8
        l.clipsToBounds = true
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.textColor = .label
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 28, weight: .heavy)
        l.textColor = .systemGreen
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let ratingLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let divider1 = DividerView()

    private let descriptionTitleLabel = SectionHeaderLabel(text: "Description")

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15)
        l.textColor = .label
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let divider2 = DividerView()

    private let specsTitleLabel = SectionHeaderLabel(text: "Specifications")

    private let specsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let divider3 = DividerView()

    private let infoTitleLabel = SectionHeaderLabel(text: "Product Info")

    private let infoStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    init(product: Product) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupLayout()
        populateContent()
        loadHeroImage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = heroImageView.bounds
    }

    private func setupNavigation() {
        title = product.title
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(heroImageView)
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.systemBackground.cgColor]
        gradientLayer.locations = [0.5, 1.0]
        heroImageView.layer.addSublayer(gradientLayer)
        heroImageView.addSubview(categoryBadge)

        let infoGroup = UIStackView(arrangedSubviews: [
            titleLabel,
            priceLabel,
            ratingLabel,
            divider1,
            descriptionTitleLabel,
            descriptionLabel,
            divider2,
            specsTitleLabel,
            specsStack,
            divider3,
            infoTitleLabel,
            infoStack
        ])
        infoGroup.axis = .vertical
        infoGroup.spacing = 12
        infoGroup.setCustomSpacing(4, after: titleLabel)
        infoGroup.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(infoGroup)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            heroImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.65),

            categoryBadge.leadingAnchor.constraint(equalTo: heroImageView.leadingAnchor, constant: 16),
            categoryBadge.bottomAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: -16),
            categoryBadge.heightAnchor.constraint(equalToConstant: 28),

            infoGroup.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: 20),
            infoGroup.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoGroup.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            infoGroup.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    private func populateContent() {
        titleLabel.text = product.title
        priceLabel.text = product.formattedPrice
        ratingLabel.text = product.formattedRating
        descriptionLabel.text = product.description
        categoryBadge.text = "  \(product.category.capitalized)  "

        if let specs = product.specs, !specs.isEmpty {
            specs.sorted(by: { $0.key < $1.key }).forEach { key, value in
                specsStack.addArrangedSubview(
                    KeyValueRow(key: key.capitalized, value: value.displayString)
                )
            }
        } else {
            specsStack.addArrangedSubview(
                KeyValueRow(key: "Specs", value: "Not available")
            )
        }
        
        infoStack.addArrangedSubview(KeyValueRow(key: "Brand", value: product.brand))
        infoStack.addArrangedSubview(KeyValueRow(key: "Category", value: product.category.capitalized))
        infoStack.addArrangedSubview(KeyValueRow(key: "Stock", value: "\(product.stock) units"))
        infoStack.addArrangedSubview(KeyValueRow(key: "Product ID", value: "#\(product.id)"))
    }

    private func loadHeroImage() {
        heroImageView.image = UIImage(systemName: "photo")
        heroImageView.tintColor = .systemGray4
        heroImageView.contentMode = .scaleAspectFit

        guard let url = product.imageURL else { return }
        ImageLoader.shared.load(url: url) { [weak self] image in
            guard let self else { return }
            if let image {
                UIView.transition(with: self.heroImageView,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve) {
                    self.heroImageView.image = image
                    self.heroImageView.contentMode = .scaleAspectFill
                }
            }
        }
    }
}

private final class DividerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .separator
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    required init?(coder: NSCoder) { fatalError() }
}

private final class SectionHeaderLabel: UILabel {
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        self.font = .systemFont(ofSize: 17, weight: .bold)
        self.textColor = .label
        translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) { fatalError() }
}

private final class KeyValueRow: UIView {

    init(key: String, value: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let keyLabel = UILabel()
        keyLabel.text = key
        keyLabel.font = .systemFont(ofSize: 14, weight: .medium)
        keyLabel.textColor = .secondaryLabel
        keyLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [keyLabel, valueLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .top
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}
