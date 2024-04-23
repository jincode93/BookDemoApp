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
    case carousel(String)
    case carouselFooter
}

fileprivate enum Item: Hashable {
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
    
    private var dataSource: UICollectionViewDiffableDataSource<Section,Item>?
    
    let bookTrigger = PublishSubject<Void>()
    let carouselIndexTrigger = PublishSubject<Int>()
    var bannerItemCount: Int = 0
    var carouselItemCount: Int = 0
    
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
}

// MARK: - Bind
extension HomeViewController {
    
    private func bindViewModel() {
        let input = HomeViewModel.Input(bookTrigger: bookTrigger.asObservable(),
                                        carouselIndexTrigger: carouselIndexTrigger.asObserver())
        let output = viewModel.transform(input: input)
        
        output.bestsellerList.bind { [weak self] result in
            switch result {
            case .success(let result):
                self?.bannerItemCount = result.item.count / 3
                
                var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
                let list = result.item.map { Item.bannerImage($0) }
                let section = Section.banner
                snapshot.append(list)
                self?.dataSource?.apply(snapshot, to: section) 
//                { [weak self] in
//                    guard let self = self else { return }
//                    self.collectionView.scrollToItem(at: [0, self.bannerItemCount],
//                                                      at: .left,
//                                                      animated: false)
//                }
                
            case .failure(let error):
                print(error)
            }
        }.disposed(by: disposeBag)
        
        output.editorChoiceList.bind { [weak self] result in
            switch result {
            case .success(let result):
                self?.carouselItemCount = result.item.count / 3
                
                var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
                let list = result.item.map { Item.carouselImage($0) }
                let section = Section.carousel("편집자 추천!")
                snapshot.append(list)
                
                self?.dataSource?.apply(snapshot, to: section) 
//                { [weak self] in
//                    guard let self = self else { return }
//                    self.collectionView.scrollToItem(at: [1, self.carouselItemCount],
//                                                      at: .left,
//                                                      animated: false)
//                }
//                
            case .failure(let error):
                print(error)
            }
        }.disposed(by: disposeBag)
        
        output.curEditorChoiceBook.bind { [weak self] result in
            switch result {
            case .success(let book):
                var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
                let item = Item.carouselFooter(book)
                let section = Section.carouselFooter
                snapshot.append([item])
                self?.dataSource?.apply(snapshot, to: section, animatingDifferences: false)
                
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
            // offset.y == 0 조건을 넣지 않으면 세로 스크롤에도 반응하게 됨
            if offset.y == 0 {
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
                if distanceFromCenter >= 0 && distanceFromCenter < 1 && offset.y == 430 {
                    guard let lastIndexPath = visibleItems.last?.indexPath, let self = self else { return }
                    self.handleVisibleItemIndexPath(lastIndexPath.row,
                                                    sectionNum: 1,
                                                    count: self.carouselItemCount)
                    self.carouselIndexTrigger.onNext(lastIndexPath.row)
                }
            }
        }
        
        return section
    }
    
    private func handleVisibleItemIndexPath(_ index: Int, sectionNum: Int, count: Int) {
        if sectionNum == 0 && index == count - 1 {
            self.collectionView.scrollToItem(at: [0, count * 2 - 1], at: .left, animated: false)
        } else if sectionNum == 0 && index == count * 2 + 1 {
            self.collectionView.scrollToItem(at: [0, count], at: .left, animated: false)
        } else if sectionNum == 1 && index == count - 1 {
            self.collectionView.scrollToItem(at: [1, count * 2 - 2], at: .left, animated: false)
        } else if sectionNum == 1 && index == count * 2 + 1 {
            self.collectionView.scrollToItem(at: [1, count], at: .left, animated: false)
        }
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
}

// MARK: - DataSource
extension HomeViewController {
    
    private func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section,Item>(
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
