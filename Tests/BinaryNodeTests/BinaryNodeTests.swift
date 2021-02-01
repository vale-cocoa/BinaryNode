//
//  BinaryNodeTests.swift
//  BinaryNodeTests
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

import XCTest
@testable import BinaryNode

final class BinaryNodeTests: XCTestCase {
    var sut: TestNode<String, Int>!
    
    override func setUp() {
        super.setUp()
        
        sutSetUp()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    private func sutSetUp() {
        let key = givenKeys
            .dropFirst(4)
            .dropLast(4)
            .randomElement()!
        let value = randomValue()
        sut = TestNode(key: key, value: value)
    }
    
    // MARK: - Given
    private func givenSmallerKeysThanSutKey() -> [String] {
        givenKeys
            .filter { $0 < sut.key }
    }
    
    private func givenLargerKeysThanSutKey() -> [String] {
        givenKeys
            .filter { $0 > sut.key }
    }
    
    private func givenRandomLeaf() -> TestNode<String, Int> {
        TestNode(key: givenKeys.randomElement()!, value: randomValue())
    }
    
    // MARK: - WHEN
    func whenChildrenAreTrees() {
        sut.left = givenRandomLeaf()
        sut.left!.left = givenRandomLeaf()
        sut.left!.right = givenRandomLeaf()
        
        sut.right = givenRandomLeaf()
        sut.right!.left = givenRandomLeaf()
        sut.right!.right = givenRandomLeaf()
    }
    
    func whenChildrenAreTreesAndIsBST() {
        sutSetUp()
        let smallerKeys = givenSmallerKeysThanSutKey().prefix(3)
        let largerKeys = givenLargerKeysThanSutKey().prefix(3)
        sut.left = TestNode(key: smallerKeys[1], value: randomValue())
        sut.left!.left = TestNode(key: smallerKeys[0], value: randomValue())
        sut.left!.right = TestNode(key: smallerKeys[2], value: randomValue())
        
        sut.right = TestNode(key: largerKeys[1], value: randomValue())
        sut.right!.left = TestNode(key: largerKeys[0], value: randomValue())
        sut.right!.right = TestNode(key: largerKeys[2], value: randomValue())
    }
    
    // MARK: -  Default implementations tests
    // MARK: - count tests
    func testCount_whenLeftAndRightAreNil_thenReturnsOne() {
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
        
        XCTAssertEqual(sut.count, 1)
    }
    
    func testCount_whenOneChildIsNilAndTheOtherIsLeaf_thenReturnsTwo() {
        let child = TestNode(key: givenKeys.randomElement()!, value: randomValue())
        XCTAssertNil(child.left)
        XCTAssertNil(child.right)
        
        sut.left = child
        XCTAssertNil(sut.right)
        XCTAssertEqual(sut.count, 2)
        
        sut.left = nil
        sut.right = child
        
        XCTAssertEqual(sut.count, 2)
    }
    
    func testCount_whenBothChildrenAreLeaves_thenReturns3() {
        sut.left = TestNode(key: givenKeys.randomElement()!, value: randomValue())
        sut.right = TestNode(key: givenKeys.randomElement()!, value: randomValue())
        XCTAssertEqual(sut.count, 3)
    }
    
    func testCount_whenChildrenAreTrees_thenReturnsOnePlusLeftAndRightCounts() {
        whenChildrenAreTrees()
        
        let leftCount = sut.left!.count
        let rightCount = sut.right!.count
        let expectedResult = 1 + leftCount + rightCount
        
        XCTAssertEqual(sut.count, expectedResult)
    }
    
    // MARK: - Sequence default implementation tests
    func testUnderEstimatedCount() {
        // When both children are nil,
        // then returns 1
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
        XCTAssertEqual(sut.underestimatedCount, 1)
        
        // When either child is nil and the other is leaf,
        // then returs 2
        sut.left = givenRandomLeaf()
        XCTAssertEqual(sut.underestimatedCount, 2)
        
        sut.left = nil
        sut.right = givenRandomLeaf()
        XCTAssertEqual(sut.underestimatedCount, 2)
        
        // when both children are leaves,
        // then returns 3
        sut.left = givenRandomLeaf()
        XCTAssertEqual(sut.underestimatedCount, 3)
        
        // when either children is a tree and the other is nil,
        // then returns 2
        let leftChildTree = sut.left!
        leftChildTree.left = givenRandomLeaf()
        leftChildTree.right = givenRandomLeaf()
        sut.right = nil
        XCTAssertEqual(sut.underestimatedCount, 2)
        sut.left = nil
        
        let rightChildTree = givenRandomLeaf()
        rightChildTree.left = givenRandomLeaf()
        rightChildTree.right = givenRandomLeaf()
        sut.right = rightChildTree
        XCTAssertEqual(sut.underestimatedCount, 2)
        
        // when both children are tree,
        // then returns 3
        sut.left = leftChildTree
        XCTAssertEqual(sut.underestimatedCount, 3)
    }
    
    func testMakeIterator() {
        XCTAssertNotNil(sut.makeIterator())
    }
    
    func testIteratorNext() {
        // when is leaf, then returns element, then nil
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
        
        var iter = sut.makeIterator()
        var result: (key: String, value: Int)? = iter.next()
        
        XCTAssertEqual(result?.key, sut.key)
        XCTAssertEqual(result?.value, sut.value)
        result = iter.next()
        XCTAssertNil(result)
        
        // when left is leaf, and right is nil,
        // then returns left element, element and then nil
        sut.left = givenRandomLeaf()
        iter = sut.makeIterator()
        
        result = iter.next()
        XCTAssertEqual(result?.key, sut.left!.key)
        XCTAssertEqual(result?.value, sut.left!.value)
        result = iter.next()
        XCTAssertEqual(result?.key, sut.key)
        XCTAssertEqual(result?.value, sut.value)
        result = iter.next()
        XCTAssertNil(result)
        
        // when left is nil and right is leaf, then returns
        // element, then right element, then nil
        sut.left = nil
        sut.right = givenRandomLeaf()
        iter = sut.makeIterator()
        
        result = iter.next()
        XCTAssertEqual(result?.key, sut.key)
        XCTAssertEqual(result?.value, sut.value)
        result = iter.next()
        XCTAssertEqual(result?.key, sut.right!.key)
        XCTAssertEqual(result?.value, sut.right!.value)
        result = iter.next()
        XCTAssertNil(result)
        
        // when bith children are leaves, then returns
        // left element, element, right element, nil
        sut.left = givenRandomLeaf()
        iter = sut.makeIterator()
        result = iter.next()
        XCTAssertEqual(result?.key, sut.left!.key)
        XCTAssertEqual(result?.value, sut.left!.value)
        result = iter.next()
        XCTAssertEqual(result?.key, sut.key)
        XCTAssertEqual(result?.value, sut.value)
        result = iter.next()
        XCTAssertEqual(result?.key, sut.right!.key)
        XCTAssertEqual(result?.value, sut.right!.value)
        result = iter.next()
        XCTAssertNil(result)
        
        // when both children are tree, then returns
        // left elements, element, right element, nil
        sut.left!.left = givenRandomLeaf()
        sut.left!.right = givenRandomLeaf()
        sut.right!.left = givenRandomLeaf()
        sut.right!.right = givenRandomLeaf()
        var expectedResults = [(key: String, value: Int)]()
        expectedResults.append(sut.left!.left!.element)
        expectedResults.append(sut.left!.element)
        expectedResults.append(sut.left!.right!.element)
        expectedResults.append(sut.element)
        expectedResults.append(sut.right!.left!.element)
        expectedResults.append(sut.right!.element)
        expectedResults.append(sut.right!.right!.element)
        iter = sut.makeIterator()
        for expectedResult in expectedResults {
            result = iter.next()
            XCTAssertEqual(result?.key, expectedResult.key)
            XCTAssertEqual(result?.value, expectedResult.value)
        }
        XCTAssertNil(iter.next())
    }
    
    // MARK: - forEach(_:) tests
    func testForEach_whenBodyDoesntThrow() {
        let notThrowingBody: ((String, Int)) throws -> Void = { element in
            guard element.1 < 1_000_000 else {
                throw err
            }
            
            return
        }
        
        whenChildrenAreTrees()
        XCTAssertNoThrow(try sut.forEach(notThrowingBody))
    }
    
    func testForEach_whenBodyThrows() {
        whenChildrenAreTrees()
        XCTAssertThrowsError(try sut.forEach(alwaysThrowingBodyOnElement))
    }
    
    func testForEach_visitsNodesInOrder() {
        whenChildrenAreTrees()
        var expectedResult = [(key: String, value: Int)]()
        for element in sut {
            expectedResult.append(element)
        }
        
        var result = [(key: String, value: Int)]()
        sut.forEach { result.append($0) }
        
        XCTAssertEqual(
            result.map { $0.key },
            expectedResult.map { $0.key }
        )
        XCTAssertEqual(
            result.map { $0.value },
            expectedResult.map { $0.value }
        )
    }
    
    // MARK: - filter(_:) tests
    func testFilter_whenIsIncludedThrows() {
        whenChildrenAreTrees()
        let isIncluded: ((String, Int)) throws -> Bool = { _ in
            throw err
        }
        XCTAssertThrowsError(try sut.filter(isIncluded))
    }
    
    func testFilter_whenIsIncludedDoesntThrow() {
        let isIncluded: ((String, Int)) throws -> Bool = { element in
            element.1 % 2 == 0
        }
        whenChildrenAreTrees()
        var allElements = [(String, Int)]()
        sut.forEach({ allElements.append($0) })
        let expectedResult: [(String, Int)]? = try? allElements.filter(isIncluded)
        let expectedKeys = expectedResult?.map { $0.0 }
        let expectedValues = expectedResult?.map { $0.1 }
        
        XCTAssertNoThrow(try sut.filter(isIncluded))
        let result: [(String, Int)]? = try? sut.filter(isIncluded)
        let resultKeys = result?.map { $0.0 }
        let resultValues = result?.map { $0.1 }
        
        XCTAssertEqual(resultKeys, expectedKeys)
        XCTAssertEqual(resultValues, expectedValues)
    }
    
    // MARK: - map(_:) tests
    func testMap_whenTransformThrows() {
        let transform: ((String, Int)) throws -> String = { _ in
            throw err
        }
        whenChildrenAreTrees()
        XCTAssertThrowsError(try sut.map(transform))
    }
    
    func testMap_whenTransformDoesntThrow() {
        let transform: ((String, Int)) throws -> String = {
            "\($0.0) : \($0.1)"
        }
        whenChildrenAreTrees()
        var allElements = [(String, Int)]()
        sut.forEach({ allElements.append($0) })
        let expectedResult = try? allElements.map(transform)
        
        XCTAssertNoThrow(try sut.map(transform))
        let result = try? sut.map(transform)
        XCTAssertEqual(result, expectedResult)
    }
    
    // MARK: - compactMap(_:) tests
    // Since the deprecated flatMap(_:) method used compactMap(_:)
    // internally, then these tests are also to be considered
    // valid for that deprecated method
    func testCompactMap_whenTransformThrows() {
        let transform: ((String, Int)) throws -> String? = { _ in
            throw err
        }
        
        whenChildrenAreTrees()
        XCTAssertThrowsError(try sut.compactMap(transform))
    }
    
    func testCompactMap_whenTransformDoesntThrow() {
        let transform: ((String, Int)) throws -> String? = {
            guard $0.1 % 2 == 0 else { return nil }
            
            return "\($0.0) : \($0.1)"
        }
        
        whenChildrenAreTrees()
        var allElements = [(String, Int)]()
        sut.forEach({ allElements.append($0) })
        let expectedResult = try? allElements.compactMap(transform)
        
        XCTAssertNoThrow(try sut.compactMap(transform))
        let result = try? sut.compactMap(transform)
        XCTAssertEqual(result, expectedResult)
    }
    
    // MARK: - flatMap(_:) tests
    func testFlatMap_whenTransformThrows() {
        let t: ((String, Int)) throws -> String = { _ in throw err }
        
        whenChildrenAreTrees()
        XCTAssertThrowsError(try sut.flatMap(t))
    }
    
    func testFlatMap_whenTransformDoesntThrow() {
        let t: ((String, Int)) throws -> String = { element in
            "\(element.0) : \(element.1)"
        }
        whenChildrenAreTrees()
        let expectedResult: [String.Element]? = try? sut
            .map { $0 }
            .flatMap(t)
        
        XCTAssertNoThrow(try sut.flatMap(t))
        let result: [String.Element]? = try? sut.flatMap(t)
        XCTAssertEqual(result, expectedResult)
    }
    
    // MARK: - reduce(_:_:) tests
    // these tests are also testing reduce(into:_:) cause that's
    // the method used internally by reduce(_:_:)
    func testReduce_whenNextPartialResultThrows() {
        let npr: ([String], (String, Int)) throws -> [String] = { _, _ in
            throw err
        }
        whenChildrenAreTrees()
        XCTAssertThrowsError(try sut.reduce([], npr))
    }
    
    func testReduce_whenNextPartialResultDoesntThrow() {
        whenChildrenAreTrees()
        let result: [String] = sut.reduce([], {
            $0 + [$1.0]
        })
        var expectedResult = [String]()
        sut.forEach { expectedResult.append($0.0) }
        XCTAssertEqual(result, expectedResult)
    }
    
    // MARK: - first(where:) tests
    func testFirstWhere_whenPredicateDoesntThrow() {
        whenChildrenAreTrees()
        let sutKey = sut.key
        let sutValue = sut.value
        let keyInLeftSubtree = sut.left!.right!.key
        let valueInLeftSubtree = sut.left!.right!.value
        let keyInRightSubTree = sut.right!.left!.key
        let valueInRightSubTree = sut.right!.left!.value
        
        // predicates returns false for whole left subtree
        // but returns true for node element,
        // then returns node element:
        var predicate: ((String, Int)) throws -> Bool = { element in
            element.1 == sutValue
        }
        XCTAssertNoThrow(try sut.first(where: predicate))
        var result = try? sut.first(where: predicate)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.0, sutKey)
        XCTAssertEqual(result?.1, sutValue)
        
        // predicate returns true for element in left subtree,
        // then returns element in left subtree
        predicate = { element in element.1 == valueInLeftSubtree }
        XCTAssertNoThrow(try sut.first(where: predicate))
        result = try? sut.first(where: predicate)
        XCTAssertEqual(result?.0, keyInLeftSubtree)
        XCTAssertEqual(result?.1, valueInLeftSubtree)
        
        // predicate returns false for left subtree and node but
        // true for element in right subtree,
        // then returns element in right subtree
        predicate = { element in element.1 == valueInRightSubTree }
        XCTAssertNoThrow(try sut.first(where: predicate))
        result = try? sut.first(where: predicate)
        XCTAssertEqual(result?.0, keyInRightSubTree)
        XCTAssertEqual(result?.1, valueInRightSubTree)
        
        // predicate returns false for whole left subtree and
        // node and whole right subtree, then returns nil
        predicate = { element in element.1 > 1_000_000 }
        XCTAssertNoThrow(try sut.first(where: predicate))
        result = try? sut.first(where: predicate)
        XCTAssertNil(result)
    }
    
