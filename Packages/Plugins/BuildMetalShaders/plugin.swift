import Foundation
import PackagePlugin

@main
struct BuildMetalShadersPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        let packageDir = context.package.directoryURL
        let workDir = context.pluginWorkDirectoryURL
        let outputFile = workDir.appending(path: "default.metallib")

        let projectRoot = packageDir.deletingLastPathComponent()
        let scriptPath = projectRoot.appending(path: "Scripts/build_metallib.sh")

        let sourceRoot = target.directoryURL
        let coreShaders = sourceRoot.appending(path: "Utils/Shaders")
        let screenShaders = sourceRoot.appending(path: "Shaders")

        return [
            .prebuildCommand(
                displayName: "Build Metal Shaders (\(target.name))",
                executable: URL(filePath: "/bin/bash"),
                arguments: [
                    scriptPath.path(),
                    "-o", outputFile.path(),
                    "-s", coreShaders.path(),
                    "-s", screenShaders.path(),
                    "-i", coreShaders.path(),
                ],
                outputFilesDirectory: workDir
            ),
        ]
    }
}
