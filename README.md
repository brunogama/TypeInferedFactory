# 🏭 Type-Inferred Factory Protocol System and Macro

This is an experiment using Swift parameter packs. Its core idea is to create a protocol system to make factories (or something resembling factories) and their produced objects more manageable.

## Concept

The core idea of this factory-like implementation is to encapsulate object creation details within a factory, preventing direct exposure of implementation details. To achieve this, I devised two protocols to address this problem.

**1 - `TypeInferedFactoryBuildable`**

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

This protocol defines a make method, dynamically constructing an output object using the provided values.

## Usage

To support this factory system, a base class Factory is provided. This class implements TypeInferedFactoryProtocol and can be overridden for custom behavior:

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

### Example Usage

1. Import the library:

```swift
import TypeInferedFactory
```

2. Use the factory to create an object:

```swift
let factory = Factory()
let user: User = factory.make(1, "Alice")
```

3. Implement TypeInferedFactoryBuildable in your type:

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

The `User` implementation of `TypeInferedFactoryBuildable` ensures compile-time safety for the parameter pack inside the `make` method. If any arguments passed to the `make` method differ from the RequiredInitializationParameter tuple, the Swift compiler will throw an error.

### Example with a Complex Class

For more complex types, implementing the `construct` method manually can become cumbersome:

```swift
import TypeInferedFactory

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
        self.init(firstValue: firstValue, secondValue: secondValue, description: "Default description", shouldRedact: false)
    }

    convenience init(firstValue: Int) {
        self.init(firstValue: firstValue, secondValue: "Default String", description: "Default description", shouldRedact: false)
    }
}

extension SimpleContainer: TypeInferedFactoryBuildable {
    typealias RequiredInitializationParameter = (Int, String, String, Bool)

    static func construct(_ parameter: RequiredInitializationParameter) -> SimpleContainer {
        SimpleContainer(
            firstValue: parameter.0,
            secondValue: parameter.1,
            description: parameter.2,
            shouldRedact: parameter.3
        )
    }
}

```

The `RequiredInitializationParameter` tuple reflects all parameters of the initializer with the largest number of arguments. Handling these tuple indices can become tedious in complex classes.

## The Macro

To simplify this process, a Swift macro is included in the package. It automatically generates the necessary code for `TypeInferedFactoryBuildable` conformance.

### Example with Macro

**Input**

```swift
import TypeInferedFactory

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

The macro evaluates its target. If the target does not have any initializers, it generates `RequiredInitializationParameter` based on the properties of the type.

### Example with a Complex Class

**Input**

```swift
import TypeInferedFactory

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
        self.init(firstValue: firstValue, secondValue: secondValue, description: "Default description", shouldRedact: false)
    }

    convenience init(firstValue: Int) {
        self.init(firstValue: firstValue, secondValue: "Default String", description: "Default description", shouldRedact: false)
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

The macro generates the `RequiredInitializationParameter` based on the initializer with the largest number of parameters.

## Installation

This is not production-ready, but you can install it using Swift Package Manager (SPM).

Add the package to your Package.swift:


```swift
dependencies: [
    .package(url: "https://github.com/your-repo/TypeInferedFactoryMacro.git", from: "0.0.1")
]
```

## Limitations

Non-Final Classes: Since the construct method of `TypeInferedFactoryBuildable` returns `Self`, this implementation supports only structs and final classes. Non-final classes cannot reliably use Self.init because the compiler cannot guarantee correct initialization of subclasses, which may result in runtime errors or compilation issues. Common compiler errors include:

* "Cannot use 'Self.init' in a non-final class"
* "Use of 'Self' initializer in a non-final class requires 'required' modifier"

For non-final classes, you must implement TypeInferedFactoryBuildable manually.

Experimental Status: The macro is not fully tested. Its behavior with property wrappers, member macros, and result builder initializers is not guaranteed. If undesired code generation occurs, implement TypeInferedFactoryBuildable manually.
