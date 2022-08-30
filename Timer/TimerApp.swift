import SwiftUI

@main
struct TimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var menu: NSMenu!
    
    private var startTime: Double!
    private var timer: Timer!
    private var duration: Double!
    
    private var stopMenuItem: NSMenuItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
            
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer")
            statusButton.title = "00:00"
            statusButton.imagePosition = NSControl.ImagePosition.imageRight
            
            statusButton.font = NSFont(name: "Courier", size: 13)
        }
        
        menu = NSMenu()
        menu.autoenablesItems = false
        stopMenuItem = NSMenuItem(title: "Stop", action: #selector(stop), keyEquivalent: "S")
        stopMenuItem.isEnabled = false
        menu.addItem(stopMenuItem)
        menu.addItem(.separator())
        menu.addItem(MenuItem(value: 5))
        menu.addItem(MenuItem(value: 10))
        menu.addItem(MenuItem(value: 15))
        menu.addItem(MenuItem(value: 20))
        menu.addItem(MenuItem(value: 30))
        menu.addItem(MenuItem(value: 45))
        menu.addItem(MenuItem(value: 60))
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "Q")
        
        statusItem.menu = menu
    }
    
    func MenuItem(value: Int) -> NSMenuItem {
        let item = NSMenuItem(title: "\(value) minutes", action: #selector(start), keyEquivalent: String(value))
        item.tag = value
        return item
    }
    
    @objc func start(_ sender:AnyObject?) {
        let item = sender as! NSMenuItem
        duration = Double(item.tag)
        
        startTime = Date().timeIntervalSince1970 + 1
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        stopMenuItem.isEnabled = true
    }
    
    @objc func stop() {
        timer.invalidate()
        timer = nil
        duration = 0
        stopMenuItem.isEnabled = false
        update()
    }
    
    @objc func update() {
        if (timer == nil) {
            statusItem.button?.title = "\(String(format: "%02d", Int(duration))):00"
        } else {
            let remaining = (duration * 60) - (Date().timeIntervalSince1970 - startTime)
            let min = Int(remaining / 60)
            let sec = Int(remaining - Double((min * 60)))
            statusItem.button?.title = "\(String(format: "%02d", min)):\(String(format: "%02d", sec))"
            
            if remaining <= 0 {
                showAlert()
                stop()
            }
        }
    }
    
    func showAlert() {
        let alert = NSAlert()
        alert.messageText = "Your timer has expired"
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational
        alert.runModal()
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
