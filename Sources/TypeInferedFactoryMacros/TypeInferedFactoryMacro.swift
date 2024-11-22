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
        let tuple = createRequiredInitializationParameter(members: parsedMembers)
        let memberWiseInit = makeInit(type: type, members: parsedMembers)
        let extensionBody = """
            extension \(type): TypeInferedFactoryBuildable {
                typealias RequiredInitializationParameter = \(tuple)

                static func construct(_ parameter: RequiredInitializationParameter) -> \(type) {
                    \(memberWiseInit)
                }
            }
            """

        let extenasionSyntax = try ExtensionDeclSyntax(.init(stringLiteral: extensionBody))

        return [extenasionSyntax]
    }

    private static func membersListPropertyData(_ memberList: MemberBlockItemListSyntax) -> [PropertyData] {
        let initializerPropertyData = extractPropertyDataFromInitializers(memberList)
        if !initializerPropertyData.isEmpty {
            return initializerPropertyData
        }

        return extractPropertyDataFromVariableDeclarations(memberList)
    }

    private static func extractPropertyDataFromInitializers(_ memberList: MemberBlockItemListSyntax) -> [PropertyData] {
        let initializerDeclarations = memberList.compactMap { $0.decl.as(InitializerDeclSyntax.self) }
        guard !initializerDeclarations.isEmpty else { return [] }

        let initializerPropertyLists = initializerDeclarations.map { initializer -> [PropertyData] in
            initializer.signature.parameterClause.parameters.compactMap { parameter in
                PropertyData(propertyName: parameter.firstName.text, type: parameter.type.description)
            }
        }

        return initializerPropertyLists.max(by: { $0.count < $1.count }) ?? []
    }

    private static func extractPropertyDataFromVariableDeclarations(
        _ memberList: MemberBlockItemListSyntax
    ) -> [PropertyData] {
        memberList.compactMap { member -> PropertyData? in
            guard let variableDeclaration = member.decl.as(VariableDeclSyntax.self),
                let firstBinding = variableDeclaration.bindings.first,
                let propertyName = firstBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                let propertyType = firstBinding.typeAnnotation?.type
            else {
                return nil
            }
            return PropertyData(propertyName: propertyName, type: propertyType.description)
        }
    }

    private static func makeInit(
        type: some SwiftSyntax.TypeSyntaxProtocol,
        members: [PropertyData]
    ) -> String {
        var initParameters = "("
        initParameters += members.enumerated().compactMap { index, member in
            member.propertyName + ": parameter.\(index)"
        }.joined(separator: ", ")
        initParameters += ")"
        return "\(type.description)\(initParameters)"
    }

    private static func createRequiredInitializationParameter(members: [PropertyData]) -> String {
        "(\(members.map(\.type).joined(separator: ", ")))"
    }
}

@main
struct TypeInferedFactoryPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FactoryBuildableMacro.self
    ]
}
