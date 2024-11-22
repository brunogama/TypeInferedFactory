//
//  TypeInferedBuildable.swift
//  TypeInferedFactory
//
//  Created by Bruno on 22/11/24.
//

public protocol TypeInferedBuildable {
    associatedtype RequiredInitializationParameter

    static func construct(
        _ parameter: RequiredInitializationParameter
    ) -> Self
}
