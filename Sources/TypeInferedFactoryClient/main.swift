import Foundation
import Swinject
import TypeInferedFactory

protocol PersonInformation {
    var name: String { get }
    var age: Int { get }
}

struct Developer: PersonInformation {
    let name: String
    let age: Int
}

struct Person: PersonInformation {
    let name: String
    let age: Int
}

extension Person: TypeInferedFactoryBuildable {
    typealias RequiredInitializationParameter = (String, Int)

    static func construct(_ parameter: RequiredInitializationParameter) -> Person {
        Person(name: parameter.0, age: parameter.1)
    }
}

extension Developer: TypeInferedFactoryBuildable {
    typealias RequiredInitializationParameter = (String, Int)

    static func construct(_ parameter: RequiredInitializationParameter) -> Developer {
        Developer(name: parameter.0, age: parameter.1)
    }
}

let factory = Factory()

let author: Developer = factory.make("Marting Fowler", 72)
let actor: Person = factory.make("Jack Nicholson", 80)

print(author)
print(actor)
