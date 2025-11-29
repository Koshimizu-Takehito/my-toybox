import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: - ScreenRegistryMacro

/// Implementation of the `@ScreenRegistry` macro.
///
/// When applied to an enum, this macro:
/// 1. Automatically adds a `@Screen` attribute to cases without it (MemberAttributeMacro)
///    - This is mainly to keep metadata consistent; type inference itself is done from the case name
///      even if `@Screen` is not present.
/// 2. Generates an extension that conforms to the `View` protocol (ExtensionMacro)
public struct ScreenRegistryMacro {}

// MARK: - MemberAttributeMacro

extension ScreenRegistryMacro: MemberAttributeMacro {
    /// Adds a `@Screen` attribute to each enum case that does not already have one.
    ///
    /// Note: Resolution of the `View` type itself is performed in the ExtensionMacro,
    /// and the type can be inferred from the case name even without a `@Screen` attribute.
    /// This macro plays a supporting role to make it look like every case explicitly has `@Screen`.
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        // Skip if the member is not an enum case
        guard let caseDecl = member.as(EnumCaseDeclSyntax.self) else {
            return []
        }

        // Skip if the case already has a @Screen attribute
        if hasScreenAttribute(in: caseDecl.attributes) {
            return []
        }

        // Add a @Screen attribute
        let screenAttribute: AttributeSyntax = "@Screen"
        return [screenAttribute]
    }

    /// Checks whether the attribute list already contains `@Screen`.
    private static func hasScreenAttribute(in attributes: AttributeListSyntax) -> Bool {
        for attribute in attributes {
            guard case .attribute(let attr) = attribute,
                  let identifier = IdentifierTypeSyntax(attr.attributeName),
                  identifier.name.text == "Screen"
            else {
                continue
            }
            return true
        }
        return false
    }
}

// MARK: - ExtensionMacro

extension ScreenRegistryMacro: ExtensionMacro {
    /// Generates an extension that conforms to the `View` protocol.
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Ensure the declaration is an enum
        guard let enumDecl = EnumDeclSyntax(declaration) else {
            throw ScreenMacroError.notAnEnum
        }

        // Collect each case and its corresponding View type
        var cases: [(caseName: String, viewType: String)] = []

        for member in enumDecl.memberBlock.members {
            guard let caseDecl = EnumCaseDeclSyntax(member.decl) else {
                continue
            }

            for element in caseDecl.elements {
                let caseName = element.name.text

                // Cases with associated values are not supported
                if element.parameterClause != nil {
                    throw ScreenMacroError.associatedValueNotSupported(caseName: caseName)
                }

                // Resolve the View type
                let viewType = try resolveViewType(
                    from: caseDecl.attributes,
                    caseName: caseName
                )
                cases.append((caseName, viewType))
            }
        }

        // Generate each case in the switch statement
        let switchCases = cases.map { caseName, viewType -> String in
            return "        case .\(caseName): \(viewType)()"
        }.joined(separator: "\n")

        // Generate the extension that conforms to the View protocol
        let extensionDecl: DeclSyntax = """
            extension \(type.trimmed): View {
                @MainActor @ViewBuilder
                public var body: some View {
                    switch self {
            \(raw: switchCases)
                    }
                }
            }
            """

        guard let extensionDeclSyntax = extensionDecl.as(ExtensionDeclSyntax.self) else {
            return []
        }

        return [extensionDeclSyntax]
    }

    /// Resolves the View type name.
    ///
    /// - Priority:
    ///   1. A type explicitly specified by `@Screen(SomeView.self)` / `@Screen(SomeView)`
    ///   2. Otherwise (no arguments to `@Screen`, or no `@Screen` at all),
    ///      a simple UpperCamelCase conversion of the case name is used.
    ///
    /// - Note:
    ///   - If we ever want to support patterns such as `SomeModule.SomeView.self` or generic types,
    ///     extend the syntax patterns handled here.
    private static func resolveViewType(
        from attributes: AttributeListSyntax,
        caseName: String
    ) throws -> String {
        for attribute in attributes {
            guard case .attribute(let attr) = attribute,
                  let identifier = IdentifierTypeSyntax(attr.attributeName),
                  identifier.name.text == "Screen"
            else {
                continue
            }

            // When arguments are present, use the explicitly specified type.
            if let arguments = LabeledExprListSyntax(attr.arguments),
               let firstArg = arguments.first {
                // Parse expressions of the form GameOfLifeScreen.self.
                if let memberAccess = MemberAccessExprSyntax(firstArg.expression),
                   memberAccess.declName.baseName.text == "self",
                   let base = DeclReferenceExprSyntax(memberAccess.base) {
                    return base.baseName.text
                }

                // Direct type reference (without `.self`).
                if let declRef = DeclReferenceExprSyntax(firstArg.expression) {
                    return declRef.baseName.text
                }

                // If an explicit View type is specified but does not match a known pattern, throw an error.
                throw ScreenMacroError.invalidScreenAttribute
            }

            // @Screen without arguments: convert the case name to UpperCamelCase.
            return caseName.toUpperCamelCase()
        }

        // Even when @Screen is absent, infer the type from the case name (before MemberAttributeMacro injection).
        return caseName.toUpperCamelCase()
    }
}

// MARK: - String Extension

extension String {
    /// Simple helper that capitalizes only the first character of a lowerCamelCase string.
    ///
    /// Example: "appleLogoScreen" → "AppleLogoScreen"
    func toUpperCamelCase() -> String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst()
    }
}

// MARK: - ScreenMacroDiagnostic

/// Diagnostic messages used during macro expansion.
///
/// By conforming to the `DiagnosticMessage` protocol, we can show detailed error
/// information (severity, ID, etc.) in Xcode.
enum ScreenMacroDiagnostic: String, DiagnosticMessage {
    case notAnEnum
    case invalidScreenAttribute
    case associatedValueNotSupported

    var severity: DiagnosticSeverity {
        .error
    }

    var message: String {
        switch self {
        case .notAnEnum:
            return "@ScreenRegistry can only be applied to an enum"
        case .invalidScreenAttribute:
            return "@Screen requires a View type argument (e.g., @Screen(MyView.self))"
        case .associatedValueNotSupported:
            return "@ScreenRegistry does not support enum cases with associated values"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "ScreenMacros", id: rawValue)
    }

    /// Helper to build an error message that includes a case name.
    func withCaseName(_ caseName: String) -> String {
        switch self {
        case .associatedValueNotSupported:
            return "\(message) (case: \(caseName))"
        default:
            return message
        }
    }
}

// MARK: - ScreenMacroError

/// Error definitions used during macro expansion.
///
/// These errors wrap `DiagnosticMessage` values and provide detailed error information.
enum ScreenMacroError: Error, CustomStringConvertible {
    case notAnEnum
    case invalidScreenAttribute
    case associatedValueNotSupported(caseName: String)

    var description: String {
        switch self {
        case .notAnEnum:
            return ScreenMacroDiagnostic.notAnEnum.message
        case .invalidScreenAttribute:
            return ScreenMacroDiagnostic.invalidScreenAttribute.message
        case .associatedValueNotSupported(let caseName):
            return ScreenMacroDiagnostic.associatedValueNotSupported.withCaseName(caseName)
        }
    }

    var diagnostic: ScreenMacroDiagnostic {
        switch self {
        case .notAnEnum:
            return .notAnEnum
        case .invalidScreenAttribute:
            return .invalidScreenAttribute
        case .associatedValueNotSupported:
            return .associatedValueNotSupported
        }
    }
}
