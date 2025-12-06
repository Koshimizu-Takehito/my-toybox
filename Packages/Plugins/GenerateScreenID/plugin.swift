import Foundation
import PackagePlugin

@main
struct GenerateScreenIDPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        // Only apply to MyToyboxScreens target
        guard target.name == "MyToyboxScreens" else {
            return []
        }
        
        let packageDir = context.package.directoryURL
        let workDir = context.pluginWorkDirectoryURL
        let outputFile = workDir.appending(path: "ScreenID.swift")
        
        // Scripts/generate_screen_id.sh へのパス（Packages/ の親ディレクトリにある）
        let projectRoot = packageDir.deletingLastPathComponent()
        let scriptPath = projectRoot.appending(path: "Scripts/generate_screen_id.sh")
        
        // Screens.json のパス（SPM モジュールのリソースを参照）
        let screensJson = packageDir.appending(path: "Sources/MyToyboxScreens/Resources/Screens.json")
        
        return [
            .prebuildCommand(
                displayName: "Generate ScreenID.swift",
                executable: URL(filePath: "/bin/bash"),
                arguments: [
                    scriptPath.path(),
                    "-i", screensJson.path(),
                    "-o", outputFile.path()
                ],
                outputFilesDirectory: workDir
            )
        ]
    }
}

