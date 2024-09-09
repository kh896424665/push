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
    var body: some View {
        VStack {
            Spacer()
            Text("\(title)")
                .font(.system(size: 30))
                   .padding()
            Spacer()
            Button("今天吃啥？"){
                //执行内容
                title = getTitle()
                
            }.padding()
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(40)
            Spacer()
        }
        .padding()
        
    }
}




#Preview {
    ContentView()
}
