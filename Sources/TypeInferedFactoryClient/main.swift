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


//final class Test<U, V> {
//    let u: U
//    let v: V
//    
//    init(u: U, v: V) {
//        self.u = u
//        self.v = v
//    }
//}
//
//extension Test: TypeInferedFactoryBuildable {
//    static func construct(_ parameter: RequiredInitializationParameter) -> Test {
//        Test<U, V>(u: parameter.0, v: parameter.1)
//    }
//    
//    typealias RequiredInitializationParameter = (U, V)
//    
//    
//}
//
//let test: Test = factory.make(1, "2")
//print(test)
