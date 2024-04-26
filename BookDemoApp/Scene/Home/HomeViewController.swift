//
//  ViewController.swift
//  BookDemoApp
//
//  Created by Zerom on 4/18/24.
//

import UIKit
import RxSwift
import RxCocoa

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
        collectionView.register(EditorChoiceCell.self, forCellWithReuseIdentifier: EditorChoiceCell.id)
        collectionView.register(CarouselFooterCell.self, forCellWithReuseIdentifier: CarouselFooterCell.id)
        collectionView.register(HorizontalCell.self, forCellWithReuseIdentifier: HorizontalCell.id)
        collectionView.register(CategoryTypeCell.self, forCellWithReuseIdentifier: CategoryTypeCell.id)
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.id)
        collectionView.register(VerticalCell.self, forCellWithReuseIdentifier: VerticalCell.id)
        
        collectionView.register(HeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderView.id)
        
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<HomeSection,HomeItem>?
    
    let bookTrigger = PublishSubject<Void>()
    let horizontalPageTrigger = PublishSubject<Int>()
    var selectedCategoryTrigger = PublishSubject<Int>()
    let verticalPageTrigger = PublishSubject<Int>()
    
    var bannerItemCount: Int = 0
    var carouselItemCount: Int = 0
    var carouselDatas: [HomeItem] = []
    var curIndex = 0
    var horizontalPage = 1
    var verticalPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setDataSource()
        bindViewModel()
        bindView()
        bookTrigger.onNext(())
    }
    
    private func setUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(titleLabel)
        self.view.addSubview(collectionView)
        
        collectionView.showsVerticalScrollIndicator = false
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(46)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - Bind
extension HomeViewController {
    
