//
//  BinaryNode.swift
//  BinaryNode
//
//  Created by Valeriano Della Longa on 2021/01/27.
//

import Foundation

public protocol BinaryNode: AnyObject, Sequence where Element == (Key, Value) {
    
    associatedtype Key
    
    associatedtype Value
    
    var key: Key { get }
    
    var value: Value { get }
    
    var count: Int { get }
    
    var left: Self? { get }
    
    var right: Self? { get }
}

// MARK: - Default implementations
extension BinaryNode {
    public var count: Int {
        1 + (left?.count ?? 0) + (right?.count ?? 0)
    }
    
}

// MARK: - Sequence default implementation
extension BinaryNode {
    public var element: (Key, Value) { (key, value) }
        
    public var underestimatedCount: Int {
        1 + (left != nil ? 1 : 0) + (right != nil ? 1 : 0)
    }
    
    public func makeIterator() -> AnyIterator<Element> {
        var stack = [Self]()
        var node: Self? = self
        
        return AnyIterator {
            while let n = node {
                stack.append(n)
                node = n.left
            }
            guard
                let current = stack.popLast()
            else { return nil }
            
            defer { node = current.right }
            
            return current.element
        }
    }
    
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try inOrderTraverse { try body($0.element) }
    }
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        var result = [Element]()
        try inOrderTraverse {
            if try isIncluded($0.element) {
                result.append($0.element)
            }
        }
        
        return result
    }
    
    public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        var result = [T]()
        try inOrderTraverse {
            let newValue = try transform($0.element)
            result.append(newValue)
        }
        
        return result
    }
    
    public func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        var result = [ElementOfResult]()
        try inOrderTraverse {
            try transform($0.element)
                .map { result.append($0) }
        }
        
        return result
    }
    
    @available(swift, deprecated: 4.1, renamed: "compactMap(_:)", message: "Please use compactMap(_:) for the case where closure returns an optional value")
    public func flatMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        try compactMap(transform)
    }
    
    public func flatMap<SegmentOfResult>(_ transform: (Element) throws -> SegmentOfResult) rethrows -> [SegmentOfResult.Element] where SegmentOfResult : Sequence {
        var result = [SegmentOfResult.Element]()
        try inOrderTraverse {
            let segment = try transform($0.element)
            result.append(contentsOf: segment)
        }
        
        return result
    }
    
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
        var result = initialResult
        try inOrderTraverse {
            try updateAccumulatingResult(&result, $0.element)
        }
        
        return result
    }
    
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        try reduce(into: initialResult) {
            $0 = try nextPartialResult($0, $1)
        }
    }
    
    public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        if let lF = try left?.first(where: predicate) { return lF }
        if try predicate((key, value)) { return element }
        
        return try right?.first(where: predicate)
    }
    
    public func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        guard
            try (left?.contains(where: predicate) ?? false) == false
        else { return true }
        
        guard
            try predicate(element) == false
        else { return true }
        
        return try (right?.contains(where: predicate) ?? false)
    }
    
    public func allSatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        guard
            try (left?.allSatisfy(predicate) ?? true)
        else { return false }
        
        guard
            try predicate(element)
        else { return false }
        
        return try (right?.allSatisfy(predicate) ?? true)
    }
    
    public func reversed() -> [Element] {
        var result = [(Key, Value)]()
        reverseInOrderTraverse { result.append($0.element) }
        
        return result
    }
    
}

// MARK: - Tree and binary search tree operations
// MARK: - Tree traversal operations
extension BinaryNode {
    public func inOrderTraverse(_ body: (Self) throws -> Void) rethrows {
        try left?.inOrderTraverse(body)
        try body(self)
        try right?.inOrderTraverse(body)
    }
    
    public func reverseInOrderTraverse(_ body: (Self) throws -> Void) rethrows {
        try right?.reverseInOrderTraverse(body)
        try body(self)
        try left?.reverseInOrderTraverse(body)
    }
    
    public func preOrderTraverse(_ body: (Self) throws -> Void) rethrows {
        try body(self)
        try self.left?.preOrderTraverse(body)
        try self.right?.preOrderTraverse(body)
    }
    
    public func postOrderTraverse(_ body: (Self) throws -> Void) rethrows {
        try left?.postOrderTraverse(body)
        try right?.postOrderTraverse(body)
        try body(self)
    }
    
    public func levelOrderTraverse(_ body: (Self) throws -> Void) rethrows {
        var currentLevel = _Queue<Self>()
        currentLevel.enqueue(self)
        
        try _levelOrder(currentLevel: &currentLevel, body: body)
    }
    
    
    fileprivate func _levelOrder(currentLevel: inout _Queue<Self>, body: (Self) throws -> Void) rethrows {
        var nextLevel = _Queue<Self>()
        
        while let node = currentLevel.dequeue() {
            try body(node)
            
            if let l = node.left { nextLevel.enqueue(l) }
            
            if let r = node.right { nextLevel.enqueue(r) }
        }
        guard !nextLevel.isEmpty else { return }
        
        try _levelOrder(currentLevel: &nextLevel, body: body)
    }
    
}

// MARK: - paths
extension BinaryNode {
    public typealias Path = [Self]
    
    public var paths: [Path] { buildPaths(self, current: []) }
    
    fileprivate func buildPaths(_ node: Self, current: Path) -> [Path] {
        var paths = [Path]()
        let updated = current + [node]
        if node.left == nil && node.right == nil {
            paths.append(updated)
        } else {
            if let l = node.left {
                paths += buildPaths(l, current: updated)
            }
            if let r = node.right {
                paths += buildPaths(r, current: updated)
            }
        }
        
        return paths
    }
    
}

// MARK: - Binary Search Tree utilities
extension BinaryNode where Key: Comparable {
    public var isBinarySearchTree: Bool {
        if let left = left {
            guard
                left.key < key,
                left.isBinarySearchTree
            else { return false }
        }
        
        if let right = right {
            guard
                right.key > key,
                right.isBinarySearchTree
            else { return false }
        }
        
        return true
    }
    
    public func binarySearch(_ needle: Key) -> Self? {
        if needle < key { return left?.binarySearch(needle) }
        if needle > key { return right?.binarySearch(needle) }
        if needle == key { return self }
        
        return nil
    }
    
}


// MARK: - Queue used internally for level order tree traversal
fileprivate struct _Queue<Element>: Sequence {
    private var enqueued: [Element] = []
    
    private var dequeued: [Element] = []
    
    var count: Int { enqueued.count + dequeued.count }
    
    var underestimatedCount: Int { dequeued.count }
    
    var isEmpty: Bool { enqueued.isEmpty && dequeued.isEmpty }
    
    mutating func enqueue(_ newElement: Element) {
        enqueued.append(newElement)
    }
    
    mutating func dequeue() -> Element? {
        if dequeued.isEmpty && !enqueued.isEmpty {
            dequeued = enqueued.reversed()
            enqueued.removeAll()
        }
        
        return dequeued.popLast()
    }
    
    mutating func next() -> Element? { dequeue() }
    
    func makeIterator() -> AnyIterator<Element> {
        var elements = self
        
        return AnyIterator { elements.next() }
    }
    
}
