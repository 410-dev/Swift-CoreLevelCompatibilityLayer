//
//  CoreLevelCompatibilityLayer.swift
//
//  Created by Hoyoun Song on 24/05/2019.
//

import Foundation
class SystemLevelCompatibilityLayer {
    @discardableResult
    public func sh(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        print("Script launched:", args.joined(separator: " "))
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
    
    public func isTheFileExist(at: String) -> Bool {
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
    
    public func getUsername() -> String? {
        return NSUserName()
    }
    
    public func readContents(of: String) -> String {
        if !isTheFileExist(at: of) {
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
