//
//  ViewController.swift
//  BookDemoApp
//
//  Created by Zerom on 4/18/24.
//

import UIKit
import RxSwift

enum HomeSection: Hashable {
    case banner
    case carousel(String)
    case carouselFooter
}

enum HomeItem: Hashable {
    case bannerImage(Book)
    case carouselImage(Book)
    case carouselFooter(Book)
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
        collectionView.register(EditorChoiceCell.self, forCellWithReuseIdentifier: EditorChoiceCell.id)
        collectionView.register(HeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderView.id)
        collectionView.register(CarouselFooterCell.self, forCellWithReuseIdentifier: CarouselFooterCell.id)
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<HomeSection,HomeItem>?
    
    let bookTrigger = PublishSubject<Void>()
    var bannerItemCount: Int = 0
    var carouselItemCount: Int = 0
    var carouselDatas: [HomeItem] = []
    var curIndex = 0
    
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
        let input = HomeViewModel.Input(bookTrigger: bookTrigger.asObservable())
        let output = viewModel.transform(input: input)
        
        output.bookResult
            .observe(on: MainScheduler.instance)
            .bind { [weak self] result in
                switch result {
                case .success(let bookResult):
                    var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>()
                    
                    let bannerItems = bookResult.bestseller.item.map { HomeItem.bannerImage($0) }
                    self?.bannerItemCount = bannerItems.count / 3
                    let bannerSection = HomeSection.banner
                    snapshot.appendSections([bannerSection])
                    snapshot.appendItems(bannerItems, toSection: bannerSection)
                    
                    let carouselItems = bookResult.editorChoice.item.map { HomeItem.carouselImage($0) }
                    self?.carouselItemCount = carouselItems.count / 3
                    let carouselSection = HomeSection.carousel("편집자 추천!")
                    snapshot.appendSections([carouselSection])
                    snapshot.appendItems(carouselItems, toSection: carouselSection)
                    
                    let carouselFooterItems = bookResult.editorChoice.item.map { HomeItem.carouselFooter($0) }
                    self?.carouselDatas = carouselFooterItems
                    let carouselFirstItem = carouselFooterItems.first ?? HomeItem.carouselFooter(.stub1)
                    let carouselFooterSection = HomeSection.carouselFooter
                    snapshot.appendSections([carouselFooterSection])
                    snapshot.appendItems([carouselFirstItem], toSection: carouselFooterSection)
                    
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
    }
}

// MARK: - Layout 관련
extension HomeViewController {
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 30
        
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
            let section = self?.dataSource?.sectionIdentifier(for: sectionIndex)
            switch section {
            case .banner:
                return self?.createBannerSection()
            case .carousel:
                return self?.createCarouselSection()
            case .carouselFooter:
                return self?.createCarouselFooterSection()
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
                if distanceFromCenter >= 0 && distanceFromCenter < 1 && offset.y == 430 {
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
                case .bannerImage(let bestseller):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: BestsellcerCell.id,
                        for: indexPath
                    ) as? BestsellcerCell
                    
                    cell?.configure(title: bestseller.title,
                                    desc: bestseller.desc,
                                    url: bestseller.coverURL)
                    return cell
                    
                case .carouselImage(let editor):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: EditorChoiceCell.id,
                        for: indexPath
                    ) as? EditorChoiceCell
                    
                    cell?.configure(url: editor.coverURL)
                    return cell
                    
                case .carouselFooter(let book):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CarouselFooterCell.id,
                        for: indexPath
                    ) as? CarouselFooterCell
                    
                    cell?.configure(title: book.title, desc: book.desc)
                    return cell
                }
            })
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: HeaderView.id,
                                                                         for: indexPath)
            let section = self?.dataSource?.sectionIdentifier(for: indexPath.section)
            
            switch section {
            case .carousel(let title):
                (header as? HeaderView)?.configure(title: title)
            default:
                print("Default")
            }
            
            return header
        }
    }
}
