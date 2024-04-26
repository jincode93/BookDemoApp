//
//  HomeSectionItem.swift
//  BookDemoApp
//
//  Created by Zerom on 4/26/24.
//

import Foundation

enum HomeSection: Hashable {
    case banner
    case carousel(String)
    case carouselFooter
    case horizontal(String)
    case categoryType(String)
    case category
    case vertical(String)
}

enum HomeItem: Hashable {
    case bannerItem(Book)
    case carouselItem(Book)
    case carouselFooterItem(Book)
    case horizontalItem(Book)
    case categoryTypeItem(Category)
    case categoryItem(Book)
    case verticalItem(Book)
}
