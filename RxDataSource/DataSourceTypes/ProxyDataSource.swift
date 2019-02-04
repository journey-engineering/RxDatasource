//
//  ProxyDataSource.swift
//  DataSource
//
//  Created by Vadim Yelagin on 04/06/15.
//  Copyright (c) 2015. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// `DataSource` implementation that returns data from
/// another dataSource (called inner dataSource).
///
/// The inner dataSource can be switched to a different
/// dataSource instance. In this case the proxyDataSource
/// emits a dataChange reloading its entire data.
///
/// ProxyDataSource listens to dataChanges of its inner dataSource
/// and emits them as its own changes.
public final class ProxyDataSource: DataSource {

	public let changes: BehaviorSubject<DataChange>
	fileprivate let disposeBag = DisposeBag()
	fileprivate var lastDisposable: Disposable?

	public let innerDataSource: BehaviorRelay<DataSource>

	/// When `true`, switching innerDataSource produces
	/// a dataChange consisting of deletions of all the
	/// sections of the old inner dataSource and insertion of all
	/// the sections of the new innerDataSource.
	///
	/// when `false`, switching innerDataSource produces `DataChangeReloadData`.
	public let animatesChanges: BehaviorRelay<Bool>

	public init(_ inner: DataSource = EmptyDataSource(), animateChanges: Bool = true) {
		self.changes = BehaviorSubject(value: DataChangeBatch([]))
		self.innerDataSource = BehaviorRelay(value: inner)
		self.animatesChanges = BehaviorRelay(value: animateChanges)

		self.lastDisposable = inner.changes.asObservable().subscribe { [weak self] in
			self?.changes.on($0)
		}

		self.innerDataSource.asObservable().combinePrevious(inner).subscribe(onNext: { [weak self] old, new in
			if let this = self {
				this.lastDisposable?.dispose()
				this.changes.onNext(changeDataSources(old, new, this.animatesChanges.value))
				this.lastDisposable = new.changes.asObservable().subscribe { [weak self] in
					self?.changes.on($0)
				}
			}
		}).disposed(by: self.disposeBag)
	}

	deinit {
		self.lastDisposable?.dispose()
	}

	public var numberOfSections: Int {
		let inner = self.innerDataSource.value
		return inner.numberOfSections
	}

	public func numberOfItemsInSection(_ section: Int) -> Int {
		let inner = self.innerDataSource.value
		return inner.numberOfItemsInSection(section)
	}

	public func supplementaryItemOfKind(_ kind: String, inSection section: Int) -> Any? {
		let inner = self.innerDataSource.value
		return inner.supplementaryItemOfKind(kind, inSection: section)
	}

	public func item(at indexPath: IndexPath) -> Any {
		let inner = self.innerDataSource.value
		return inner.item(at: indexPath)
	}

	public func leafDataSource(at indexPath: IndexPath) -> (DataSource, IndexPath) {
		let inner = self.innerDataSource.value
		return inner.leafDataSource(at: indexPath)
	}

}

private func changeDataSources(_ old: DataSource, _ new: DataSource, _ animateChanges: Bool) -> DataChange {
	if !animateChanges {
		return DataChangeReloadData()
	}
	var batch: [DataChange] = []
	let oldSections = old.numberOfSections
	if oldSections > 0 {
		batch.append(DataChangeDeleteSections(Array(0 ..< oldSections)))
	}
	let newSections = new.numberOfSections
	if newSections > 0 {
		batch.append(DataChangeInsertSections(Array(0 ..< newSections)))
	}
	return DataChangeBatch(batch)
}