//
//  MutableDataSource.swift
//  DataSource
//
//  Created by Vadim Yelagin on 04/06/15.
//  Copyright (c) 2015. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// `DataSource` implementation that has one section of items of type T.
///
/// The array of items can be modified by calling methods that perform
/// individual changes and instantly make the dataSource emit
/// a corresponding dataChange.
public final class MutableDataSource<T>: DataSource {

	public let changes: BehaviorSubject<DataChange>

	fileprivate let _items: BehaviorRelay<[T]>

	public var items: BehaviorRelay<[T]> {
		return _items
	}

	public let supplementaryItems: [String: Any]

	public init(_ items: [T] = [], supplementaryItems: [String: Any] = [:]) {
		self.changes = BehaviorSubject(value: DataChangeBatch([]))
		self._items = BehaviorRelay(value: items)
		self.supplementaryItems = supplementaryItems
	}

	public let numberOfSections = 1

	public func numberOfItemsInSection(_ section: Int) -> Int {
		return self._items.value.count
	}

	public func supplementaryItemOfKind(_ kind: String, inSection section: Int) -> Any? {
		return self.supplementaryItems[kind]
	}

	public func item(at indexPath: IndexPath) -> Any {
		return self._items.value[indexPath.item]
	}

	public func leafDataSource(at indexPath: IndexPath) -> (DataSource, IndexPath) {
		return (self, indexPath)
	}

	/// Inserts a given item at a given index
	/// and emits `DataChangeInsertItems`.
	public func insertItem(_ item: T, at index: Int) {
		self.insertItems([item], at: index)
	}

	/// Inserts items at a given index
	/// and emits `DataChangeInsertItems`.
	public func insertItems(_ items: [T], at index: Int) {
		var items = self._items.value
		items.insert(contentsOf: items, at: index)
		self._items.accept(items)
		let change = DataChangeInsertItems(items.indices.map { z(index + $0) })
		self.changes.onNext(DataChangeBatch([change]))
	}

	/// Deletes an item at a given index
	/// and emits `DataChangeDeleteItems`.
	public func deleteItem(at index: Int) {
		self.deleteItems(in: Range(index...index))
	}

	/// Deletes items in a given range
	/// and emits `DataChangeDeleteItems`.
	public func deleteItems(in range: Range<Int>) {
		var items = self._items.value
		items.removeSubrange(range)
		self._items.accept(items)
		let change = DataChangeDeleteItems(range.map(z))
		self.changes.onNext(DataChangeBatch([change]))
	}

	/// Replaces an item at a given index with another item
	/// and emits `DataChangeReloadItems`.
	public func replaceItem(at index: Int, with item: T) {
		var items = self._items.value
		items[index] = item
		self._items.accept(items)
		let change = DataChangeReloadItems(z(index))
		self.changes.onNext(DataChangeBatch([change]))
	}

	/// Moves an item at a given index to another index
	/// and emits `DataChangeMoveItem`.
	public func moveItem(at oldIndex: Int, to newIndex: Int) {
		var items = self._items.value
		let item = items.remove(at: oldIndex)
		items.insert(item, at: newIndex)
		self._items.accept(items)
		let change = DataChangeMoveItem(from: z(oldIndex), to: z(newIndex))
		self.changes.onNext(DataChangeBatch([change]))
	}

	/// Replaces all items with a given array of items
	/// and emits `DataChangeReloadSections`.
	public func replaceItems(with items: [T]) {
		self._items.accept(items)
		let change = DataChangeReloadSections([0])
		self.changes.onNext(DataChangeBatch([change]))
	}

}

private func z(_ index: Int) -> IndexPath {
	return IndexPath(item: index, section: 0)
}
