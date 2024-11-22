//
//  TypeInferedFactoryBuildable.swift
//  TypeInferedFactory
//
//  Created by Bruno on 22/11/24.
//

public protocol TypeInferedFactoryBuildable {
    associatedtype RequiredInitializationParameter

    static func construct(
        _ parameter: RequiredInitializationParameter
    ) -> Self
}
