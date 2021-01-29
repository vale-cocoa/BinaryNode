//
//  File.swift
//  
//
//  Created by Valeriano Della Longa on 28/01/21.
//

import XCTest
@testable import BinaryNode

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
