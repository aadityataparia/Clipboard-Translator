//
//  AppDelegate.swift
//  Translater
//
//  Created by aaditya-taparia on 2017/10/27.
//  Copyright © 2017 aaditya-taparia. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTextFieldDelegate, NSPopoverDelegate {

  let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
  let popover = NSPopover()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
      // Insert code here to initialize your application
    if let button = statusItem.button {
      button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
      button.action = #selector(togglePopover(_:))
    }
    popover.contentViewController = TranslateViewController.freshController()
    popover.delegate = self
    
    var _ = NSEvent.addGlobalMonitorForEvents(matching:[NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown], handler: { _ in self.popover.performClose(self)
    })
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  @objc func togglePopover(_ sender: Any?) {
    if popover.isShown {
      closePopover(sender: sender)
    } else {
      showPopover(sender: sender)
    }
  }
  
  func showPopover(sender: Any?) {
    if let button = statusItem.button {
      NSRunningApplication.current.activate(options: NSApplication.ActivationOptions.activateIgnoringOtherApps )
      popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
    }
    
  }
  
  func closePopover(sender: Any?) {
    popover.performClose(sender)
  }
  
  
  func popoverDidShow(_ notification: Notification) {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "translateClipboard"), object: nil)
  }
}

