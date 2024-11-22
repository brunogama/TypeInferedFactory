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
    func testMacro() throws {
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
}
