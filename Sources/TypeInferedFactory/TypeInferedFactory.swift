//
//  TypeInferedFactory.swift
//  TypeInferedFactory
//
//  Created by Bruno on 22/11/24.
//

@_exported import TypeInferedFactoryCore

@attached(extension, conformances: TypeInferedFactoryBuildable)
public macro FactoryBuildable() = #externalMacro(module: "TypeInferedFactoryMacros", type: "FactoryBuildableMacro")
