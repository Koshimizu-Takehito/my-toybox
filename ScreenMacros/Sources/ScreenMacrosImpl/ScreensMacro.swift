import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: - ScreensMacro

/// Implementation of the `@Screens` macro.
///
/// When applied to an enum, this macro:
/// 1. Automatically adds a `@Screen` attribute to cases without it (MemberAttributeMacro)
///    - This is mainly to keep metadata consistent; type inference itself is done from the case name
///      even if `@Screen` is not present.
/// 2. Generates an extension that conforms to both the `View` and `Screens` protocols (ExtensionMacro)
public struct ScreensMacro {}

// MARK: - Constants

private enum Constants {
    /// Prefix used for generating parameter names for unlabeled associated values.
    /// e.g., "param0", "param1", etc.
    static let unlabeledParameterPrefix = "param"
}

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

    /// Generates the pattern for the switch case.
    ///
    /// Examples:
    /// - No associated values: `.homeScreen`
    /// - Single value: `.detailScreen(id: let id)`
    /// - Multiple values: `.userProfile(userId: let userId, showEdit: let showEdit)`
    /// - Unlabeled: `.detailScreen(let param0)`
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
    ///
    /// Examples:
    /// - No parameters: `HomeScreen()`
    /// - With labeled parameters: `DetailScreen(id: id)`
    /// - With unlabeled parameters: `DetailScreen(param0)` (passed without label)
    /// - With mapping: `ProfileView(detailId: id)` (when `["id": "detailId"]` mapping is applied)
    /// - With mapping to unlabeled: `DetailView(param0)` (when `["id": "_"]` mapping is applied)
    func viewInitializer() -> String {
        if parameters.isEmpty {
            return "\(viewType)()"
        }

        let args = parameters.map { param -> String in
            // For unlabeled parameters, pass without label by default
            guard let sourceLabel = param.label else {
                // Check if there's a mapping to add a label
                if let mappedLabel = parameterMapping[param.name], mappedLabel != "_" {
                    return "\(mappedLabel): \(param.name)"
                }
                // Default: pass without label
                return param.name
            }

            // For labeled parameters, use mapping or original label
            let targetLabel = parameterMapping[sourceLabel] ?? sourceLabel

            // "_" means pass without label
            if targetLabel == "_" {
                return param.name
            }
            return "\(targetLabel): \(param.name)"
        }.joined(separator: ", ")

        return "\(viewType)(\(args))"
    }
}

// MARK: - MemberAttributeMacro

extension ScreensMacro: MemberAttributeMacro {
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

extension ScreensMacro: ExtensionMacro {
    /// Generates an extension that conforms to the `View` and `Screens` protocols.
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

                // Validate mapping keys and emit warnings for unused keys
                validateMappingKeys(
                    mapping: screenInfo.parameterMapping,
                    parameters: parameters,
                    caseName: caseName,
                    caseDecl: caseDecl,
                    context: context
                )

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

        // Resolve access level from the original enum declaration so that
        // the generated API does not accidentally become more public than
        // the source type (e.g. internal enum with public body).
        let accessModifier = resolveAccessModifier(from: enumDecl)

