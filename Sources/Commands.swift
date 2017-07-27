//
//  Commands.swift
//  SwiftCodeGenerator
//
//  Created by Scott Lessans on 4/5/17.
//  Copyright © 2016 Scott Lessans. All rights reserved.
//

import Foundation
import Commandant
import AppKit
import Result

struct GeneratorOptions: OptionsProtocol {
    var file: String
    
    var input: Input {
        if self.file == "" {
            return .pasteboard
        }
        return .file(path: self.file)
    }
    
    static func create(_ file: String) -> GeneratorOptions {
        return GeneratorOptions(file: file)
    }
    
    static func evaluate(_ m: CommandMode) -> Result<GeneratorOptions, CommandantError<SwiftCodeGeneratorError>> {
        return create
            <*> m <| Argument(defaultValue: "", usage: "the file to parse or nothing to use clipboard")
    }
    
    func run(_ fnc: ([Property]) throws -> String) -> Result<(), SwiftCodeGeneratorError> {
        let properties: [Property]
        do {
            properties = try self.input.parseProperties()
        } catch {
            return .failure(SwiftCodeGeneratorError.couldNotParseInput(underlying: error))
        }
        do {
            print(try fnc(properties))
            return .success()
        } catch {
            if let e = error as? SwiftCodeGeneratorError {
                return .failure(e)
            }
            return .failure(SwiftCodeGeneratorError.unknownExecutionError(underlying: error))
        }
    }
}

struct EnumOptions: OptionsProtocol {
    var file: String
    
    var input: Input {
        if self.file == "" {
            return .pasteboard
        }
        return .file(path: self.file)
    }
    
    static func create(_ file: String) -> EnumOptions {
        return EnumOptions(file: file)
    }
    
    static func evaluate(_ m: CommandMode) -> Result<EnumOptions, CommandantError<SwiftCodeGeneratorError>> {
        return create
            <*> m <| Argument(defaultValue: "", usage: "the file to parse or nothing to use clipboard")
    }
    
    func run(_ fnc: ([EnumCase]) throws -> String) -> Result<(), SwiftCodeGeneratorError> {
        let properties: [EnumCase]
        do {
            properties = try self.input.parseEnumCases()
        } catch {
            return .failure(SwiftCodeGeneratorError.couldNotParseInput(underlying: error))
        }
        do {
            print(try fnc(properties))
            return .success()
        } catch {
            if let e = error as? SwiftCodeGeneratorError {
                return .failure(e)
            }
            return .failure(SwiftCodeGeneratorError.unknownExecutionError(underlying: error))
        }
    }
}

struct EnumEqualityCommand: CommandProtocol {
    var verb: String {
        return "enum-equal"
    }
    
    var function: String {
        return "generate equality code for enum"
    }
    
    func run(_ options: EnumOptions) -> Result<(), SwiftCodeGeneratorError> {
        return options.run { properties in
            var output = "public static func ==(lhs: Self, rhs: Self) -> Bool {\n"
            
            output += "\tswitch (lhs, rhs) {\n"
            
            for p in properties {
                if p.hasAssociatedData {
                    output += "\tcase let (.\(p.name)(lv), .\(p.name)(rv)) where lv == rv:\n"
                } else {
                    output += "\tcase (.\(p.name), .\(p.name)):\n"
                }
                output += "\t\treturn true\n"
            }
            
            output += "\tdefault:\n"
            output += "\t\treturn false\n"
            output += "\t}\n"
            output += "}\n"
            return output
        }
    }
}

struct InitCommand: CommandProtocol {
    var verb: String {
        return "init"
    }
    
    var function: String {
        return "generate initializer code"
    }
    
    func run(_ options: GeneratorOptions) -> Result<(), SwiftCodeGeneratorError> {
        return options.run { properties in
            var initializer = "init("
            initializer += properties.map({ $0.initializerParamExpression }).joined(separator: ", ")
            initializer += ") {\n"
            initializer += properties.map({ "\t\($0.constructorAssignmentExpression)\n" }).joined()
            initializer += "}\n"
            return initializer
        }
    }
}

struct EqualityCommand: CommandProtocol {
    var verb: String {
        return "equal"
    }
    
    var function: String {
        return "generate equality code"
    }
    
    func run(_ options: GeneratorOptions) -> Result<(), SwiftCodeGeneratorError> {
        return options.run { properties in
            var output = "public static func ==(lhs: Self, rhs: Self) -> Bool {\n"
            if properties.count > 0 {
                output += properties
                    .map({ "\tguard lhs.\($0.name) == rhs.\($0.name) else { return false }\n" })
                    .joined()
            }
            output += "\treturn true\n"
            output += "}"
            return output
        }
    }
}
