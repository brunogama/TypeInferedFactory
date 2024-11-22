//
//  TypeInferedFactoryMacroError.swift
//  TypeInferedFactory
//
//  Created by Bruno on 22/11/24.
//

enum TypeInferedFactoryMacroError: Error, CustomStringConvertible, Hashable {
    case message(String)

    var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
}
