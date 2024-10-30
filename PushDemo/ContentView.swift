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
            Text("\(title)")
                .font(.system(size: 30))
                   .padding()
            
            Button("发送本地通知(延时5秒)"){
                sendNotification()
            }.padding()
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(40)
            
        
        }
        .padding()
        
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
