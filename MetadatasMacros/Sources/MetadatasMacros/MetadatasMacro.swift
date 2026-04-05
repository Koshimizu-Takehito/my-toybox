import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: - MetadatasMacro

/// Implementation of the `@Metadatas` macro.
///
/// When applied to an enum, this macro generates an extension that conforms to
/// `ScreenMetadata` protocol, providing `metadata`, `title`, `description`, and `tags` properties.
public struct MetadatasMacro {}

// MARK: - Constants

private enum Constants {
    /// Prefix used for generating parameter names for unlabeled associated values.
    /// e.g., "param0", "param1", etc.
    static let unlabeledParameterPrefix = "param"
}

// MARK: - CaseInfo

/// Represents information about an enum case for code generation.
private struct CaseInfo {
    /// The name of the case (e.g., "gameOfLifeScreen").
    let caseName: String

    /// The Metadata type to instantiate (e.g., "GameOfLifeScreen").
    let metadataType: String

    /// Associated value parameters, if any.
    /// Each tuple contains (label, name) where label is the external name and name is the internal name.
    let parameters: [(label: String?, name: String)]

    /// Generates the pattern for the switch case.
    ///
    /// Examples:
    /// - No associated values: `.gameOfLifeScreen`
    /// - Single value: `.detailScreen(id: let id)`
    /// - Multiple values: `.userProfile(userId: let userId, showEdit: let showEdit)`
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

    /// Generates the Metadata type initializer call.
    ///
    /// Examples:
    /// - No parameters: `GameOfLifeScreen()`
    /// - With parameters: `DetailScreen(id: id)`
    func metadataInitializer() -> String {
        if parameters.isEmpty {
            return "\(metadataType)()"
        }

        let args = parameters.map { param -> String in
            if param.label == nil {
                return param.name
            }
            return "\(param.label!): \(param.name)"
        }.joined(separator: ", ")

        return "\(metadataType)(\(args))"
    }
}

// MARK: - ExtensionMacro

extension MetadatasMacro: ExtensionMacro {
    /// Generates an extension that conforms to the `ScreenMetadata` protocol.
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Ensure the declaration is an enum
        guard let enumDecl = EnumDeclSyntax(declaration) else {
            throw MetadatasMacroError.notAnEnum
        }

        // Collect information about each case
        var caseInfos: [CaseInfo] = []

        for member in enumDecl.memberBlock.members {
            guard let caseDecl = EnumCaseDeclSyntax(member.decl) else {
                continue
            }

            for element in caseDecl.elements {
                let caseName = element.name.text
                let metadataType = caseName.toUpperCamelCase()
                let parameters = extractParameters(from: element.parameterClause)

                caseInfos.append(CaseInfo(
                    caseName: caseName,
                    metadataType: metadataType,
                    parameters: parameters
                ))
            }
        }

        // Generate each case in the switch statement
        let switchCases = caseInfos.map { info -> String in
            return "        case \(info.switchPattern()): \(info.metadataInitializer())"
        }.joined(separator: "\n")

        // Resolve access level from the original enum declaration
        let accessModifier = resolveAccessModifier(from: enumDecl)

        // Generate the extension that conforms to Metadatas protocol
        // Note: The generated extension uses MyToyboxCore.ScreenMetadata for actual type conformance
        // while conforming to MetadatasMacros.Metadatas to satisfy macro expansion requirements
        // @MainActor is required because ScreenMetadata protocol is @MainActor isolated
        let extensionDecl: DeclSyntax = """
            @MainActor
            extension \(type.trimmed): MetadatasMacros.Metadatas {
                \(raw: accessModifier)var metadata: any MyToyboxCore.ScreenMetadata {
                    switch self {
            \(raw: switchCases)
                    }
                }

                \(raw: accessModifier)var title: String {
                    metadata.title
                }

                \(raw: accessModifier)var description: String {
                    metadata.description
                }

                \(raw: accessModifier)var tags: [Tag] {
                    metadata.tags
                }

                \(raw: accessModifier)var thumbnail: AnyView {
                    func open(_ metadata: some MyToyboxCore.ScreenMetadata) -> AnyView {
                        AnyView(type(of: metadata).thumbnail)
                    }
                    return open(metadata)
                }
            }
            """

        guard let extensionDeclSyntax = extensionDecl.as(ExtensionDeclSyntax.self) else {
            return []
        }