    func testFirstWhere_returnsFirstElementWherePredicateIsTrue() {
        whenChildrenAreTrees()
        sut.value = 1_000_000
        sut.left!.right!.value = 1_000_000
        sut.right!.left!.value = 1_000_000
        let result = sut.first(where: { $0.1 >= 1_000_000 })
        XCTAssertEqual(result?.0, sut.left!.right!.key)
    }
    
    func testFirstWhere_whenPredicateThrows() {
        let throwingPredicate: ((String, Int)) throws -> Bool = { _ in
            throw err
        }
        whenChildrenAreTreesAndIsBST()
        XCTAssertThrowsError(try sut.first(where: throwingPredicate))
    }
    
    // MARK: - contains(where:) tests
    func testContainsWhere_whenPredicateThrows() {
        let predicate: ((String, Int)) throws -> Bool = { element in
            guard element.1 < 1_000_000 else { throw err }
            
            return element.0 == "!"
        }
        whenChildrenAreTrees()
        sut.value = 1_000_000
        XCTAssertThrowsError(try sut.contains(where: predicate))
    }
    
    func testContainsWhere_whenPredicateDoesntThrow() {
        let predicate: ((String, Int)) -> Bool = { element in
            element.1 >= 1_000_000
        }
        whenChildrenAreTrees()
        
        // when predicate returns false for every element,
        // then returns false
        XCTAssertFalse(sut.contains(where: predicate))
        
        // when predicate returns true for one element
        // in left subtree, then returns true
        sut.left!.right!.value = 1_000_000
        XCTAssertTrue(sut.left!.contains(where: predicate))
        XCTAssertTrue(sut.contains(where: predicate))
        
        // when predicate returns false for elements
        // in left subtree but returns true for node element,
        // then returns true
        sut.left!.right!.value = randomValue()
        sut.value = 1_000_000
        XCTAssertFalse(sut.left!.contains(where: predicate))
        XCTAssertTrue(predicate((sut.key, sut.value)))
        XCTAssertTrue(sut.contains(where: predicate))
        
        // when predicate returns false for elements in left
        // subtree and node's element but returns true for
        // an element in right subtree, then returns true
        sut.value = randomValue()
        sut.right!.left!.value = 1_000_000
        XCTAssertFalse(sut.left!.contains(where: predicate))
        XCTAssertFalse(predicate((sut.key, sut.value)))
        XCTAssertTrue(sut.contains(where: predicate))
    }
    
