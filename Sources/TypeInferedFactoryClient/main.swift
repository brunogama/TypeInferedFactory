import Foundation
import Swinject
import TypeInferedFactory

let factory = Factory()

@FactoryBuildable
struct Developer {
    let name: String
    let age: Int
}

let developer: Developer = factory.make("Martin Fowler", 72)

print(developer)
