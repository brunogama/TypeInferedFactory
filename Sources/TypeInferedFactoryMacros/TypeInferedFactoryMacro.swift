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
        of attribute: SwiftSyntax.AttributeSyntax,
        attachedTo declarationGroup: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf typeSyntax: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        let trimmedType = typeSyntax.trimmed
        let propertyDataList = extractProperties(from: declarationGroup.memberBlock.members)
        let initializationTuple = createInitializationParameterType(members: propertyDataList)
        let initializerCode = generateMemberwiseInitializer(for: trimmedType, with: propertyDataList)
        let extensionCode = """
            extension \(trimmedType): TypeInferedFactoryBuildable {
                typealias RequiredInitializationParameter = \(initializationTuple)

                static func construct(_ parameter: RequiredInitializationParameter) -> \(trimmedType) {
                    \(initializerCode)
                }
            }
            """

        let extensionDeclaration = try ExtensionDeclSyntax(.init(stringLiteral: extensionCode))

        return [extensionDeclaration]
    }

    private static func extractProperties(from members: MemberBlockItemListSyntax) -> [PropertyData] {
        let propertiesFromInitializers = extractPropertiesFromInitializers(members)
        if !propertiesFromInitializers.isEmpty {
            return propertiesFromInitializers
        }
        return extractPropertiesFromVariableDeclarations(members)
    }

    private static func extractPropertiesFromInitializers(_ members: MemberBlockItemListSyntax) -> [PropertyData] {
        let initializerDeclarations = members.compactMap { $0.decl.as(InitializerDeclSyntax.self) }
        guard !initializerDeclarations.isEmpty else { return [] }

        let initializerPropertyGroups = initializerDeclarations.map { initializer -> [PropertyData] in
            initializer.signature.parameterClause.parameters.compactMap { parameter in
                PropertyData(propertyName: parameter.firstName.text, type: parameter.type.description)
            }
        }

        return initializerPropertyGroups.max(by: { $0.count < $1.count }) ?? []
    }

    private static func extractPropertiesFromVariableDeclarations(
        _ members: MemberBlockItemListSyntax
    ) -> [PropertyData] {
        members.compactMap { member -> PropertyData? in
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

    private static func generateMemberwiseInitializer(
        for type: some SwiftSyntax.TypeSyntaxProtocol,
        with properties: [PropertyData]
    ) -> String {
        let initializerParameters = properties.enumerated()
            .map { index, property in
                "\(property.propertyName): parameter.\(index)"
            }
            .joined(separator: ", ")
        return "\(type.description)(\(initializerParameters))"
    }

    private static func createInitializationParameterType(members: [PropertyData]) -> String {
        "(\(members.map(\.type).joined(separator: ", ")))"
    }
}

@main
struct TypeInferedFactoryPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FactoryBuildableMacro.self
    ]
}
