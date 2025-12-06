import Foundation
import PackagePlugin

@main
struct BuildMetalShadersPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        // Only apply to MyToyboxScreens target
        guard target.name == "MyToyboxScreens" else {
            return []
        }
        
        let packageDir = context.package.directoryURL
        let workDir = context.pluginWorkDirectoryURL
        let outputFile = workDir.appending(path: "default.metallib")
        
        // Scripts/build_metallib.sh へのパス（Packages/ の親ディレクトリにある）
        let projectRoot = packageDir.deletingLastPathComponent()
        let scriptPath = projectRoot.appending(path: "Scripts/build_metallib.sh")
        
        // ソースディレクトリ
        let coreShaders = packageDir.appending(path: "Sources/MyToyboxCore/Utils/Shaders")
        let screenShaders = packageDir.appending(path: "Sources/MyToyboxScreens/Shaders")
        
        return [
            .prebuildCommand(
                displayName: "Build Metal Shaders",
                executable: URL(filePath: "/bin/bash"),
                arguments: [
                    scriptPath.path(),
                    "-o", outputFile.path(),
                    "-s", coreShaders.path(),
                    "-s", screenShaders.path(),
                    "-i", coreShaders.path()
                ],
                outputFilesDirectory: workDir
            )
        ]
    }
}
