//
//  TypeInferedFactoryMacro.swift
//  TypeInferedFactory
//
//  Created by Bruno on 22/11/24.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum FactoryBuildableMacro: ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
//        let type = type.trimmed
//        return []
        
        let extensionBody = """
        extension Developer: TypeInferedFactoryBuildable {
            typealias RequiredInitializationParameter = (String, Int)

            static func construct(_ parameter: RequiredInitializationParameter) -> Developer {
                Developer(name: parameter.0, age: parameter.1)
            }
        }
        """
        
        let extenasionSyntax = try ExtensionDeclSyntax(.init(stringLiteral: extensionBody))
        
        return [extenasionSyntax]
    }
}

@main
struct TypeInferedFactoryPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FactoryBuildableMacro.self
    ]
}
