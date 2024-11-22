//
//  MacroDiagnosticMessage.swift
//  TypeInferedFactory
//
//  Created by Bruno on 22/11/24.
//

import SwiftDiagnostics
import SwiftSyntax

struct MacroDiagnosticMessage: DiagnosticMessage, Error {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity

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
