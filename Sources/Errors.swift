//
//  Errors.swift
//  SwiftCodeGenerator
//
//  Created by Scott Lessans on 4/5/17.
//
//

import Foundation

enum SwiftCodeGeneratorError: Error {
    case couldNotParseInput(underlying: Error)
    case unknownExecutionError(underlying: Error)
}

extension SwiftCodeGeneratorError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .couldNotParseInput(underlying):
            return "Could not parse the properties of the input: \(underlying)"
        case let .unknownExecutionError(underlying):
            return "An unknown error occurred during execution of the program: \(underlying)"
        }
    }
}

