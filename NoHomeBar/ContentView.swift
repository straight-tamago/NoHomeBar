//
//  ContentView.swift
//  NoHomeBar
//
//  Created by straight-tamago★ on 2022/12/28.
//

import SwiftUI
import AudioToolbox

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    @State private var isVibrationOn = false
    @State private var LogMessage = ""
    @State private var ViewLog = true
    @State private var Respring_confirm = false
    @State private var SettingsShowing = false
    @State private var Restore_Confirm = false
    @State private var Update_Alert = false
    @State private var Update_Available = false
    @State private var Notcompatiblewithios14 = false
    struct TargetFilesPath_Struct: Identifiable {
      var  id = UUID()
      let title: String
      let path: String
    }
    @State private var TargetFilesPath = [
        TargetFilesPath_Struct(
            title: "Assets.car",
            path: "/System/Library/PrivateFrameworks/MaterialKit.framework/Assets.car"
        ),
    ]
    var body: some View {
        VStack {
            if ViewLog {
                Text("")
                    .frame(width: 300, height: 200)
                    .disabled(true)
            }
            Text("NoHomeBar__").font(.largeTitle).fontWeight(.bold)
                .alert(isPresented: $Respring_confirm) {
                    Alert(title: Text("Restart SpringBoard"),
                          primaryButton: .destructive(Text("Restart"),action: Respring),
                          secondaryButton: .default(Text("Cancel"))
                    )
                }
            HStack {
                //---------------------------------------------------------------------------
                if TargetFilesPath.allSatisfy { IsSucceeded(TargetFilePath: "file://"+$0.path) == true } == false {
                    Button("Disable HomeBar") {
                        Disable_ShutterSound()
                    }
                    .padding()
                    .accentColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(26)
                    .shadow(color: Color.purple, radius: 15, x: 0, y: 5)
                }
                else {
                    Button("Restore HomeBar") {
                        Restore_Confirm = true
                    }
                    .padding()
                    .accentColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(26)
                    .shadow(color: Color.purple, radius: 15, x: 0, y: 5)
                    .alert(isPresented: $Restore_Confirm) {
                        Alert(title: Text("Restore HomeBar?"),
                              primaryButton: .destructive(Text("Restore"),action: Restore_ShutterSound),
                              secondaryButton: .default(Text("Cancel"))
                        )
                    }
                }
                //---------------------------------------------------------------------------
                Button {
                    SettingsShowing = true
                } label: {
                    Image(systemName: "info.circle")
                        .padding()
                        .accentColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(26)
                        .shadow(color: Color.purple, radius: 15, x: 0, y: 5)
                }.actionSheet(isPresented: $SettingsShowing) {
                    ActionSheet(title: Text("NoHomeBar v\(version)"), message: Text("by straight-tamago"), buttons: [
                        .default(Text("Source Code")) {
                            if let url = URL(string: "https://github.com/straight-tamago/NoHomeBar") {
                                UIApplication.shared.open(url)
                            }
                        },
                        .default(Text("MacDirtyCowDemo (Exploit)")) {
                            if let url = URL(string: "https://github.com/zhuowei/MacDirtyCowDemo") {
                                UIApplication.shared.open(url)
                            }
                        },
                        .default(Text("\(NSLocalizedString("Auto run when the app starts (Status: ", comment: ""))"+String(UserDefaults.standard.bool(forKey: "AutoRun"))+")")) {
                            if #available(iOS 15.0, *) {
                                if UserDefaults.standard.bool(forKey: "AutoRun") == true {
                                    UserDefaults.standard.set(false, forKey: "AutoRun")
                                }else {
                                    UserDefaults.standard.set(true, forKey: "AutoRun")
                                }
                            }
                            else {
                                Notcompatiblewithios14 = true
                            }
                        },
                        .default(Text("\(NSLocalizedString("View Log (Status: ", comment: ""))"+String(UserDefaults.standard.bool(forKey: "ViewLog"))+")")) {
                            if UserDefaults.standard.bool(forKey: "ViewLog") == true {
                                UserDefaults.standard.set(false, forKey: "ViewLog")
                                ViewLog = false
                            }else {
                                UserDefaults.standard.set(true, forKey: "ViewLog")
                                ViewLog = true
                            }
                        },
                        .default(Text("\(NSLocalizedString("Update Check", comment: ""))")) {
                            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
                            let url = URL(string: "https://api.github.com/repos/straight-tamago/NoHomeBar/releases/latest")
                            let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
                                guard let data = data else { return }
                                do {
                                    let object = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
                                    let latast_v = object["tag_name"]!
                                    if version != latast_v as! String {
                                        print("update")
                                        Update_Available = true
                                        Update_Alert = true
                                    }else{
                                        print("no update")
                                        Update_Available = false
                                        Update_Alert = true
                                    }
                                } catch {
                                    print(error)
                                }
                            }
                            task.resume()
                        },
                        .cancel()
                    ])
                }
                .alert(isPresented: $Notcompatiblewithios14) {
                    Alert(title: Text("Not　compatible　with　ios14"),
                          primaryButton: .destructive(Text("OK")),
                          secondaryButton: .default(Text("Cancel"))
                    )
                }
                .alert(isPresented: $Update_Alert) {
                    if Update_Available == true {
                        return Alert(title: Text("Update available"),
                              message: Text("Do you want to download the update from the Github ?"),
                              primaryButton: .destructive(Text("OK"),action: {
                            if let url = URL(string: "https://github.com/straight-tamago/NoHomeBar/releases") {
                                UIApplication.shared.open(url)
                            }
                        }),
                              secondaryButton: .default(Text("Cancel"))
                        )
                    }else{
                        return Alert(title: Text("No Update"),
                              dismissButton: .default(Text("OK"))
                        )
                    }
                }
                //---------------------------------------------------------------------------
            }
            if ViewLog {
                    Text(LogMessage)
                        .padding(.top, 10)
                        List {
                            ForEach(TargetFilesPath) { item in
                              HStack {
                                Text(item.title)
                                Spacer()
                                  if IsSucceeded(TargetFilePath: "file://"+item.path) == true {
                                      Text(
                                        String("OFF")
                                      ).foregroundColor(.green)
                                  }else {
                                      Text(
                                          String("ON")
                                      ).foregroundColor(.red)
                                  }
                              }
                            }.frame(height: 1)
                        }
                    .listStyle(.plain)
                    .frame(width: 300, height: 200)
            }else {
                Text(LogMessage)
                    .padding(.top, 10)
            }
        }.onAppear {
            LogMessage = "v\(version)"
            if UserDefaults.standard.bool(forKey: "ViewLog") == false {
                ViewLog = false
            }
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                // なぜか更新されないから無理矢理
                // 多分osが勝手にやってるから
                print("List refresh")
                TargetFilesPath[0].id = UUID()
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                print("バックグラウンド！")
            }
            if phase == .active {
                print("フォアグラウンド！")
                if UserDefaults.standard.bool(forKey: "AutoRun") == true {
                    Disable_ShutterSound()
                }
            }
            if phase == .inactive {
                print("バックグラウンドorフォアグラウンド直前")
            }
        }
    }
    
    
    //    ---------------------------------------------------------------------------------------
    func Disable_ShutterSound() {
        LogMessage = "Disabling..."
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(i/10)) {
                TargetFilesPath.forEach {
                    LogMessage = overwrite(TargetFilePath: $0.path, OverwriteData: "xxx")
                }
                self.Respring_confirm = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            TargetFilesPath.forEach {
                LogMessage = overwrite(TargetFilePath: $0.path, OverwriteData: "xxx")
            }
        }
    }
    
    func Restore_ShutterSound() {
        LogMessage = "Restoring..."
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(i/10)) {
                TargetFilesPath.forEach {
                    LogMessage = overwrite(TargetFilePath: $0.path, OverwriteData: "BOM")
                }
                self.Respring_confirm = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            TargetFilesPath.forEach {
                LogMessage = overwrite(TargetFilePath: $0.path, OverwriteData: "BOM")
            }
        }
    }
    
    func Respring() {
        let sharedApplication = UIApplication.shared
        let windows = sharedApplication.windows
        if let window = windows.first {
            while true {
                window.snapshotView(afterScreenUpdates: false)
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
