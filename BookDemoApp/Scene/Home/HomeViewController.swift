//
//  ViewController.swift
//  BookDemoApp
//
//  Created by Zerom on 4/18/24.
//

import UIKit
import RxSwift

fileprivate enum Section: Hashable {
    case banner
}

fileprivate enum Item: Hashable {
    case bigImage(Book)
}

class HomeViewController: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel = HomeViewModel()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "BOOK Demo"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        collectionView.register(BestsellcerCell.self, forCellWithReuseIdentifier: BestsellcerCell.id)
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section,Item>?
    
    let bookTrigger = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setDataSource()
        bindViewModel()
        bookTrigger.onNext(())
    }
    
    private func setUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(titleLabel)
        self.view.addSubview(collectionView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(6)
            make.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(46)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        let input = HomeViewModel.Input(bookTrigger: bookTrigger.asObservable())
        let output = viewModel.transform(input: input)
        
        output.bookResult.bind { [weak self] result in
            switch result {
            case .success(let bookResult):
                var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
                
                let bigImageList = bookResult.bestseller.item.map { Item.bigImage($0) }
                let bannerSection = Section.banner
                snapshot.appendSections([bannerSection])
                snapshot.appendItems(bigImageList, toSection: bannerSection)
                
                self?.dataSource?.apply(snapshot)
                
            case .failure(let error):
                print(error)
            }
        }.disposed(by: disposeBag)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
            let section = self?.dataSource?.sectionIdentifier(for: sectionIndex)
            switch section {
            case .banner:
                return self?.createBannerSection()
            default:
                return self?.createBannerSection()
            }
        }, configuration: config)
    }
    
    private func createBannerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(400))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    private func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section,Item>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                switch item {
                case .bigImage(let bestseller):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: BestsellcerCell.id,
                        for: indexPath
                    ) as? BestsellcerCell
                    
                    cell?.configure(title: bestseller.title,
                                    desc: bestseller.desc,
                                    url: bestseller.coverURL)
                    return cell
                }
            })
    }
}