    private func bindViewModel() {
        let input = HomeViewModel.Input(bookTrigger: bookTrigger.asObservable(),
                                        horizontalPageTrigger: horizontalPageTrigger,
                                        selectedCategoryTrigger: selectedCategoryTrigger,
                                        verticalPageTrigger: verticalPageTrigger)
        let output = viewModel.transform(input: input)
        
        output.bookResult
            .observe(on: MainScheduler.instance)
            .bind { [weak self] result in
                switch result {
                case .success(let bookResult):
                    var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>()
                    
                    let bannerItems = bookResult.bestseller.item.map { HomeItem.bannerItem($0) }
                    self?.bannerItemCount = bannerItems.count / 3
                    let bannerSection = HomeSection.banner
                    snapshot.appendSections([bannerSection])
                    snapshot.appendItems(bannerItems, toSection: bannerSection)
                    
                    let carouselItems = bookResult.editorChoice.item.map { HomeItem.carouselItem($0) }
                    self?.carouselItemCount = carouselItems.count / 3
                    let carouselSection = HomeSection.carousel("편집자 추천!")
                    snapshot.appendSections([carouselSection])
                    snapshot.appendItems(carouselItems, toSection: carouselSection)
                    
                    let carouselFooterItems = bookResult.editorChoice.item.map { HomeItem.carouselFooterItem($0) }
                    self?.carouselDatas = carouselFooterItems
                    let carouselFirstItem = carouselFooterItems.first ?? HomeItem.carouselFooterItem(.stub1)
                    let carouselFooterSection = HomeSection.carouselFooter
                    snapshot.appendSections([carouselFooterSection])
                    snapshot.appendItems([carouselFirstItem], toSection: carouselFooterSection)
                    
                    let horizontalItems = bookResult.newSpecial.item.map { HomeItem.horizontalItem($0) }
                    let horizontalSeciton = HomeSection.horizontal("주목할 신간 도서")
                    snapshot.appendSections([horizontalSeciton])
                    snapshot.appendItems(horizontalItems, toSection: horizontalSeciton)
                    
                    let categoryTypes = bookResult.categoryType.categorys.map { HomeItem.categoryTypeItem($0) }
                    let categoryTypeSection = HomeSection.categoryType("카테고리 별 신간 도서")
                    snapshot.appendSections([categoryTypeSection])
                    snapshot.appendItems(categoryTypes, toSection: categoryTypeSection)
                    
                    let categoryItems = bookResult.newCategory.item.map { HomeItem.categoryItem($0) }
                    let categorySection = HomeSection.category
                    snapshot.appendSections([categorySection])
                    snapshot.appendItems(categoryItems, toSection: categorySection)
                    
                    let newAllItems = bookResult.newAll.item.map { HomeItem.verticalItem($0) }
                    let newAllSection = HomeSection.vertical("신간 도서")
                    snapshot.appendSections([newAllSection])
                    snapshot.appendItems(newAllItems, toSection: newAllSection)
                    
                    self?.dataSource?.apply(snapshot) { [weak self] in
                        guard let self = self else { return }
                        self.collectionView.scrollToItem(at: [0, bannerItemCount],
                                                         at: .left,
                                                         animated: false)
                        self.collectionView.scrollToItem(at: [1, carouselItemCount],
                                                         at: .left,
                                                         animated: false)
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }.disposed(by: disposeBag)
        
        output.horizontalPageResult
            .observe(on: MainScheduler.instance)
            .bind { [weak self] result in
                switch result {
                case .success(let bookList):
                    guard let self = self, let dataSource = self.dataSource else { return }
                    let items = bookList.item.map { HomeItem.horizontalItem($0) }
                    var snapshot = dataSource.snapshot()
                    let section = HomeSection.horizontal("주목할 신간 도서")
                    snapshot.appendItems(items, toSection: section)
                    dataSource.apply(snapshot)

                case .failure(let error):
                    print(error)
                }
            }.disposed(by: disposeBag)
        
        output.categoryResult
            .observe(on: MainScheduler.instance)
            .bind { [weak self] result in
                switch result {
                case .success(let bookList):
                    guard let self = self, let dataSource = self.dataSource else { return }
                    let items = bookList.item.map { HomeItem.categoryItem($0) }
                    var snapshot = dataSource.snapshot()
                    let section = HomeSection.category
                    snapshot.deleteItems(snapshot.itemIdentifiers(inSection: section))
                    snapshot.appendItems(items, toSection: section)
                    dataSource.apply(snapshot)
                    
                case .failure(let error):
                    print(error)
                }
            }.disposed(by: disposeBag)
        
        output.verticalPageResult
            .observe(on: MainScheduler.instance)
            .bind { [weak self] result in
                switch result {
                case .success(let bookList):
                    guard let self = self, let dataSource = self.dataSource else { return }
                    let items = bookList.item.map { HomeItem.verticalItem($0) }
                    var snapshot = dataSource.snapshot()
                    let section = HomeSection.vertical("신간 도서")
                    snapshot.appendItems(items, toSection: section)
                    dataSource.applySnapshotUsingReloadData(snapshot)

                case .failure(let error):
                    print(error)
                }
            }.disposed(by: disposeBag)
    }
    
    private func bindView() {
        collectionView.rx.itemSelected.bind { [weak self] indexPath in
            let item = self?.dataSource?.itemIdentifier(for: indexPath)
            switch item {
            case .categoryTypeItem(let category):
                self?.selectedCategoryTrigger.onNext(category.id)
                self?.collectionView.scrollToItem(at: [5, 0],
                                                  at: .left,
                                                  animated: true)
            default:
                print("default")
            }
        }.disposed(by: disposeBag)
    }
}

// MARK: - Layout 관련
extension HomeViewController {
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
            let section = self?.dataSource?.sectionIdentifier(for: sectionIndex)
            switch section {
            case .banner:
                return self?.createBannerSection()
            case .carousel:
                return self?.createCarouselSection()
            case .carouselFooter:
                return self?.createCarouselFooterSection()
            case .horizontal:
                return self?.createHorizontalSection()
            case .categoryType:
                return self?.createCategoryTypeSection()
            case .category:
                return self?.createCategorySection()
            case .vertical:
                return self?.createVerticalSection()
            default:
                return self?.createBannerSection()
            }
        })
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0)
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, environment in
            // offset.y == 0 && visibleItems.count == 2 조건을 넣지 않으면 세로 스크롤에도 반응하게 됨
            if offset.y == 0 && visibleItems.count == 2 {
                guard let lastIndexPath = visibleItems.last?.indexPath, let self = self else { return }
                if lastIndexPath.section == 0 {
                    self.handleVisibleItemIndexPath(lastIndexPath.row,
                                                    sectionNum: 0,
                                                    count: self.bannerItemCount)
                }
            }
        }
        return section
    }
    
    private func createCarouselSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(220),
                                               heightDimension: .absolute(300))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .topLeading)
        section.boundarySupplementaryItems = [header]
        
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, environment in
            // Header를 제외하고 나머지 cellItem만 구별
            let cellItems = visibleItems.filter { $0.representedElementKind != UICollectionView.elementKindSectionHeader }
            let containerWidth = environment.container.contentSize.width
            
            cellItems.forEach { item in
                let itemCenterRelativeToOffset = item.frame.midX - offset.x
                
                // 셀이 컬렉션 뷰의 중앙에서 얼마나 떨어져 있는지 확인
                let distanceFromCenter = abs(itemCenterRelativeToOffset - containerWidth / 2.0)
                
                // 셀의 이동에 따라서 스케일 조절
                let minScale: CGFloat = 0.7
                let maxScale: CGFloat = 1.0
                let scale = max(maxScale - (distanceFromCenter / containerWidth), minScale)
                
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
                
                // 아이템이 중심부에 왔을 때 무한 스크롤을 위해 자동 스크롤 해주기
                guard let lastIndex = visibleItems.last?.indexPath.row, let self = self else { return }
                if distanceFromCenter >= 0 && distanceFromCenter < 1 && offset.y == 440 {
                    self.handleVisibleItemIndexPath(lastIndex,
                                                    sectionNum: 1,
                                                    count: self.carouselItemCount)
                    
                    // 스크롤에 따라서 CarouselFooterSection Data update 해주기
                    if self.curIndex != lastIndex && lastIndex != 0 {
                        self.updateCarouselFooterSection(lastIndex-1)
                        self.curIndex = lastIndex
                    }
                }
            }
        }
        return section
    }
    
    private func createCarouselFooterSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0)
        return section
    }
    
    private func createHorizontalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(120),
                                               heightDimension: .absolute(220))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 40, trailing: 20)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .topLeading)
        section.boundarySupplementaryItems = [header]
        
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, environment in
            guard let self = self else { return }
            if offset.y == 944 {
                let endOffset = CGFloat(120 * 18 * self.horizontalPage + 20) - environment.container.contentSize.width
                if offset.x >= endOffset {
                    self.horizontalPage += 1
                    self.horizontalPageTrigger.onNext(self.horizontalPage)
                }
            }
        }
        
        return section
    }
    
    private func createCategoryTypeSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(50),
                                               heightDimension: .absolute(70))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .topLeading)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createCategorySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(240))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 20)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
        
        return section
    }
    
    private func createVerticalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(300))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.interItemSpacing = .fixed(20)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .topLeading)
        section.boundarySupplementaryItems = [header]
        
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, environment in
            guard let self = self else { return }
            if offset.y >= 900 + CGFloat(300 * 8 * self.verticalPage) {
                self.verticalPage += 1
                self.verticalPageTrigger.onNext(self.verticalPage)
            }
        }
        
        return section
    }
    
    private func updateCarouselFooterSection(_ index: Int) {
        guard let dataSource = dataSource else { return }
        let item = [carouselDatas[index]]
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .carouselFooter))
        snapshot.appendItems(item, toSection: .carouselFooter)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func handleVisibleItemIndexPath(_ index: Int, sectionNum: Int, count: Int) {
        if sectionNum == 0 && index == count - 1 {
            self.collectionView.scrollToItem(at: [0, count * 2 - 1], at: .left, animated: false)
        } else if sectionNum == 0 && index == count * 2 + 1 {
            self.collectionView.scrollToItem(at: [0, count + 1], at: .left, animated: false)
        } else if sectionNum == 1 && index == count - 1 {
            self.collectionView.scrollToItem(at: [1, count * 2 - 2], at: .left, animated: false)
        } else if sectionNum == 1 && index == count * 2 + 1 {
            self.collectionView.scrollToItem(at: [1, count], at: .left, animated: false)
        }
    }
}

