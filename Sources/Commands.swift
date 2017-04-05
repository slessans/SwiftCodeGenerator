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
            output += "\treturn "
            if properties.count > 0 {
                output += properties.map({ "lhs.\($0.name) == rhs.\($0.name)" }).joined(separator: " &&\n\t\t")
                output += "\n"
            } else {
                output += "true\n"
            }
            output += "}"
            return output
        }
    }
}
