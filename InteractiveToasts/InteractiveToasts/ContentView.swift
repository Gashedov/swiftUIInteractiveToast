//
//  ContentView.swift
//  InteractiveToasts
//
//  Created by Artem Gorshkov on 26.06.25.
//

import SwiftUI

struct ContentView: View {
    @State var toasts: [Toast] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: { addToast(.coppied) }) {
                Text("Add coppied toast")
            }
            
            Button(action: { addToast(.warning) }) {
                Text("Add warning toast")
            }
            
            Button(action: { addToast(.success) }) {
                Text("Add success toast")
            }
        }
        .padding()
        .interactiveToasts($toasts)
    }
    
    
    private func addToast(_ type: Toast.DefaultViewType) {
        withAnimation(.bouncy) {
            toasts.append(Toast(type))
        }
    }
}

#Preview {
    ContentView()
}