// MARK: - DataSource
extension HomeViewController {
    
    private func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource<HomeSection,HomeItem>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                switch item {
                case .bannerItem(let bestseller):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: BestsellcerCell.id,
                        for: indexPath
                    ) as? BestsellcerCell
                    
                    cell?.configure(title: bestseller.title,
                                    desc: bestseller.desc,
                                    url: bestseller.coverURL)
                    return cell
                    
                case .carouselItem(let editor):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: EditorChoiceCell.id,
                        for: indexPath
                    ) as? EditorChoiceCell
                    
                    cell?.configure(url: editor.coverURL)
                    return cell
                    
                case .carouselFooterItem(let book):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CarouselFooterCell.id,
                        for: indexPath
                    ) as? CarouselFooterCell
                    
                    cell?.configure(title: book.title, desc: book.desc)
                    return cell
                    
                case .horizontalItem(let special):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: HorizontalCell.id,
                        for: indexPath
                    ) as? HorizontalCell
                    
                    cell?.configure(title: special.title, url: special.coverURL)
                    return cell
                    
                case .categoryTypeItem(let category):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CategoryTypeCell.id,
                        for: indexPath
                    ) as? CategoryTypeCell
                    
                    cell?.configure(title: category.title, imageName: category.image)
                    return cell
                    
                case .categoryItem(let category):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CategoryCell.id,
                        for: indexPath
                    ) as? CategoryCell
                    
                    cell?.configure(title: category.title, desc: category.desc, url: category.coverURL)
                    return cell
                    
                case .verticalItem(let newAll):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: VerticalCell.id,
                        for: indexPath
                    ) as? VerticalCell
                    
                    cell?.configure(title: newAll.title, url: newAll.coverURL)
                    return cell
                }
            })
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: HeaderView.id,
                                                                         for: indexPath)
            let section = self?.dataSource?.sectionIdentifier(for: indexPath.section)
            
            switch section {
            case .carousel(let title), .horizontal(let title), .categoryType(let title), .vertical(let title):
                (header as? HeaderView)?.configure(title: title)
            default:
                print("Default")
            }
            
            return header
        }
    }
}
