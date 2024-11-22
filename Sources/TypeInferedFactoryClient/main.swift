import Foundation
import Swinject
import TypeInferedFactory

final class Factory: TypeInferedFactoryProtocol {
    func make<Output, each T>(
        _ value: repeat each T
    ) -> Output where Output: TypeInferedBuildable, Output.RequiredInitializationParameter == (repeat each T) {
        let tuple = (repeat each value)
        return Output.construct(tuple)
    }
}

protocol Person {
    var name: String { get }
    var age: Int { get }
}

struct Author: Person {
    let name: String
    let age: Int
}

struct Actor: Person {
    let name: String
    let age: Int
}

extension Actor: TypeInferedBuildable {
    typealias RequiredInitializationParameter = (String, Int)

    static func construct(_ parameter: RequiredInitializationParameter) -> Actor {
        Actor(name: parameter.0, age: parameter.1)
    }
}

extension Author: TypeInferedBuildable {
    typealias RequiredInitializationParameter = (String, Int)

    static func construct(_ parameter: RequiredInitializationParameter) -> Author {
        Author(name: parameter.0, age: parameter.1)
    }
}

let factory = Factory()

let author: Author = factory.make("Marting Fowler", 72)
let actor: Actor = factory.make("Jack Nicholson", 80)

print(author)
print(actor)
