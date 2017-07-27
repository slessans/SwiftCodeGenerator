//
//  Property.swift
//  SwiftCodeGenerator
//
//  Created by Scott Lessans on 4/5/17.
//  Copyright © 2016 Scott Lessans. All rights reserved.
//

import Foundation

private let propertyPattern = try! NSRegularExpression(pattern: "^.*?(?:let|var)\\s+([a-zA-Z0-9_]+)\\s*:\\s*(.+)$", options: [.caseInsensitive])
private let casePattern = try! NSRegularExpression(pattern: "^(?:case)\\s+([a-zA-Z0-9_]+)(\\([^)]+\\))?$", options: [.caseInsensitive])

private extension String {
    func substring(with range: NSRange) -> String? {
        if range.location == NSNotFound {
            return nil
        }
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

struct EnumCase {
    var name: String
    var hasAssociatedData: Bool
}

extension Input {
    func parseEnumCases() throws -> [EnumCase] {
        return try self.lines().flatMap({ line in
            var trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)            
            guard let match = casePattern.firstMatch(in: trimmed, options: [], range: NSRange(location: 0, length: trimmed.characters.count)) else {
                return nil
            }
            precondition(match.numberOfRanges == 3)
            let name = trimmed.substring(with: match.rangeAt(1))!
            let hasAssociatedData = match.rangeAt(2).location != NSNotFound
            return EnumCase(name: name, hasAssociatedData: hasAssociatedData)
        })
    }
    func parseProperties() throws -> [Property] {
        return try self.lines().flatMap({ line in
            var trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let match = propertyPattern.firstMatch(in: trimmed, options: [], range: NSRange(location: 0, length: trimmed.characters.count)) else {
                return nil
            }
            let varName = trimmed.substring(with: match.rangeAt(1))!
            let varType = trimmed.substring(with: match.rangeAt(2))!
            return Property(name: varName, typeName: varType)
        })
    }
}
