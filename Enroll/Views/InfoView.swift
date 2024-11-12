//
//  InfoView.swift
//  Enroll
//
//  Created by Edward Arenberg on 11/8/24.
//

import SwiftUI

struct InfoView: View {
  @Binding var showInfo: Bool
  
  var body: some View {
    ZStack( alignment: .topTrailing) {
      VStack(spacing: 16) {
        Spacer()
        Text("Tap Scan Card button")
        Text("Scan back of\nState ID Card")
        Text("See your voter status")
        Text("Tap Register if needed")
        Spacer()
      }
      .multilineTextAlignment(.center)
      .font(.title)
      Button("", systemImage: "xmark.circle") {
        withAnimation(.easeInOut(duration: 1)) {
          showInfo.toggle()
        }
      }
      .font(.title)
      .tint(.red)
      .padding(.vertical)
    }
  }
}