        return [extensionDeclSyntax]
    }

    /// Resolves the access modifier to use for the generated extension properties.
    private static func resolveAccessModifier(from enumDecl: EnumDeclSyntax) -> String {
        let accessKeywords: Set<String> = ["public", "open", "internal", "fileprivate", "private"]

        guard let modifier = enumDecl.modifiers.first(where: { accessKeywords.contains($0.name.text) }) else {
            return ""
        }

        return modifier.name.text + " "
    }

    /// Extracts parameter information from an enum case's associated value clause.
    private static func extractParameters(
        from parameterClause: EnumCaseParameterClauseSyntax?
    ) -> [(label: String?, name: String)] {
        guard let clause = parameterClause else {
            return []
        }

        return clause.parameters.enumerated().map { index, param in
            if let firstName = param.firstName {
                let label = firstName.text
                let name = param.secondName?.text ?? label
                return (label: label, name: name)
            } else {
                return (label: nil, name: "\(Constants.unlabeledParameterPrefix)\(index)")
            }
        }
    }
}

// MARK: - String Extension

extension String {
    /// Capitalizes only the first character of a lowerCamelCase string.
    ///
    /// Example: "gameOfLifeScreen" → "GameOfLifeScreen"
    func toUpperCamelCase() -> String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst()
    }
}

// MARK: - MetadatasMacroDiagnostic

/// Diagnostic messages used during macro expansion.
enum MetadatasMacroDiagnostic: String, DiagnosticMessage {
    case notAnEnum

    var severity: DiagnosticSeverity {
        .error
    }

    var message: String {
        switch self {
        case .notAnEnum:
            return "@Metadatas can only be applied to an enum"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "MetadatasMacros", id: rawValue)
    }
}

// MARK: - MetadatasMacroError

/// Error definitions used during macro expansion.
enum MetadatasMacroError: Error, CustomStringConvertible {
    case notAnEnum

    var description: String {
        switch self {
        case .notAnEnum:
            return MetadatasMacroDiagnostic.notAnEnum.message
        }
    }
}

// MARK: - MetadataMacro

/// Implementation of the `@Metadata` macro.
///
/// This macro generates an extension that conforms to `ScreenMetadata` protocol,
/// providing `title`, `description`, and `tags` properties.
public struct MetadataMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Extract arguments from the macro attribute
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            throw MetadataError.missingArguments
        }

        // Parse the required arguments
        var titleExpr: String?
        var descriptionExpr: String?
        var tagsExpr: String?

        for argument in arguments {
            let label = argument.label?.text
            let expression = argument.expression.trimmedDescription

            switch label {
            case "title":
                titleExpr = expression
            case "description":
                descriptionExpr = expression
            case "tags":
                tagsExpr = expression
            default:
                break
            }
        }

        guard let title = titleExpr else {
            throw MetadataError.missingTitle
        }
        guard let description = descriptionExpr else {
            throw MetadataError.missingDescription
        }
        guard let tags = tagsExpr else {
            throw MetadataError.missingTags
        }

        // Resolve access modifier from the original declaration
        let accessModifier = resolveAccessModifier(from: declaration)

        // Generate the extension
        // Note: Access modifier cannot be applied to extension with protocol conformance
        let extensionDecl: DeclSyntax = """
            extension \(type.trimmed): @MainActor ScreenMetadata {
                \(raw: accessModifier)var title: String { \(raw: title) }
                \(raw: accessModifier)var description: String { \(raw: description) }
                \(raw: accessModifier)var tags: [Tag] { \(raw: tags) }
            }
            """

        guard let extensionDeclSyntax = extensionDecl.as(ExtensionDeclSyntax.self) else {
            return []
        }

        return [extensionDeclSyntax]
    }

    /// Resolves the access modifier from the declaration.
    private static func resolveAccessModifier(from declaration: some DeclGroupSyntax) -> String {
        let accessKeywords: Set<String> = ["public", "open", "internal", "fileprivate", "private"]

        if let structDecl = declaration.as(StructDeclSyntax.self) {
            if let modifier = structDecl.modifiers.first(where: { accessKeywords.contains($0.name.text) }) {
                return modifier.name.text + " "
            }
        }

        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            if let modifier = classDecl.modifiers.first(where: { accessKeywords.contains($0.name.text) }) {
                return modifier.name.text + " "
            }
        }

        return ""
    }
}

// MARK: - MetadataError

/// Errors thrown during @Metadata macro expansion.
enum MetadataError: Error, CustomStringConvertible {
    case missingArguments
    case missingTitle
    case missingDescription
    case missingTags

    var description: String {
        switch self {
        case .missingArguments:
            "@Metadata requires title, description, and tags arguments"
        case .missingTitle:
            "@Metadata requires a 'title' argument"
        case .missingDescription:
            "@Metadata requires a 'description' argument"
        case .missingTags:
            "@Metadata requires a 'tags' argument"
        }
    }
}
