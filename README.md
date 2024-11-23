# 🏭 Type-Inferred Factory Protocol System and Macro

This is a experiment using swift parameter packs. It's core ideia is to create protocol system to make factories (or something that is quite a factory) and its produced objects easier.

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

Imagine implementation of `TypeInferedFactoryBuildable` protocol in a more complex class.

**Example 2**

```swift
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
```

The tuple creation and the init assignment will become more complex.

## The Macro 

To make the life of the engineer easier a Swift Macro was added into the package.

The macro automatically generates the necessary code for `TypeInferedFactoryBuildable` conformance.

**Example 1**

**Input**

```swift
@FactoryBuildable
struct User {
    let id: Int
    let name: String
}
```

**Output (Generated Code)**

```swift
extension User: TypeInferedFactoryBuildable {
    typealias RequiredInitializationParameter = (Int, String)

    static func construct(_ parameter: RequiredInitializationParameter) -> User {
        return User(id: parameter.0, name: parameter.1)
    }
}
```

The macro evaluates its binded target. If it does not have any `inits` it will generate `RequiredInitializationParameter` based on the properties of where it is attached.

**Example 2**

**Input**

```swift
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
```

**Output (Generated Code)**

```swift
extension SimpleContainer: TypeInferedFactoryBuildable {
    typealias RequiredInitializationParameter = (Int, String, String, Bool)

    static func construct(_ parameter: RequiredInitializationParameter) -> SimpleContainer {
        SimpleContainer(firstValue: parameter.0, secondValue: parameter.1, description: parameter.2, shouldRedact: parameter.3)
    }
}
```

Since there are many `inits` the macro will generate `RequiredInitializationParameter` based on the init with biggest number of parameters.

## Installation

This is not production ready. But you can install using SPM.

Add the package to your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/your-repo/TypeInferedFactoryMacro.git", from: "0.0.1")
]
```

## Usage

1. Import the target

```swift
import TypeInferedFactory
```

2. Annotate your type with `@FactoryBuildable`:

```swift
@FactoryBuildable
struct Product {
    let id: Int
    let name: String
}
```

3. Use the factory to create instances:

```swift
let factory = Factory()

let product: Product = factory.make(101, "Table")
```

## Limitations

Since `TypeInferedFactoryBuildable` `construct` method returns `Self` at the moment this code only works with `Strucs` and `Final Classes`. Classes that are not final must be initialezed using `Self`. Swift compiler acts weird when using directly `Self` `inits`.

It's not fully tested. So property wrappers, Member Macros, inits with result builders still a mistery how the macro will produce de code. I recommend to implement `TypeInferedFactoryBuildable` manually if any undesired code generation occurs.
