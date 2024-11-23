# 🏭 Type-Inferred Factory Protocol System and Macro

This is a experiment using swift parameter packs. It's core ideia is to creeate protocol system to make factories (or something that is quite a factory) and its produced objects easier.

## Concept

The core idea of this factory like implementation is to not leak object implementation details inside the factory. For that I come up with some protocols to asssist to solve this problem.

**1 - TypeInferedFactoryBuildable**

A protocol for types that can be constructed using a factory method.

```swift
public protocol TypeInferedFactoryBuildable {
    associatedtype RequiredInitializationParameter
    static func construct(_ parameter: RequiredInitializationParameter) -> Self
}
```

Types adopting this protocol declare their required initialization parameters and provide a construct method for object creation.

**2 - TypeInferedFactoryProtocol**

A protocol for factories that create objects conforming to `TypeInferedFactoryBuildable`.

```swift
public protocol TypeInferedFactoryProtocol {
    func make<Output, each T>(
        _ value: repeat each T
    ) -> Output where Output: TypeInferedFactoryBuildable, Output.RequiredInitializationParameter == (repeat each T)
}
```

This protocol defines the make method, which dynamically builds an output object using the provided values.

## Making use of it

To support the factory system, a base factory class is provided. This class implements `TypeInferedFactoryProtocol` and can be overridden for custom behavior:

```swift
open class Factory: TypeInferedFactoryProtocol {
    public init() {}

    public func make<Output, each T>(
        _ value: repeat each T
    ) -> Output where Output: TypeInferedFactoryBuildable, Output.RequiredInitializationParameter == (repeat each T) {
        let tuple = (repeat each value)
        return Output.construct(tuple)
    }
}
```

**Example**

The base factory takes a variadic list of parameters and constructs an object:

```swift
let factory = Factory()

let user: User = factory.make(1, "Alice")
```

The `User` implementation of `TypeInferedFactoryBuildable` makes the parameter pack inside the make method compile time safe.

```swift
struct User {
    let id: Int
    let name: String
}

extension User: TypeInferedFactoryBuildable {
    typealias RequiredInitializationParameter = (Int, String)

    static func construct(_ parameter: RequiredInitializationParameter) -> User {
        return User(id: parameter.0, name: parameter.1)
    }
}
```

The idea works perfectly. But the implementation can be error prone. 

