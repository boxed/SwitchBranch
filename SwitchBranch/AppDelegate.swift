//
//  AppDelegate.swift
//  SwitchBranch
//
//  Created by Anders Hovmöller on 2017-11-10.
//  Copyright © 2017 Anders Hovmöller. All rights reserved.
//

import Cocoa

extension URL {
    public var queryItems: [String: String] {
        var params = [String: String]()
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce([:], { (_, item) -> [String: String] in
                params[item.name] = item.value
                return params
            }) ?? [:]
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var path: NSTextField!
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(self.handleGetURL(event:reply:)), forEventClass: UInt32(kInternetEventClass), andEventID: UInt32(kAEGetURL) )
    }
    
    @objc func handleGetURL(event: NSAppleEventDescriptor, reply:NSAppleEventDescriptor) {
        if let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue {
            if let path = UserDefaults.standard.string(forKey:"path") {
                if let url = URL.init(string: urlString) {
                    if let ref = url.queryItems["ref"] {
                        let fetch = Process()
                        fetch.launchPath = "/usr/local/bin/git"
                        fetch.arguments = ["fetch"]
                        fetch.currentDirectoryPath = path
                        fetch.launch()
                        fetch.waitUntilExit()

                        let branch = ref.replacingOccurrences(of: "refs/heads/", with: "")
                        let task = Process()
                        task.launchPath = "/usr/local/bin/git"
                        task.arguments = ["checkout", branch]
                        task.currentDirectoryPath = path
                        task.launch()
                        task.waitUntilExit()
                        exit(0)
                    }
                }
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

