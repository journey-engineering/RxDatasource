//
//  ObservableExtensions.swift
//  RXDataSource-iOS
//
//  Created by Thibault Gauche on 06/12/2018.
//  Copyright © 2018. All rights reserved.
//

import UIKit
import RxSwift

extension ObservableType {
	func combinePrevious(_ first: E) -> Observable<(E, E)> {
		return scan((first, first)) { ($0.1, $1) }.skip(1)
	}
}