    // MARK: - allSatisfy(_:) tests
    func testAllSatisfy_whenPredicateThrows() {
        let predicate: ((String, Int)) throws -> Bool = { _ in
            throw err
        }
        
        whenChildrenAreTrees()
        XCTAssertThrowsError(try sut.allSatisfy(predicate))
    }
    
    func testAllSatisfy_whenPredicateDoesntThrow() {
        let predicate: ((String, Int)) throws -> Bool = { element in
            element.1 < 1_000_000
        }
        
        whenChildrenAreTrees()
        XCTAssertNoThrow(try sut.allSatisfy(predicate))
        // when every element returns true,
        // then returns true
        XCTAssertTrue(try! sut.allSatisfy(predicate))
        
        // when an element in left subtree returns false,
        // then returns false
        sut.left!.right!.value = 1_000_000
        XCTAssertFalse(try! sut.left!.allSatisfy(predicate))
        XCTAssertFalse(try! sut.allSatisfy(predicate))
        
        // when every element is left subtree returns true but
        // node element returns false, then returns false
        sut.left!.right!.value = randomValue()
        sut.value = 1_000_000
        XCTAssertTrue(try! sut.left!.allSatisfy(predicate))
        XCTAssertFalse(try! predicate((sut.key, sut.value)))
        XCTAssertFalse(try! sut.allSatisfy(predicate))
        
        // when every element is left subtree returns true and
        // node element returns true and returns false for
        // right subtree, then returns false
        sut.value = randomValue()
        sut.right!.left!.value = 1_000_000
        XCTAssertTrue(try! sut.left!.allSatisfy(predicate))
        XCTAssertTrue(try! predicate((sut.key, sut.value)))
        XCTAssertFalse(try! sut.right!.allSatisfy(predicate))
        XCTAssertFalse(try! sut.allSatisfy(predicate))
    }
    
