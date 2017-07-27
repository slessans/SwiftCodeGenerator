//
//  main.swift
//  SwiftCodeGenerator
//
//  Created by Scott Lessans on 3/15/16.
//  Copyright © 2016 Scott Lessans. All rights reserved.
//

import Foundation
import Commandant


setlinebuf(stdout)

let registry = CommandRegistry<SwiftCodeGeneratorError>()
registry.register(InitCommand())
registry.register(EqualityCommand())
registry.register(EnumEqualityCommand())

let helpCommand = HelpCommand(registry: registry)
registry.register(helpCommand)

registry.main(defaultVerb: helpCommand.verb) { error in
    fputs(error.description + "\n", stderr)
}


