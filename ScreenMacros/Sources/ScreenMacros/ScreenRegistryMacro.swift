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

// MARK: - ScreenInfo

/// Information extracted from the `@Screen` attribute.
private struct ScreenInfo {
    /// The View type to instantiate (e.g., "DetailView").
    let viewType: String

    /// Parameter mapping from case labels to View initializer labels.
    /// e.g., ["id": "detailId"] means case's `id` becomes View's `detailId`.
    let parameterMapping: [String: String]
}

// MARK: - CaseInfo

/// Represents information about an enum case for code generation.
private struct CaseInfo {
    /// The name of the case (e.g., "detail").
    let caseName: String

    /// The View type to instantiate (e.g., "DetailView").
    let viewType: String

    /// Associated value parameters, if any.
    /// Each tuple contains (label, name) where label is the external name and name is the internal name.
    /// For example, `case detail(id: Int)` would have `[("id", "id")]`.
    let parameters: [(label: String?, name: String)]

    /// Parameter mapping from case labels to View initializer labels.
    let parameterMapping: [String: String]

    /// Whether this case has associated values.
    var hasAssociatedValues: Bool {
        !parameters.isEmpty
    }

    /// Generates the pattern for the switch case.
    /// e.g., ".detail" or ".detail(let id)" or ".userProfile(let userId, let showEdit)"
    func switchPattern() -> String {
        if parameters.isEmpty {
            return ".\(caseName)"
        }

        let bindings = parameters.map { param -> String in
            if let label = param.label {
                return "\(label): let \(param.name)"
            } else {
                return "let \(param.name)"
            }
        }.joined(separator: ", ")

        return ".\(caseName)(\(bindings))"
    }