    // MARK: - reversed() tests
    func testReversed() {
        whenChildrenAreTrees()
        let expectedResult = sut!
            .map { $0 }
            .reversed()
        let expectedKeys = expectedResult.map { $0.0 }
        let expectedValues = expectedResult.map { $0.1 }
        
        let result = sut.reversed()
        let resultKeys = result.map { $0.0 }
        let resultValues = result.map { $0.1 }
        XCTAssertEqual(resultKeys, expectedKeys)
        XCTAssertEqual(resultValues, expectedValues)
    }
    
    // MARK: - Tree traversal tests
    // MARK: - inOrderTraverse(_:) tests
    func testInOrderTraverse_whenBodyThrows_thenThrows() {
        XCTAssertThrowsError(try sut.inOrderTraverse(alwaysThrowingBodyOnNode))
    }
    
    func testInOrderTraverse_whenBodyDoesntThrow_thenDoesntThrow() {
        XCTAssertNoThrow(try sut.inOrderTraverse(neverThrowingBodyOnNode))
    }
    
    func testInOrderTraverse_visitsTreeNodesInOrder() {
        whenChildrenAreTrees()
        let expectedResult = [
            sut.left!.left!.element,
            sut.left!.element,
            sut.left!.right!.element,
            sut.element,
            sut.right!.left!.element,
            sut.right!.element,
            sut.right!.right!.element

        ]
        
        var result: [(key: String, value: Int)] = []
        sut.inOrderTraverse { result.append($0.element) }
        XCTAssertEqual(result.map { $0.key }, expectedResult.map {$0.0} )
        XCTAssertEqual(result.map { $0.value }, expectedResult.map { $0.1 } )
    }
    
