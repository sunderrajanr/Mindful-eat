//
//  AppRouteProtocols.swift
//  EAT
//
//  Created by Emlyn Murphy on 2/15/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import Foundation

protocol MainTabBarControllerRouteManagement {
    weak var mainTabBarController: MainTabBarController? { get set }
}

protocol DiaryViewControllerRouteManagement {
    weak var diaryViewController: EATDiaryViewController? { get set }
}

protocol RatingViewControllerRouteManagement {
    weak var ratingViewController: EATRatingViewController? { get set }
}
