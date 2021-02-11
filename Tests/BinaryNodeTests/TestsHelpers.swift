//
//  TestHelpers.swift
//  BinaryNodeTests
//
//  Created by Valeriano Della Longa on 2021/01/28.
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

// MARK: - Common helpers for tests
let err = NSError(domain: "com.vdl.error", code: 1, userInfo: nil)

func randomValue() -> Int {
    Int.random(in: 1...301)
}

let givenKeys = "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
    .components(separatedBy: " ")

let alwaysThrowingBodyOnNode: (TestNode<String, Int>) throws -> Void = { _ in
    throw err
}

let alwaysThrowingBodyOnElement: ((String, Int)) throws -> Void = { _ in
    throw err
}

let neverThrowingBodyOnNode: (TestNode<String, Int>) throws -> Void = { _ in }
