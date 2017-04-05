//
//  Property.swift
//  SwiftCodeGenerator
//
//  Created by Scott Lessans on 4/5/17.
//  Copyright © 2016 Scott Lessans. All rights reserved.
//

import Foundation

private let propertyPattern = try! NSRegularExpression(pattern: "^\\s*(?:let|var)\\s+([a-zA-Z0-9_]+)\\s*:\\s*(.+)$", options: [.caseInsensitive])

private extension String {
    func substring(with range: NSRange) -> String {
        let start = self.index(self.startIndex, offsetBy: range.location)
        let end = self.index(start, offsetBy: range.length)
        return self[start..<end]
    }
}

struct Property {
    var name: String
    var typeName: String
    
    var initializerParamExpression: String {
        return "\(self.name): \(self.typeName)"
    }
    
    var constructorAssignmentExpression: String {
        return "self.\(self.name) = \(self.name)"
    }
}

extension Input {
    func parseProperties() throws -> [Property] {
        return try self.lines().flatMap({ line in
            var trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let match = propertyPattern.firstMatch(in: trimmed, options: [], range: NSRange(location: 0, length: trimmed.characters.count)) else {
                return nil
            }
            let varName = trimmed.substring(with: match.rangeAt(1))
            let varType = trimmed.substring(with: match.rangeAt(2))
            return Property(name: varName, typeName: varType)
        })
    }
}