    // MARK: - reverseInOrderTraverse(_:) tests
    func testReverseInOrderTraverse_whenBodyThrows_thenThrows() {
        XCTAssertThrowsError(try sut.reverseInOrderTraverse(alwaysThrowingBodyOnNode))
    }
    
    func testReverseInOrderTraverse_whenBodyDoesntThrow_thenDoesntThrow() {
        XCTAssertNoThrow(try sut.reverseInOrderTraverse(neverThrowingBodyOnNode))
    }
    
    func testReverseInOrderTraverse_visitsNodeInReverse() {
        whenChildrenAreTrees()
        let expectedResult = [
            sut.left!.left!.element,
            sut.left!.element,
            sut.left!.right!.element,
            sut.element,
            sut.right!.left!.element,
            sut.right!.element,
            sut.right!.right!.element

        ].reversed()
        
        var result: [(key: String, value: Int)] = []
        sut.reverseInOrderTraverse {
            result.append($0.element)
        }
        XCTAssertEqual(result.map { $0.key }, expectedResult.map {$0.0} )
        XCTAssertEqual(result.map { $0.value }, expectedResult.map { $0.1 } )
    }
    
    // MARK: - preOrderTraverse(_:) tests
    func testPreOrderTraverse_whenBodyThrows_thenThrows() {
        XCTAssertThrowsError(try sut.preOrderTraverse(alwaysThrowingBodyOnNode))
    }
    
    func testPreOrderTraverse_whenBodyDoesntThrow_thenDoesntThrow() {
        XCTAssertNoThrow(try sut.preOrderTraverse(neverThrowingBodyOnNode))
    }
    
    func testPreOrderTraverse_visitsNodeInPreOrder() {
        whenChildrenAreTrees()
        let expectedResult = [
            sut.element,
            sut.left!.element,
            sut.left!.left!.element,
            sut.left!.right!.element,
            sut.right!.element,
            sut.right!.left!.element,
            sut.right!.right!.element
        ]
        var result: [(key: String, value: Int)] = []
        sut.preOrderTraverse {
            result.append($0.element)
        }
        XCTAssertEqual(result.map { $0.key }, expectedResult.map {$0.0} )
        XCTAssertEqual(result.map { $0.value }, expectedResult.map { $0.1 } )
    }
    
    // MARK: - postOrderTraverse(_:) tests
    func testPostOrderTraverse_whenBodyThrows_thenThrows() {
        XCTAssertThrowsError(try sut.postOrderTraverse(alwaysThrowingBodyOnNode))
    }
    
    func testPostOrderTraverse_whenBodyDoesntThrow_thenDoesntThrow() {
        XCTAssertNoThrow(try sut.postOrderTraverse(neverThrowingBodyOnNode))
    }
    
    func testPostOrderTraverse_visitsNodeInPostOrder() {
        whenChildrenAreTrees()
        let expectedResult = [
            sut.left!.left!.element,
            sut.left!.right!.element,
            sut.left!.element,
            sut.right!.left!.element,
            sut.right!.right!.element,
            sut.right!.element,
            sut.element,
        ]
        var result: [(key: String, value: Int)] = []
        sut.postOrderTraverse {
            result.append($0.element)
        }
        XCTAssertEqual(result.map { $0.key }, expectedResult.map {$0.0} )
        XCTAssertEqual(result.map { $0.value }, expectedResult.map { $0.1 } )
    }
    
    // MARK: - levelOrderTraverse(_:) tests
    func testLevelOrderTraverse_whenBodyThrows_thenThrows() {
        XCTAssertThrowsError(try sut.levelOrderTraverse(alwaysThrowingBodyOnNode))
    }
    
    func testLevelOrderTraverse_whenBodyDoesntThrow_thenDoesntThrow() {
        XCTAssertNoThrow(try sut.levelOrderTraverse(neverThrowingBodyOnNode))
    }
    
    func testLevelOrderTraverse_visitsNodeInLevelOrder() {
        whenChildrenAreTrees()
        let expectedResult = [
            sut.element,
            sut.left!.element,
            sut.right!.element,
            sut.left!.left!.element,
            sut.left!.right!.element,
            sut.right!.left!.element,
            sut.right!.right!.element,
        ]
        var result: [(key: String, value: Int)] = []
        sut.levelOrderTraverse {
            result.append($0.element)
        }
        XCTAssertEqual(result.map { $0.key }, expectedResult.map {$0.0} )
        XCTAssertEqual(result.map { $0.value }, expectedResult.map { $0.1 } )
    }
    
    // MARK: - paths tests
    func test_paths() {
        whenChildrenAreTrees()
        let expectedResult = [
            [sut!, sut.left!, sut.left!.left!],
            [sut!, sut.left!, sut.left!.right!],
            [sut!, sut.right!, sut.right!.left!],
            [sut!, sut.right!, sut.right!.right!]
        ]
        
        let result = sut.paths
        XCTAssertEqual(result.count, expectedResult.count)
        for (sutPath, expectedPath) in zip(result, expectedResult) {
            XCTAssertEqual(sutPath.count, expectedPath.count)
            for (sutNode, expectedNode) in zip(sutPath, expectedPath) {
                XCTAssertTrue(sutNode === expectedNode, "sutPath: \(sutPath) is different from expected one: \(expectedPath)")
            }
        }
    }
    
