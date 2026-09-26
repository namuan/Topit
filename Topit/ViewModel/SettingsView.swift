//
//  SettingsView.swift
//  Topit
//
//  Created by apple on 2024/11/19.
//

import SwiftUI
import KeyboardShortcuts
import ServiceManagement

private enum SettingsPage: Hashable {
    case general
    case windows
    case hotkeys
    case filters
}

struct SettingsView: View {
    @State private var selectedItem: SettingsPage? = .general
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedItem) {
                Label("General", image: "gear").tag(SettingsPage.general)
                Label("Windows", image: "window").tag(SettingsPage.windows)
                Label("Hotkey", image: "hotkey").tag(SettingsPage.hotkeys)
                Label("App Filter", image: "block").tag(SettingsPage.filters)
            }
            .listStyle(.sidebar)
            .padding(.top, 9)
        } detail: {
            Group {
                switch selectedItem ?? .general {
                case .general:
                    GeneralView()
                case .windows:
                    WindowView()
                case .hotkeys:
                    HotkeyView()
                case .filters:
                    FilterView()
                }
            }
            .navigationTitle("Topit Settings")
        }
        .frame(width: 600, height: 400)
    }
}

struct GeneralView: View {
    @AppStorage("showOnDock") private var showOnDock: Bool = true
    @AppStorage("showMenubar") private var showMenubar: Bool = true
    
    @State private var launchAtLogin = false
    
    var body: some View {
        SForm {
            SGroupBox(label: "General") {
                SToggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        do {
                            if newValue {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                        } catch {
                            print("Failed to \(newValue ? "enable" : "disable") launch at login: \(error.localizedDescription)")
                        }
                    }
                SDivider()
                SToggle("Show Topit on Dock", isOn: $showOnDock)
                SDivider()
                SToggle("Show Topit on Menu Bar", isOn: $showMenubar)
            }
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                Text("Topit v\(appVersion)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear { launchAtLogin = SMAppService.mainApp.status == .enabled }
        .onChange(of: showMenubar) { newValue in statusBarItem.isVisible = newValue }
        .onChange(of: showOnDock) { newValue in
            if !newValue {
                NSApp.setActivationPolicy(.accessory)
                closeMainWindow()
            } else { NSApp.setActivationPolicy(.regular) }
        }
    }
}

struct WindowView: View {
    @AppStorage("buttonPosition") private var buttonPosition: Int = 0
    @AppStorage("mouseOverAction") private var mouseOverAction: Bool = true
    @AppStorage("keepFocus") private var keepFocus: Bool = false
    @AppStorage("autoAvoid") private var autoAvoid: Bool = true
    @AppStorage("showBorder") private var showBorder: Bool = false
    @AppStorage("maxFps") private var maxFps: Int = 65535
    
    var body: some View {
        SForm(spacing: 10) {
            SGroupBox(label: "Windows") {
                SPicker("Activate Pinned Window on", selection: $mouseOverAction,
                        tips: "When you select \"Left Click\" as the way to activate a window, you need to activate the window before moving it.") {
                    Text("Cursor Hover").tag(true)
                    Text(keepFocus ? "Double Click" : "Left Click").tag(false)
                }
                if !mouseOverAction {
                    SDivider()
                    SToggle("Prevent Focus Switching", isOn: $keepFocus,
                            tips: "Prevent keyboard input from being interrupted when the mouse passes over a pinned window.\nPlease note: You will need to double-click to activate pinned window after enabling this!")
                }
                SDivider()
                SPicker("Control Button Position", selection: $buttonPosition) {
                    Text("Top Leading").tag(0)
                    Text("Top Trailing").tag(2)
                    Text("Bottom Leading").tag(1)
                    Text("Bottom Trailing").tag(3)
                }
                SDivider()
                SPicker("Maximum Refresh Rate", selection: $maxFps) {
                    Text("30 Hz").tag(30)
                    Text("60 Hz").tag(60)
                    Text("120 Hz").tag(120)
                    Text("No Limit").tag(65535)
                }
            }
            SGroupBox {
                SToggle("Ducking Between Pinned Windows", isOn: $autoAvoid,
                        tips: "By enabling this, Topit will hide other pinned windows that overlap with the currently active window.")
                SDivider()
                SToggle("Add Border for Translucent Window", isOn: $showBorder)
            }
        }
    }
}

struct HotkeyView: View {
    var body: some View {
        SForm(spacing: 10) {
            SGroupBox(label: "Hotkey") {
                SItem(label: "Select a Window to Pin") { KeyboardShortcuts.Recorder("", name: .selectWindow) }
                SDivider()
                SItem(label: "Open Window Selector"){ KeyboardShortcuts.Recorder("", name: .openMainPanel) }
            }
            SGroupBox {
                SItem(label: "Pin / Unpin Under-Mouse Window") { KeyboardShortcuts.Recorder("", name: .pinUnpin) }
                SDivider()
                SItem(label: "Pin / Unpin Frontmost Window") { KeyboardShortcuts.Recorder("", name: .pinUnpinTopmost) }
                SDivider()
                SItem(label: "Unpin All Pinned Windows"){ KeyboardShortcuts.Recorder("", name: .unpinAll) }
            }
        }
    }
}

struct FilterView: View {
    @AppStorage("noTitle") var noTitle = true
    
    var body: some View {
        SForm(spacing: 10, noSpacer: true) {
            SGroupBox(label: "App Filter") {
                SToggle("Show Windows with No Title", isOn: $noTitle)
            }
            SGroupBox {
                BundleSelector()
            }
        }
    }
}

extension KeyboardShortcuts.Name {
    static let selectWindow = Self("selectWindow")
    static let openMainPanel = Self("openMainPanel")
    static let pinUnpin = Self("pinUnpin")
    static let pinUnpinTopmost = Self("pinTopmost")
    static let unpinAll = Self("unpinAll")
}
