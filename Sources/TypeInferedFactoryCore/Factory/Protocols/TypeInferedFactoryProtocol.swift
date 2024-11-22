//
//  TypeInferedFactoryProtocol.swift
//  TypeInferedFactory
//
//  Created by Bruno on 22/11/24.
//

public protocol TypeInferedFactoryProtocol {
    func make<Output, each T>(
        _ value: repeat each T
    ) -> Output where Output: TypeInferedFactoryBuildable, Output.RequiredInitializationParameter == (repeat each T)
}
