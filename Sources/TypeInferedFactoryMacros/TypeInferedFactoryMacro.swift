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
        let type = type.trimmed
        let parsedMembers = membersListPropertyData(declaration.memberBlock.members)
        let tuple = "(\(parsedMembers.map(\.type).joined(separator: ", ")))"
        let initParameters = "(" + parsedMembers.enumerated().compactMap { index, member in
            member.propertyName + ": parameter.\(index)"
        }.joined(separator: ", ") + ")"
        let extensionBody = """
        extension \(type): TypeInferedFactoryBuildable {
            typealias RequiredInitializationParameter = \(tuple)

            static func construct(_ parameter: RequiredInitializationParameter) -> \(type) {
                \(type)\(initParameters)
            }
        }
        """
        
        let extenasionSyntax = try ExtensionDeclSyntax(.init(stringLiteral: extensionBody))
        
        return [extenasionSyntax]
    }
    
    private static func membersListPropertyData(_ meberList: MemberBlockItemListSyntax) -> [PropertyData] {
        meberList.compactMap { member -> PropertyData? in
            guard let varDcl = member.decl.as(VariableDeclSyntax.self),
                 let binding = varDcl.bindings.first,
                 let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                 let typeAnnotation = binding.typeAnnotation?.type
             else {
                 return nil
             }
            
            return PropertyData(propertyName: identifier, type: typeAnnotation.description)
        }
    }
}

@main
struct TypeInferedFactoryPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FactoryBuildableMacro.self
    ]
}
