import Foundation
import Swinject
import TypeInferedFactory

let factory = Factory()

@FactoryBuildable
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

let developer: Developer = factory.make("Martin Fowler", 72)

print(developer)
