//
//  BinaryNode.swift
//  BinaryNode
//
//  Created by Valeriano Della Longa on 2021/01/27.
//  Copyright © 2020 Valeriano Della Longa
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use, copy,
//  modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
//  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
//  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
/// A protocol defining functionalites for a 2-node data structure with reference semantics.
/// That is a 2-node is a node with a key/value pair as element and two children nodes,
/// one at its left and one at its right.
/// Thus recursively defining a binary tree.
public protocol BinaryNode: AnyObject, Sequence where Element == (Key, Value) {
    
    associatedtype Key
    
    associatedtype Value
    
    /// The key for this node
    var key: Key { get }
    
    /// The value stored in this node
    var value: Value { get }
    
    /// The number of elements for this node.
    var count: Int { get }
    
    /// The child node to the left of this node.
    var left: Self? { get }
    
    /// The child node to the right of this node.
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
    /// The key-value pair for this node.
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
    /// Traverse the binary tree rooted at this node in-order executing the given `body` closure
    /// on each node during the traversal operation.
    ///
    /// - Parameter _: a closure to execute on every node during the traversal.
    /// - Complexity:   O(`n`) where `n` is the count of nodes in the tree rooted at this
    ///                 node.
    public func inOrderTraverse(_ body: (Self) throws -> Void) rethrows {
        try left?.inOrderTraverse(body)
        try body(self)
        try right?.inOrderTraverse(body)
    }
    /// Traverse the binary tree rooted at this node in reverse-in-order executing the given
    /// `body` closure on each node during the traversal operation.
    ///
    /// - Parameter _: a closure to execute on every node during the traversal.
    /// - Complexity:   O(`n`) where `n` is the count of nodes in the tree rooted at this
    ///                 node.
    public func reverseInOrderTraverse(_ body: (Self) throws -> Void) rethrows {
        try right?.reverseInOrderTraverse(body)
        try body(self)
        try left?.reverseInOrderTraverse(body)
    }
    /// Traverse the binary tree rooted at this node in pre-order executing the given `body`
    /// closure on each node during the traversal operation.
    ///
    /// - Parameter _: a closure to execute on every node during the traversal.
    /// - Complexity:   O(`n`) where `n` is the count of nodes in the tree rooted at this
    ///                 node.
    public func preOrderTraverse(_ body: (Self) throws -> Void) rethrows {
        try body(self)
        try self.left?.preOrderTraverse(body)
        try self.right?.preOrderTraverse(body)
    }
    
    /// Traverse the binary tree rooted at this node in post-order executing the given `body`
    /// closure on each node during the traversal operation.
    ///
    /// - Parameter _: a closure to execute on every node during the traversal.
    /// - Complexity:   O(`n`) where `n` is the count of nodes in the tree rooted at this
    ///                 node.
    public func postOrderTraverse(_ body: (Self) throws -> Void) rethrows {
        try left?.postOrderTraverse(body)
        try right?.postOrderTraverse(body)
        try body(self)
    }
    /// Traverse the binary tree rooted at this node in level-order executing the given `body`
    /// closure on each node during the traversal operation.
    ///
    /// - Parameter _: a closure to execute on every node during the traversal.
    /// - Complexity:   Amortized O(`n`) where `n` is the count of nodes in the tree
    ///                 rooted at this node.
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
    /// The nodes to traverse in the tree rooted at this node to get to a leaf.
    public typealias Path = [WrappedNode<Self>]
    
    /// Every path to leaf nodes in the tree rooted at this node.
    ///
    /// Every node in a path is wrapped as an `unowned(unsafe)` instance,
    /// not to strongly reference it and increase its reference count: therefore a path
    /// is not reliable to be stored.
    /// Attempting to access a node in a path when the original node was already
    /// deallocated results in unexpected beahvior and potential run-time errors.
    /// Additionally when a node is changed, the path in which was previously stored
    /// might as well not be valid anymore.
    /// - Complexity:   O(*n²*) where *n* is the lenght of the tree
    ///                 rooted at this node.
    public var paths: [Path] { buildPaths(self, current: []) }
    
    fileprivate func buildPaths(_ node: Self, current: Path) -> [Path] {
        var paths = [Path]()
        let updated = current + [WrappedNode(node: node)]
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
    /// A boolean value, `true` when the tree rooted at this node is a Binary Search Tree.
    ///
    /// A Binary Search Tree holds the invariant recursively so that the left children has a smaller
    /// `key` than the node and the right children has a greater `key` than the node.
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
    
    /// Lookup and returns the node with the given `key` in the tree rooted at this node, by
    /// adopting a binary search on it.
    ///
    /// - Parameter needle: The `key` to lookup for.
    /// - Returns:  The node in the tree with the given `key`, or `nil` if such a node
    ///             couldn't be found.
    /// - Complexity:   O(log *n*) where *n* is the count of nodes in the tree rooted at
    ///                 this node.
    /// - Note: If the tree rooted at this node is not a Binary Search Tree, then this method
    ///         won't behave as expected.
    public func binarySearch(_ needle: Key) -> Self? {
        if needle < key { return left?.binarySearch(needle) }
        if needle > key { return right?.binarySearch(needle) }
        if needle == key { return self }
        
        return nil
    }
    
}

// MARK: - Sequential Search
extension BinaryNode where Key: Equatable {
    /// Lookup for the node with the given `key` in the tree rooted at this node.
    ///
    /// - Parameter needle: The `key` to lookup for.
    /// - Returns:  The node in the tree with the given `key`, or `nil` if such a node
    ///             couldn't be found.
    /// - Complexity:   O(*n*) where *n* is the count of nodes in the tree rooted at this
    ///                 node.
    /// - Note: This search algorithm prioritizes the subtree on the left over the one on the
    ///         right when recursively checking a node which has not its `key` equal to the
    ///         one looked for.
    public func sequentialSearch(_ needle: Key) -> Self? {
        if needle == key { return self }
        
        return left?.sequentialSearch(needle) ?? right?.sequentialSearch(needle)
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

// MARK: - WrappedNode
/// Wraps an `unowned(unsafe)` instance of `BinaryNode` used
/// to weakly reference node instances without incrementing their reference count.
public struct WrappedNode<Node: BinaryNode> {
    unowned(unsafe) let node: Node
    
}
