//
//  EmptyDataSource.swift
//  DataSource
//
//  Created by Vadim Yelagin on 04/06/15.
//  Copyright (c) 2015. All rights reserved.
//

import Foundation
import RxSwift

/// `DataSource` implementation that has zero sections.
///
/// Never emits any dataChanges.
public final class EmptyDataSource: DataSource {
	public var changes: BehaviorSubject<DataChange>

	public init() {
		self.changes = BehaviorSubject(value: DataChangeBatch([]))
	}

	public let numberOfSections = 0

	public func numberOfItemsInSection(_ section: Int) -> Int {
		fatalError("Trying to access EmptyDataSource.numberOfItemsInSection(_:)")
	}

	public func supplementaryItemOfKind(_ kind: String, inSection section: Int) -> Any? {
		fatalError("Trying to access EmptyDataSource.supplementaryItemOfKind(_:inSection:)")
	}

	public func item(at indexPath: IndexPath) -> Any {
		fatalError("Trying to access EmptyDataSource.item(at:)")
	}

	public func leafDataSource(at indexPath: IndexPath) -> (DataSource, IndexPath) {
		fatalError("Trying to access EmptyDataSource.leafDataSource(at:)")
	}

}