    // MARK: - Binary Tree utilities tests
    func testIsBinarySearchTree_whenIsLeaf_returnsTrue() {
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
        XCTAssertTrue(sut.isBinarySearchTree)
    }
    
    func testIsBinarySearchTree_whenEitherOrBothChildrenAreLeaf() {
        let smallerKeyNode = TestNode(key: givenSmallerKeysThanSutKey().randomElement()!, value: randomValue())
        let largerKeyNode = TestNode(key: givenLargerKeysThanSutKey().randomElement()!, value: randomValue())
        
        // when left is leaf, right is nil:
        sut.left = smallerKeyNode
        XCTAssertLessThan(sut.left!.key, sut.key)
        XCTAssertTrue(sut.isBinarySearchTree)
        sut.left = largerKeyNode
        XCTAssertGreaterThanOrEqual(sut.left!.key, sut.key)
        XCTAssertFalse(sut.isBinarySearchTree)
        
        // when left is nil, right is leaf:
        sut.left = nil
        sut.right = largerKeyNode
        XCTAssertGreaterThan(sut.right!.key, sut.key)
        XCTAssertTrue(sut.isBinarySearchTree)
        sut.right = smallerKeyNode
        XCTAssertLessThanOrEqual(sut.right!.key, sut.key)
        XCTAssertFalse(sut.isBinarySearchTree)
        
        // when both left and right are leaf:
        sut.right = largerKeyNode
        sut.left = smallerKeyNode
        XCTAssertLessThan(sut.left!.key, sut.key)
        XCTAssertGreaterThan(sut.right!.key, sut.key)
        XCTAssertTrue(sut.isBinarySearchTree)
        sut.right = smallerKeyNode
        sut.left = largerKeyNode
        XCTAssertGreaterThanOrEqual(sut.left!.key, sut.key)
        XCTAssertLessThanOrEqual(sut.right!.key, sut.key)
    }
    
    func testIsBinarySearchTree_whenChildrenAreTrees() {
        whenChildrenAreTreesAndIsBST()
        XCTAssertTrue(sut.left!.isBinarySearchTree)
        XCTAssertTrue(sut.right!.isBinarySearchTree)
        XCTAssertLessThan(sut.left!.key, sut.key)
        XCTAssertGreaterThan(sut.right!.key, sut.key)
        XCTAssertTrue(sut.isBinarySearchTree)
        
        let l = sut.left!
        let r = sut.right!
        
        var tmp = l.left!.key
        l.left!.key = l.right!.key
        l.right!.key = tmp
        XCTAssertFalse(sut.left!.isBinarySearchTree)
        XCTAssertFalse(sut.isBinarySearchTree)
        
        tmp = l.left!.key
        l.left!.key =  l.right!.key
        l.right!.key = tmp
        XCTAssertTrue(sut.left!.isBinarySearchTree)
        tmp = r.left!.key
        r.left!.key = r.right!.key
        r.right!.key = tmp
        XCTAssertFalse(sut.right!.isBinarySearchTree)
        XCTAssertFalse(sut.isBinarySearchTree)
    }
    
    // MARK: - binarySearch(_:) tests
    func testBinarySearch_whenLeftAndRightAreNil() {
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
        let sutKey = sut.key
        let notContainedKeys = givenKeys.filter { $0 != sutKey }
        
        // and needle is equal to node.key, then returns node:
        let result = sut.binarySearch(sutKey)
        XCTAssertNotNil(result)
        XCTAssertTrue(result === sut)
        
        // when needle is not equal to node.key, then returns nil
        for needle in notContainedKeys {
            XCTAssertNil(sut.binarySearch(needle))
        }
    }
    
    func testBinarySearch_whenEitherOrBothChildrenAreLeavesAndIsBinaryTreeIsTrue() {
        let smallerKey = givenSmallerKeysThanSutKey().randomElement()!
        let largerKey = givenLargerKeysThanSutKey().randomElement()!
        let smallerChild = TestNode(key: smallerKey, value: randomValue())
        let largerChild = TestNode(key: largerKey, value: randomValue())
        
        // left is leaf, right is nil:
        sut.left = smallerChild
        XCTAssertTrue(sut.isBinarySearchTree)
        // needle is smaller than node.key and equal to left.key,
        // then returns left
        var result = sut.binarySearch(smallerKey)
        XCTAssertNotNil(result)
        XCTAssertTrue(result === sut.left, "returned a different node than left node")
        
        // needle is smaller than node.key, and not equal to left.key,
        // then returns nil
        for needle in givenSmallerKeysThanSutKey() where needle != sut.left!.key {
            XCTAssertNil(sut.binarySearch(needle))
        }
        
        // needle is larger than node.key, returns nil
        for needle in givenLargerKeysThanSutKey() {
            XCTAssertNil(sut.binarySearch(needle))
        }
        
        // left is nil, right is leaf:
        sut.left = nil
        sut.right = largerChild
        // needle is larger than node.key and equal to right.key,
        // then returns node.right
        result = sut.binarySearch(largerKey)
        XCTAssertNotNil(result)
        XCTAssertTrue(result === sut.right, "returned a different node than right node")
        
        // needle is larger than node.key, and is not equal to
        // right.key, then returns nil
        for needle in givenLargerKeysThanSutKey() where needle != sut.right!.key {
            XCTAssertNil(sut.binarySearch(needle))
        }
        
        // right is leaf, left is leaf
        sut.right = largerChild
        sut.left = smallerChild
        XCTAssertTrue(sut.isBinarySearchTree)
        
        // when needle is less than node.key and equal to left.key,
        // then returns left
        result = sut.binarySearch(sut.left!.key)
        XCTAssertNotNil(result)
        XCTAssertTrue(result === sut.left)
        // when needle is less than node.key and is not equal to
        // node.left, then returns nil
        for needle in givenSmallerKeysThanSutKey() where needle != sut.left!.key {
            XCTAssertNil(sut.binarySearch(needle))
        }
        
        // when needle is equal to node.key, returns node:
        result = sut.binarySearch(sut.key)
        XCTAssertNotNil(result)
        XCTAssertTrue(result === sut, "returned a different node than root")
        
        // when needle is greater than node.key and equals to right.key,
        // then returns right
        result = sut.binarySearch(sut.right!.key)
        XCTAssertNotNil(result)
        XCTAssertTrue(result === sut.right, "returned a different node than right node")
        // when key is larger than node.key and is not equal to
        // right.key, then returns nil
        // needle is larger than node.key, and is not equal to
        // right.key, then returns nil
        for needle in givenLargerKeysThanSutKey() where needle != sut.right!.key {
            XCTAssertNil(sut.binarySearch(needle))
        }
    }
    
