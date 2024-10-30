//
//  NotificationsView.swift
//  PushDemo
//
//  Created by 康辉 on 2024/9/17.
//

import SwiftUI
import UserNotifications
import os


struct NotificationsView: View {
    @StateObject var notificationManager: NotificationManager
    @State private var notificationTitle : String = "APNS通知标题"
    @State private var notificationSubtitle : String = "APNS通知副标题"
    @State private var log : String = "日志区域"
    let systemVersion = UIDevice.current.systemVersion
    let currentDevice = UIDevice.current.localizedModel
    private var canSendNotif: Bool {
        !notificationTitle.isEmpty || !notificationSubtitle.isEmpty
    }
    private var notifsAllowed: Bool {
        notificationManager.notificationStatus == "Authorized"
    }
    
    var body: some View {
        NavigationView() {
            
            VStack(spacing: 10) {
                VStack(alignment: .center) {
                    Text("\(log)")
                        .foregroundColor(.red)
                }
                Button("发送本地通知(延时5秒)"){
                    sendNotification()
                    log = "发送本地通知"
                }.padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(40)
                
                Button("判断是否安装了微信"){
                    sendNotification()
                    log = "是否安装了微信："
                }.padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(40)
                
                Button("判断是否安装了抖音"){
                    sendNotification()
                    log = "是否安装抖音："
                }.padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(40)
                
                Form() {
                    
                    Section(header: Text("编辑通知内容").font(.headline)) {
                        TextField("标题", text: $notificationTitle)
                        TextField("副标题", text: $notificationSubtitle)
                            .onAppear() {
                                notificationManager.checkNotificationAuthorization()
                            }
                    }
                    
                    Section(header: Text("通知开关状态")) {
                        Text("\(notificationManager.notificationStatus)")
                        Text("\(notificationManager.pushNotificationToken)")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .contextMenu {
                                Button {
                                    UIPasteboard.general.string = String(describing: notificationManager.pushNotificationToken)
                                } label: {
                                    Text("复制Token")
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                    }
                    if notificationManager.notificationStatus == "Unknown" {
                        Section(footer: Text("Notifications are required to continue").font(.subheadline)) {
                            Button("Enable Notifications") {
                                notificationManager.requestAuthorization()
                            }
                        }
                    } else if notificationManager.notificationStatus == "Denied" {
                        Section(footer: Text("Notifications are required to continue").font(.subheadline)) {
                            Button("Enable Notifications") {
                                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(appSettings)
                                }
                            }
                        }
                    }
                    else {
                        Section(footer: Text( canSendNotif ? "" : "A Title or Subtitle is required to send a notification").font(.subheadline)) {
                            Button("发送通知并退出APP") {
                                
                                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    sendPostRequest()
                                }
                            }.disabled(!canSendNotif)
                        }
                    }
                }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    notificationManager.checkNotificationAuthorization()
                    notificationManager.requestAuthorization()
                }
               
            }.navigationTitle("APNS Demo")
        }.navigationViewStyle(.stack)
            .onAppear {
                notificationManager.checkNotificationAuthorization()
                notificationManager.requestAuthorization()
            }
    }
    
    func sendPostRequest() {
        guard let url = URL(string: "https://WholeLotta.Red/push/send") else {
            print("测试" + "Invalid URL")
            log = "链接异常"
            return
        }
    
        let body: [String: Any] = [
            "title": notificationTitle,
            "subTitle": notificationSubtitle,
            "deviceToken": notificationManager.pushNotificationToken
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("APNS Demo/1.00 | \( currentDevice + "OS" + " " + systemVersion)", forHTTPHeaderField: "User-Agent")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("测试" + "Error: \(error.localizedDescription)")
                log = "请求异常: \(error.localizedDescription)"

                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("测试" + "HTTP Status Code: \(httpResponse.statusCode)")
                log = "HTTP Status Code: \(httpResponse.statusCode)"
                return
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("测试" + "Response Data: \(dataString)")
                log = "Response Data: \(dataString)"
            }
        }.resume()
    }
    
    /**
        请求通知权限，并发送通知
     */
    func sendNotification() {
            // 请求权限
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                guard granted else { return }
                self.scheduleNotification()
            }
        }

    
    /**
     延时5秒发送一个本地通知
     */
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "这是主标题"
        content.subtitle = "这是副标题"
        content.body = "这是一条本地通知内容"
        content.badge = 2
        content.sound = UNNotificationSound.default
        
        //一个触发器，5秒后弹出通知，点击弹出后需要将应用退出后台，前台无法弹出通知
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        print("发送本地通知")
        // 添加通知请求
        UNUserNotificationCenter.current().add(request) { (error : Error?) in
                  if let theError = error {
                      print("发送异常")
                      log = "发送本地通知异常"

                      print(theError.localizedDescription)
                  } else {
                      print("发送成功")
                      log = "发送本地通知成功"

                  }
       }
    }
    
}


struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView(notificationManager: NotificationManager.init())
    }
}




#Preview {
    NotificationsView(notificationManager: NotificationManager.init())
}

