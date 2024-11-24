//
//  TypeInferedFactory.swift
//  TypeInferedFactory
//
//  Created by Bruno on 22/11/24.
//

open class TypeInferedFactory: TypeInferedFactoryProtocol {
    public init() {}

    public func make<Output, each T>(
        _ value: repeat each T
    ) -> Output where Output: TypeInferedFactoryBuildable, Output.RequiredInitializationParameter == (repeat each T) {
        let tuple = (repeat each value)
        return Output.construct(tuple)
    }
}