    func testBinarySearch_whenBothChildrenAreTreesAndIsBinarySearchTreeIsTrue() {
        whenChildrenAreTreesAndIsBST()
        XCTAssertTrue(sut.isBinarySearchTree)
        
        // when needle is equal to node.key, then returns node:
        var result = sut.binarySearch(sut.key)
        XCTAssertNotNil(result)
        XCTAssertTrue(result === sut, "returned a different node than root")
        
        // when needle is less than node.key and is contained in left
        // tree, than returns node from left tree:
        let keysInLeftTree = givenSmallerKeysThanSutKey().prefix(3)
        for needle in keysInLeftTree {
            result = sut.binarySearch(needle)
            XCTAssertNotNil(result)
            XCTAssertTrue(result === sut.left!.binarySearch(needle), "needle was not found in left tree")
        }
        // when needle is less than node.key and is not contained
        // in left tree, then returns nil
        for needle in givenSmallerKeysThanSutKey() where keysInLeftTree.contains(needle) == false {
            XCTAssertNil(sut.binarySearch(needle))
        }
        
        // when needle is greater than node.key and is contained in
        // right tree, then returns node from right tree:
        let keysInRightTree = givenLargerKeysThanSutKey().prefix(3)
        for needle in keysInRightTree {
            result = sut.binarySearch(needle)
            XCTAssertNotNil(result)
            XCTAssertTrue(result === sut.right!.binarySearch(needle))
        }
        // when needle is greater than node.key, and is not contained
        // in right tree, then returns nil
        for needle in givenLargerKeysThanSutKey() where keysInRightTree.contains(needle) == false {
            XCTAssertNil(sut.binarySearch(needle))
        }
    }
    
    func testBinarySearch_whenEitherChildrenIsTreeOtherIsNilAndIsBinarySearchTreeIsTrue() {
        whenChildrenAreTreesAndIsBST()
        let leftTree = sut.left!
        let rightTree = sut.right!
        
        // left is nil, right is tree
        sut.left = nil
        XCTAssertTrue(sut.isBinarySearchTree)
        
        // when needle is node.key, then returns node
        var result = sut.binarySearch(sut.key)
        XCTAssertTrue(result === result, "needle was not found in root node")
        // when needle is less than sut.key, then returns nil
        for needle in givenSmallerKeysThanSutKey() {
            XCTAssertNil(sut.binarySearch(needle))
        }
        // when needle is greater thannode.key and is in right tree,
        // then returns node from right tree:
        let rightTreeKeys = rightTree.map { $0.0 }
        for needle in rightTreeKeys {
            result = sut.binarySearch(needle)
            XCTAssertNotNil(result)
            XCTAssertTrue(result === sut.right!.binarySearch(needle), "needle was not found in right tree")
        }
        // when needle is greater than node.key and is not in right
        // tree, then returns nil
        for needle in givenLargerKeysThanSutKey() where rightTreeKeys.contains(needle) == false {
            XCTAssertNil(sut.binarySearch(needle))
        }
        
        // left is tree, right is nil
        sut.left = leftTree
        sut.right = nil
        XCTAssertTrue(sut.isBinarySearchTree)
        // when needle is node.key, then returns node
        result = sut.binarySearch(sut.key)
        XCTAssertTrue(result === result, "needle was not found in root node")
        // when needle is greater than node.key, then returns nil
        for needle in givenLargerKeysThanSutKey() {
            XCTAssertNil(sut.binarySearch(needle))
        }
        // when key is less than node.key and is contained in
        // left tree, then returns node from left tree
        let leftTreeKeys = leftTree.map { $0.0 }
        for needle in leftTreeKeys {
            result = sut.binarySearch(needle)
            XCTAssertNotNil(result)
            XCTAssertTrue(result === sut.left!.binarySearch(needle), "needle was not found in left tree")
        }
        // when key is less than node.key and key is not in left tree,
        // then returns nil
        for needle in givenSmallerKeysThanSutKey() where leftTreeKeys.contains(needle) == false {
            XCTAssertNil(sut.binarySearch(needle))
        }
    }
    
