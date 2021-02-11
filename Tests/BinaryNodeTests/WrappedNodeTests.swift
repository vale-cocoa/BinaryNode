//
//  WrappedNodeTests.swift
//  BinaryNodeTests
//
//  Created by Valeriano Della Longa on 2021/02/11.
//  Copyright © 2021 Valeriano Della Longa
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

final class WrappedNodeTests: XCTestCase {
    var sut: (node: TestNode<String, Int>, wrapped: WrappedNode<TestNode<String, Int>>)!
    
    override func setUp() {
        super.setUp()
        
        let node = TestNode(key: givenKeys.randomElement()!, value: randomValue())
        let wrapped = WrappedNode(node: node)
        sut = (node, wrapped)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func testInit() {
        let node = TestNode(key: givenKeys.randomElement()!, value: randomValue())
        let wrapped = WrappedNode(node: node)
        XCTAssertNotNil(wrapped)
        XCTAssertNotNil(wrapped.node)
    }
    
    func testNode() {
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.node === sut.wrapped.node, "wrapped's node is not the same instance of node")
    }
    
    func testWrappedLeft() {
        // when node.left is nil, then returns nil
        XCTAssertNil(sut.node.left)
        XCTAssertNil(sut.wrapped.wrappedLeft)
        
        // when node.left is not nil, then returns a WrappedNode
        // wrapping node.left
        sut.node.left = TestNode(key: givenKeys.randomElement()!, value: randomValue())
        XCTAssertNotNil(sut.wrapped.wrappedLeft)
        XCTAssertTrue(sut.node.left === sut.wrapped.wrappedLeft?.node)
    }
    
    func testWrappedRight() {
        // when node.right is nil, then returns nil
        XCTAssertNil(sut.node.right)
        XCTAssertNil(sut.wrapped.wrappedRight)
        
        // when node.right is not nil, then returns a WrappedNode
        // wrapping node.right
        sut.node.right = TestNode(key: givenKeys.randomElement()!, value: randomValue())
        XCTAssertNotNil(sut.wrapped.wrappedRight)
        XCTAssertTrue(sut.node.right === sut.wrapped.wrappedRight?.node)
    }
}