        // Generate the extension that conforms to View and Screens protocols
        // Use fully-qualified `ScreenMacros.Screens` to avoid name collisions
        // with user-defined types named `Screens` in the client module.
        let extensionDecl: DeclSyntax = """
            \(raw: accessModifier)extension \(type.trimmed): View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                \(raw: accessModifier)var body: some View {
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

    /// Resolves the access modifier to use for the generated extension and `body` property.
    ///
    /// The rule is simple:
    /// - If the enum is declared as `public`/`open`/`internal`/`fileprivate`/`private`,
    ///   use the same modifier for the generated extension and property.
    /// - If no explicit access modifier is present, the default is `internal`,
    ///   which we represent by returning an empty string (no keyword emitted).
    private static func resolveAccessModifier(from enumDecl: EnumDeclSyntax) -> String {
        // SwiftSyntax represents modifiers such as `public`, `internal`, etc. as `DeclModifierSyntax`.
        // We look for the first access-control modifier and mirror it.
        let accessKeywords: Set<String> = ["public", "open", "internal", "fileprivate", "private"]

        guard let modifier = enumDecl.modifiers.first(where: { accessKeywords.contains($0.name.text) }) else {
            // No explicit access modifier → default `internal`
            return ""
        }

        // Append a trailing space so it can be placed directly before `extension` / `var`.
        return modifier.name.text + " "
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
                return (label: nil, name: "\(Constants.unlabeledParameterPrefix)\(index)")
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
                        // Second argument must be a dictionary literal
                        guard let mapping = parseMappingDictionary(from: argArray[1].expression) else {
                            throw ScreenMacroError.invalidMappingArgument
                        }
                        parameterMapping = mapping
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
    ///
    /// - Returns: The View type string, or `nil` if the expression is not a type expression.
    /// - Throws: `ScreenMacroError.unsupportedTypeExpression` if the expression looks like a type
    ///           but uses an unsupported syntax pattern.
    private static func parseViewType(from expression: ExprSyntax) throws -> String? {
        // Handle `.self` suffix: extract the base expression
        if let memberAccess = MemberAccessExprSyntax(expression),
           memberAccess.declName.baseName.text == "self",
           let base = memberAccess.base {
            guard let result = stringifyTypeExpression(base) else {
                // Expression has `.self` suffix but base couldn't be parsed
                throw ScreenMacroError.unsupportedTypeExpression
            }
            return result
        }

        // Direct type reference (without `.self`)
        // Note: Returns nil for non-type expressions (e.g., dictionary literals)
        // which is expected and handled by the caller
        return stringifyTypeExpression(expression)
    }

    /// Converts a type expression to its string representation.
    ///
    /// ## Supported Syntax Patterns
    /// - `DeclReferenceExprSyntax`: Simple type name (e.g., `SomeView`)
    /// - `MemberAccessExprSyntax`: Module-qualified type (e.g., `SomeModule.SomeView`)
    /// - `GenericSpecializationExprSyntax`: Generic type (e.g., `SomeView<Int>`)
    /// - Nested combinations of the above (e.g., `SomeModule.GenericView<Int, String>`)
    ///
    /// ## Unsupported Syntax Patterns
    /// The following patterns will return `nil`:
    /// - Closures or function types (e.g., `(Int) -> View`)
    /// - Tuple types (e.g., `(Int, String)`)
    /// - Existential types (e.g., `any View`)
    /// - Opaque types (e.g., `some View`)
    ///
    /// - Returns: The string representation of the type, or `nil` if the expression
    ///            is not a supported type syntax pattern.
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

    /// Validates that all mapping keys correspond to actual parameter labels.
    ///
    /// Emits a warning for any keys that don't match parameter labels, helping
    /// developers catch typos early.
    ///
    /// - Parameters:
    ///   - mapping: The parameter mapping dictionary from @Screen attribute.
    ///   - parameters: The extracted parameters from the enum case.
    ///   - caseName: The name of the enum case (for error messages).
    ///   - caseDecl: The syntax node for the case declaration (for diagnostic location).
    ///   - context: The macro expansion context for emitting diagnostics.
    private static func validateMappingKeys(
        mapping: [String: String],
        parameters: [(label: String?, name: String)],
        caseName: String,
        caseDecl: EnumCaseDeclSyntax,
        context: some MacroExpansionContext
    ) {
        guard !mapping.isEmpty else { return }

        // Collect all valid parameter labels
        let validLabels = Set(parameters.compactMap { $0.label ?? $0.name })

        // Find keys that don't match any parameter label
        let unusedKeys = mapping.keys.filter { !validLabels.contains($0) }

        if !unusedKeys.isEmpty {
            let warning = ScreenMacroWarning.unusedMappingKeys(
                keys: unusedKeys.sorted(),
                caseName: caseName
            )
            context.diagnose(Diagnostic(node: caseDecl, message: warning))
        }
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
    case invalidMappingArgument
    case unsupportedTypeExpression

    var severity: DiagnosticSeverity {
        .error
    }

    var message: String {
        switch self {
        case .notAnEnum:
            return "@Screens can only be applied to an enum"
        case .invalidScreenAttribute:
            // swiftlint:disable:next line_length
            return "@Screen expects a View type and/or a parameter mapping (e.g., @Screen(MyView.self), @Screen([\"id\": \"detailId\"]), @Screen(MyView.self, [\"id\": \"detailId\"]))"
        case .invalidMappingArgument:
            return "@Screen's second argument must be a dictionary literal (e.g., [\"id\": \"detailId\"])"
        case .unsupportedTypeExpression:
            // swiftlint:disable:next line_length
            return "@Screen's View type expression is not supported. Use simple types, module-qualified types, or generic types (e.g., MyView.self, Module.MyView.self, GenericView<Int>.self)"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "ScreenMacros", id: rawValue)
    }
}

/// Warning messages used during macro expansion.
enum ScreenMacroWarning: DiagnosticMessage {
    case unusedMappingKeys(keys: [String], caseName: String)

    var severity: DiagnosticSeverity {
        .warning
    }

    var message: String {
        switch self {
        case .unusedMappingKeys(let keys, let caseName):
            let keyList = keys.map { "\"\($0)\"" }.joined(separator: ", ")
            return "Mapping keys [\(keyList)] do not match any parameter labels in case '\(caseName)' and will be ignored"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "ScreenMacros", id: "unusedMappingKeys")
    }
}

// MARK: - ScreenMacroError

/// Error definitions used during macro expansion.
///
/// These errors wrap `DiagnosticMessage` values and provide detailed error information.
enum ScreenMacroError: Error, CustomStringConvertible {
    case notAnEnum
    case invalidScreenAttribute
    case invalidMappingArgument
    case unsupportedTypeExpression

    var description: String {
        switch self {
        case .notAnEnum:
            return ScreenMacroDiagnostic.notAnEnum.message
        case .invalidScreenAttribute:
            return ScreenMacroDiagnostic.invalidScreenAttribute.message
        case .invalidMappingArgument:
            return ScreenMacroDiagnostic.invalidMappingArgument.message
        case .unsupportedTypeExpression:
            return ScreenMacroDiagnostic.unsupportedTypeExpression.message
        }
    }
}