    // MARK: - sequentialSearch(_:) tests
    func testSequentialSearch_whenBothChildrenAreNil() {
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
        
        // when needle != key, then returns nil
        for needle in givenKeys where needle != sut.key {
            XCTAssertNil(sut.sequentialSearch(needle))
        }
        
        // when needle == key, then returns self
        XCTAssertTrue(sut.sequentialSearch(sut.key) === sut, "has returned different instance than self")
    }
    
    func testSequentialSearch_whenEitherOrBothChildrenAreLeaves() {
        let leftLeaf = givenRandomLeaf()
        let rightLeaf = givenRandomLeaf()
        
        // left is leaf, right is nil
        sut.left = leftLeaf
        XCTAssertNil(sut.right)
        
        // when needle is key, then returns self
        XCTAssertTrue(sut.sequentialSearch(sut.key) === sut, "has returned different instance than self")
        // when needle is not key and not left key, then
        // returns nil:
        for needle in givenKeys where (needle != sut.key && needle != leftLeaf.key) {
            XCTAssertNil(sut.sequentialSearch(needle))
        }
        // when needle is not equal to key and
        // needle is equal to left.key, then returns left
        if let needle = givenKeys
            .first(where: { ($0 != sut.key && $0 == leftLeaf.key) })
        {
            XCTAssertTrue(sut.sequentialSearch(needle) === leftLeaf, "did not return left leaf")
        }
        
        // left is nil, right is leaf
        sut.left = nil
        sut.right = rightLeaf
        
        // when needle is key, then returns self
        XCTAssertTrue(sut.sequentialSearch(sut.key) === sut, "has returned different instance than self")
        // when needle is not key and not right key, then
        // returns nil:
        for needle in givenKeys where (needle != sut.key && needle != rightLeaf.key) {
            XCTAssertNil(sut.sequentialSearch(needle))
        }
        // when needle is not equal to key and
        // needle is equal to right.key, then returns right
        if let needle = givenKeys
            .first(where: { ($0 != sut.key && $0 == rightLeaf.key) })
        {
            XCTAssertTrue(sut.sequentialSearch(needle) === rightLeaf, "did not return right leaf")
        }
        
        // both children are leaves
        sut.left = leftLeaf
        // when needle is key, then returns self
        XCTAssertTrue(sut.sequentialSearch(sut.key) === sut, "has returned different instance than self")
        // when needle is not key and not left.key
        // or right.key, then returns nil
        // returns nil:
        for needle in givenKeys where (needle != sut.key && needle != rightLeaf.key && needle != leftLeaf.key) {
            XCTAssertNil(sut.sequentialSearch(needle))
        }
        // when needle is not equal to key and
        // needle is equal to left.key, then returns left
        if let needle = givenKeys
            .first(where: { ($0 != sut.key && $0 == leftLeaf.key && $0 != rightLeaf.key) })
        {
            XCTAssertTrue(sut.sequentialSearch(needle) === leftLeaf, "did not return left leaf")
        }
        // when needle is not equal to key and is not equal
        // to left.key and needle is equal to right.key,
        // then returns right
        if let needle = givenKeys
            .first(where: { ($0 != sut.key && $0 != leftLeaf.key && $0 == rightLeaf.key) })
        {
            XCTAssertTrue(sut.sequentialSearch(needle) === rightLeaf, "did not return right leaf")
        }
    }
    
    func testSequentialSearch_whenChildrenAreTrees() {
        whenChildrenAreTrees()
        
        // when needle == key, then returns node
        XCTAssertTrue(sut.binarySearch(sut.key) === sut, "has returned a different instance than sut")
        // when needle is not node key, and both left and right
        // returns nil for sequentialSearch, then returns nil
        for needle in givenKeys
            .filter({ $0 != sut.key && sut.left?.sequentialSearch($0) == nil && sut.right?.sequentialSearch($0) == nil })
        {
            XCTAssertNil(sut.sequentialSearch(needle))
        }
        
        // when needle is not node key, and sequentialSearch
        // on left tree returns a node, then returns that node
        for needle in givenKeys
            .filter({ $0 != sut.key && sut.left?.sequentialSearch($0) != nil })
        {
            XCTAssertTrue(sut.sequentialSearch(needle) === sut.left?.sequentialSearch(needle))
        }
        
        // when needle is not node key, and sequentialSearch
        // on left tree returns nil and sequentialSearch
        // on right tree returns a node,
        // then returns that node
        for needle in givenKeys
            .filter({ $0 != sut.key && sut.left?.sequentialSearch($0) == nil && sut.right?.sequentialSearch($0) != nil })
        {
            XCTAssertTrue(sut.sequentialSearch(needle) === sut.right?.sequentialSearch(needle))
        }
    }
    
}

// MARK: - TestNode
final class TestNode<Key, Value>: BinaryNode {
    typealias Element = (Key, Value)
    
    var key: Key
    
    var value: Value
    
    var left: TestNode? = nil
    
    var right: TestNode? = nil
    
    init(key: Key, value: Value) {
        self.key = key
        self.value = value
    }
    
}
