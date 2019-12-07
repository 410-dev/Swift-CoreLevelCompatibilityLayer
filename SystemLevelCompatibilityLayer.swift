//
//  CoreLevelCompatibilityLayer.swift
//
//  Created by Hoyoun Song on 24/05/2019.
//

import Foundation
class SystemLevelCompatibilityLayer {
    @discardableResult
    public func executeShellScript(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
    
    @discardableResult
    public func executeShellScriptWithRootPrivilages(pass: String, _ args: String) -> Int32 {
        return pipeCommandline(primaryCommand: "echo#" + pass, execCommands: "sudo#-S#" + args)
    }
    
    @discardableResult
    public func pipeCommandline(primaryCommand: String, execCommands: String) -> Int32 {
        let pipe = Pipe()
        let echo = Process()
        echo.launchPath = "/usr/bin/env"
        echo.arguments = primaryCommand.components(separatedBy: "#")
        echo.standardOutput = pipe
        let uniq = Process()
        uniq.launchPath = "/usr/bin/env"
        uniq.arguments = execCommands.components(separatedBy: "#")
        uniq.standardInput = pipe
        let out = Pipe()
        uniq.standardOutput = out
        echo.launch()
        uniq.launch()
        uniq.waitUntilExit()
        return uniq.terminationStatus
    }
    
    public func doesTheFileExist(at: String) -> Bool {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: at) {
            return true
        } else {
            var isDir : ObjCBool = true
            if fileManager.fileExists(atPath: at, isDirectory:&isDir) {
                return true
            } else {
                return false
            }
        }
    }
    
    public func isFile(at: String) -> Bool {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: at) {
            return true
        } else {
            return false
        }
    }
    
    public func getUsername() -> String? {
        return NSUserName()
    }
    
    public func readContents(of: String) -> String {
        if !doesTheFileExist(at: of) {
            return "returned:nofile"
        }else{
            do{
                let filepath = URL.init(fileURLWithPath: of)
                let content = try String(contentsOf: filepath, encoding: .utf8)
                return content
            }catch{
                exit(1)
            }
        }
    }
    
    public func writeData(to: String, content: String) -> Bool{
        let file = to
        let text = content
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
                return true
            }catch {
                return false
            }
        }else{
            return false
        }
    }
    
    public func getHomeDirectory() -> String{
        let fsutil = FileManager.default
        var homeurl = fsutil.homeDirectoryForCurrentUser.absoluteString
        if homeurl.contains("file://"){
            homeurl = homeurl.replacingOccurrences(of: "file://", with: "")
        }
        return homeurl
    }
    
}