    /// Generates the View initializer call.
    /// e.g., "DetailView()" or "DetailView(id: id)" or "DetailView(detailId: id)"
    func viewInitializer() -> String {
        if parameters.isEmpty {
            return "\(viewType)()"
        }

        let args = parameters.map { param -> String in
            // Use the case label (or generated name) as the source
            let sourceLabel = param.label ?? param.name

            // Check if there's a mapping for this parameter
            let targetLabel = parameterMapping[sourceLabel] ?? sourceLabel

            return "\(targetLabel): \(param.name)"
        }.joined(separator: ", ")

        return "\(viewType)(\(args))"
    }
}

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

        // Collect information about each case
        var caseInfos: [CaseInfo] = []

        for member in enumDecl.memberBlock.members {
            guard let caseDecl = EnumCaseDeclSyntax(member.decl) else {
                continue
            }

            for element in caseDecl.elements {
                let caseName = element.name.text

                // Resolve the View type and parameter mapping
                let screenInfo = try resolveScreenInfo(
                    from: caseDecl.attributes,
                    caseName: caseName
                )

                // Extract associated value parameters
                let parameters = extractParameters(from: element.parameterClause)

                caseInfos.append(CaseInfo(
                    caseName: caseName,
                    viewType: screenInfo.viewType,
                    parameters: parameters,
                    parameterMapping: screenInfo.parameterMapping
                ))
            }
        }

        // Generate each case in the switch statement
        let switchCases = caseInfos.map { info -> String in
            return "        case \(info.switchPattern()): \(info.viewInitializer())"
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

    /// Extracts parameter information from an enum case's associated value clause.
    ///
    /// For `case detail(id: Int)`, returns `[("id", "id")]`.
    /// For `case example(value: String, count: Int)`, returns `[("value", "value"), ("count", "count")]`.
    private static func extractParameters(
        from parameterClause: EnumCaseParameterClauseSyntax?
    ) -> [(label: String?, name: String)] {
        guard let clause = parameterClause else {
            return []
        }

        return clause.parameters.enumerated().map { index, param in
            // Use firstName (external label) if available, otherwise generate a name
            if let firstName = param.firstName {
                let label = firstName.text
                // Use secondName if available (internal name), otherwise use firstName
                let name = param.secondName?.text ?? label
                return (label: label, name: name)
            } else {
                // Unlabeled parameter - generate a name like "param0", "param1", etc.
                return (label: nil, name: "param\(index)")
            }
        }
    }

    /// Resolves the View type name and parameter mapping from @Screen attribute.
    ///
    /// Supported patterns:
    /// - `@Screen` → type inferred from case name, no mapping
    /// - `@Screen(SomeView.self)` → explicit type, no mapping
    /// - `@Screen(SomeView.self, ["a": "b"])` → explicit type with mapping
    /// - `@Screen(["a": "b"])` → type inferred from case name, with mapping
    ///
    /// - Parameter mapping:
    ///   - `@Screen(DetailView.self, ["id": "detailId"])` provides a mapping
    ///   - `@Screen(["id": "detailId"])` provides a mapping with inferred type
    ///   - If no mapping is provided, labels are passed through unchanged
    private static func resolveScreenInfo(
        from attributes: AttributeListSyntax,
        caseName: String
    ) throws -> ScreenInfo {
        for attribute in attributes {
            guard case .attribute(let attr) = attribute,
                  let identifier = IdentifierTypeSyntax(attr.attributeName),
                  identifier.name.text == "Screen"
            else {
                continue
            }

            // When arguments are present, parse them
            if let arguments = LabeledExprListSyntax(attr.arguments) {
                let argArray = Array(arguments)

                guard let firstArg = argArray.first else {
                    // @Screen() - empty parentheses, same as @Screen
                    return ScreenInfo(viewType: caseName.toUpperCamelCase(), parameterMapping: [:])
                }

                // Check if first argument is a dictionary literal (mapping only)
                if let mapping = parseMappingDictionary(from: firstArg.expression) {
                    // @Screen(["a": "b"]) - mapping only, infer type from case name
                    return ScreenInfo(
                        viewType: caseName.toUpperCamelCase(),
                        parameterMapping: mapping
                    )
                }

                // First argument should be View type
                if let viewType = try parseViewType(from: firstArg.expression) {
                    // Second argument (optional): parameter mapping dictionary
                    var parameterMapping: [String: String] = [:]
                    if argArray.count >= 2 {
                        parameterMapping = parseMappingDictionary(from: argArray[1].expression) ?? [:]
                    }
                    return ScreenInfo(viewType: viewType, parameterMapping: parameterMapping)
                }

                // @Screen with arguments but couldn't parse them
                throw ScreenMacroError.invalidScreenAttribute
            }

            // @Screen without arguments: convert the case name to UpperCamelCase
            return ScreenInfo(viewType: caseName.toUpperCamelCase(), parameterMapping: [:])
        }

        // Even when @Screen is absent, infer the type from the case name
        return ScreenInfo(viewType: caseName.toUpperCamelCase(), parameterMapping: [:])
    }

    /// Parses a View type from an expression.
    ///
    /// Handles:
    /// - `SomeView.self` → "SomeView"
    /// - `SomeView` → "SomeView"
    /// - `SomeModule.SomeView.self` → "SomeModule.SomeView"
    /// - `SomeView<Int>.self` → "SomeView<Int>"
    /// - `SomeModule.SomeView<Int, String>.self` → "SomeModule.SomeView<Int, String>"
    private static func parseViewType(from expression: ExprSyntax) throws -> String? {
        // Handle `.self` suffix: extract the base expression
        if let memberAccess = MemberAccessExprSyntax(expression),
           memberAccess.declName.baseName.text == "self",
           let base = memberAccess.base {
            return stringifyTypeExpression(base)
        }

        // Direct type reference (without `.self`)
        return stringifyTypeExpression(expression)
    }

    /// Converts a type expression to its string representation.
    ///
    /// Recursively handles:
    /// - `DeclReferenceExprSyntax`: Simple type name (e.g., "SomeView")
    /// - `MemberAccessExprSyntax`: Module-qualified type (e.g., "SomeModule.SomeView")
    /// - `GenericSpecializationExprSyntax`: Generic type (e.g., "SomeView<Int>")
    private static func stringifyTypeExpression(_ expression: ExprSyntax) -> String? {
        // Simple type reference: SomeView
        if let declRef = DeclReferenceExprSyntax(expression) {
            return declRef.baseName.text
        }

        // Member access: SomeModule.SomeView or nested generics
        if let memberAccess = MemberAccessExprSyntax(expression) {
            // Ignore `.self` suffix at this level
            if memberAccess.declName.baseName.text == "self" {
                if let base = memberAccess.base {
                    return stringifyTypeExpression(base)
                }
                return nil
            }

            // Build module.type path
            if let base = memberAccess.base,
               let baseString = stringifyTypeExpression(base) {
                return "\(baseString).\(memberAccess.declName.baseName.text)"
            }
            return nil
        }

        // Generic specialization: SomeView<Int> or SomeView<Int, String>
        if let genericExpr = GenericSpecializationExprSyntax(expression) {
            guard let baseString = stringifyTypeExpression(genericExpr.expression) else {
                return nil
            }

            let genericArgs = genericExpr.genericArgumentClause.arguments
                .map { stringifyGenericArgument($0) }
                .joined(separator: ", ")

            return "\(baseString)<\(genericArgs)>"
        }

        return nil
    }

    /// Converts a generic argument to its string representation.
    ///
    /// Uses the argument's source description, which covers common cases like
    /// `Int`, `String`, `[Int]`, `SomeModule.TypeName`, etc.
    private static func stringifyGenericArgument(_ argument: GenericArgumentSyntax) -> String {
        // For simple cases, we can use the argument's description
        // This handles types like Int, String, [Int], etc.
        return argument.argument.trimmedDescription
    }

    /// Parses a dictionary literal expression into a String-to-String mapping.
    ///
    /// Handles: `["id": "detailId", "name": "userName"]` and `[:]`
    ///
    /// - Returns: A mapping dictionary if the expression is a dictionary literal, `nil` otherwise.
    private static func parseMappingDictionary(from expression: ExprSyntax) -> [String: String]? {
        guard let dictExpr = DictionaryExprSyntax(expression) else {
            return nil
        }

        var mapping: [String: String] = [:]

        // Handle non-empty dictionary
        if case .elements(let elements) = dictExpr.content {
            for element in elements {
                // Extract key (string literal)
                guard let keyLiteral = StringLiteralExprSyntax(element.key),
                      let keySegment = keyLiteral.segments.first,
                      case .stringSegment(let keyString) = keySegment else {
                    continue
                }

                // Extract value (string literal)
                guard let valueLiteral = StringLiteralExprSyntax(element.value),
                      let valueSegment = valueLiteral.segments.first,
                      case .stringSegment(let valueString) = valueSegment else {
                    continue
                }

                mapping[keyString.content.text] = valueString.content.text
            }
        }

        return mapping
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

    var severity: DiagnosticSeverity {
        .error
    }

    var message: String {
        switch self {
        case .notAnEnum:
            return "@ScreenRegistry can only be applied to an enum"
        case .invalidScreenAttribute:
            return "@Screen expects a View type and/or a parameter mapping (e.g., @Screen(MyView.self), @Screen([\"id\": \"detailId\"]), @Screen(MyView.self, [\"id\": \"detailId\"]))"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "ScreenMacros", id: rawValue)
    }
}

// MARK: - ScreenMacroError

/// Error definitions used during macro expansion.
///
/// These errors wrap `DiagnosticMessage` values and provide detailed error information.
enum ScreenMacroError: Error, CustomStringConvertible {
    case notAnEnum
    case invalidScreenAttribute

    var description: String {
        switch self {
        case .notAnEnum:
            return ScreenMacroDiagnostic.notAnEnum.message
        case .invalidScreenAttribute:
            return ScreenMacroDiagnostic.invalidScreenAttribute.message
        }
    }

    var diagnostic: ScreenMacroDiagnostic {
        switch self {
        case .notAnEnum:
            return .notAnEnum
        case .invalidScreenAttribute:
            return .invalidScreenAttribute
        }
    }
}
