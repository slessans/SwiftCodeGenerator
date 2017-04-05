//
//  Input.swift
//  SwiftCodeGenerator
//
//  Created by Scott Lessans on 4/5/17.
//  Copyright © 2016 Scott Lessans. All rights reserved.
//

import Foundation
import AppKit

enum Input {
    case file(path: String)
    case pasteboard
}

extension Input {
    func lines() throws -> AnySequence<String> {
        switch self {
        case let .file(path: path):
            guard let reader = FileLineReader(path: path) else {
                throw NSError(domain: "com.sl", code: -1, userInfo: [NSLocalizedFailureReasonErrorKey: "Couldnt create reader"])
            }
            return AnySequence(reader)
        case .pasteboard:
            guard let contents = NSPasteboard.general().string(forType: NSPasteboardTypeString) else {
                throw NSError(domain: "com.sl", code: -1, userInfo: [NSLocalizedFailureReasonErrorKey: "Nothing in pasteboard"])
            }
            return AnySequence(contents.characters.split(separator: "\n").map(String.init))
        }
    }
}
