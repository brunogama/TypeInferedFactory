import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(TypeInferedFactoryMacros)
import TypeInferedFactoryMacros

let testMacros: [String: Macro.Type] = [
    "FactoryBuildable": FactoryBuildableMacro.self
]
#endif

final class TypeInferedFactoryTests: XCTestCase {
    func testSimpleStructMacroExpansion() throws {
        #if canImport(TypeInferedFactoryMacros)
        assertMacroExpansion(
            """
            @FactoryBuildable
            struct Developer {
                let name: String
                let age: Int
            }
            """,
            expandedSource: """
                struct Developer {
                    let name: String
                    let age: Int
                }

                extension Developer: TypeInferedFactoryBuildable {
                    typealias RequiredInitializationParameter = (String, Int)

                    static func construct(_ parameter: RequiredInitializationParameter) -> Developer {
                        Developer(name: parameter.0, age: parameter.1)
                    }
                }
                """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMultipleInitClassMacroExpansion() throws {
        #if canImport(TypeInferedFactoryMacros)
        assertMacroExpansion(
            """
            @FactoryBuildable
            final class SimpleContainer {
                let firstValue: Int
                let secondValue: String
                let description: String

                init(firstValue: Int, secondValue: String, description: String, shouldRedact: Bool) {
                    self.firstValue = shouldRedact ? -1 : firstValue
                    self.secondValue = shouldRedact ? "" : secondValue
                    self.description = shouldRedact ? "" : description
                }

                convenience init(firstValue: Int, secondValue: String) {
                    self.init(firstValue: firstValue, secondValue: secondValue, description: "Default description")
                }

                convenience init(firstValue: Int) {
                    self.init(firstValue: firstValue, secondValue: "Default String", description: "Default description")
                }
            }
            """,
            expandedSource: """
                final class SimpleContainer {
                    let firstValue: Int
                    let secondValue: String
                    let description: String

                    init(firstValue: Int, secondValue: String, description: String, shouldRedact: Bool) {
                        self.firstValue = shouldRedact ? -1 : firstValue
                        self.secondValue = shouldRedact ? "" : secondValue
                        self.description = shouldRedact ? "" : description
                    }

                    convenience init(firstValue: Int, secondValue: String) {
                        self.init(firstValue: firstValue, secondValue: secondValue, description: "Default description")
                    }

                    convenience init(firstValue: Int) {
                        self.init(firstValue: firstValue, secondValue: "Default String", description: "Default description")
                    }
                }

                extension SimpleContainer: TypeInferedFactoryBuildable {
                    typealias RequiredInitializationParameter = (Int, String, String, Bool)

                    static func construct(_ parameter: RequiredInitializationParameter) -> SimpleContainer {
                        SimpleContainer(firstValue: parameter.0, secondValue: parameter.1, description: parameter.2, shouldRedact: parameter.3)
                    }
                }
                """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
