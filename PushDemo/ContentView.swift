//
//  ContentView.swift
//  PushDemo
//
//  Created by 康辉 on 2024/9/8.
//

import SwiftUI


func getTitle() -> String {
    return ["Push Test1", "Push Test2", "Push Test3"]
        .randomElement()!
}




struct ContentView: View {
    @State private var title = getTitle()
    @State private var showNotification = false

    var body: some View {
        VStack {
            Spacer()
            Text("\(title)")
                .font(.system(size: 30))
                   .padding()
            Spacer()
            Button("发送本地通知"){
                sendNotification()
            }.padding()
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(40)
            Spacer()
        }
        .padding()
        
    }
    
    func sendNotification() {
            // 请求权限
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                guard granted else { return }
                self.scheduleNotification()
            }
        }

    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "本地通知"
        content.body = "这是一条本地通知"
        content.sound = UNNotificationSound.default
        
        // 立即发送通知，不需要触发器
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        print("发送本地通知")
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        // 添加通知请求
        UNUserNotificationCenter.current().add(request) { (error : Error?) in
                  if let theError = error {
                      print("发送异常")
                      print(theError.localizedDescription)
                  } else {
                      print("发送成功")

                  }
       }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




#Preview {
    ContentView()
}
