//
//  MacroDiagnosticMessage.swift
//  TypeInferedFactory
//
//  Created by Bruno on 22/11/24.
//

import SwiftDiagnostics
import SwiftSyntax
import Foundation

struct MacroDiagnosticMessage: DiagnosticMessage, Error, LocalizedError, CustomStringConvertible {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
    
    var description: String { message }
    var localizedDescription: String { message }
    
    init(id: String, message: String, severity: DiagnosticSeverity) {
        self.message = message
        self.diagnosticID = MessageID.makeHashableMacroMessageID(id: id)
        self.severity = severity
    }
}

extension MacroDiagnosticMessage: FixItMessage {
    var fixItID: MessageID { diagnosticID }
}

extension MessageID {
    static func makeHashableMacroMessageID(id: String) -> MessageID {
        MessageID(domain: "br.brunoporciuncula.TypeInferedFactory", id: id)
    }
}
