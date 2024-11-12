//
//  FlipView.swift
//  Enroll
//
//  Created by Edward Arenberg on 11/8/24.
//

import SwiftUI

struct FlipView<FrontView: View, BackView: View>: View {
  
  let frontView: FrontView
  let backView: BackView
  
  @State private var showBack: Bool = false
  
  var body: some View {
    ZStack() {
      frontView
        .modifier(FlipOpacity(percentage: showBack ? 0 : 1))
        .rotation3DEffect(Angle.degrees(showBack ? 180 : 360), axis: (0,1,0))
      backView
        .modifier(FlipOpacity(percentage: showBack ? 1 : 0))
        .rotation3DEffect(Angle.degrees(showBack ? 0 : 180), axis: (0,1,0))
    }
    /*
     .onTapGesture {
     withAnimation {
     self.showBack.toggle()
     }
     }
     */
    .onAppear {
      withAnimation(.easeInOut(duration: 1)) {
        self.showBack.toggle()
      }
    }
  }
}

private struct FlipOpacity: AnimatableModifier {
  var percentage: CGFloat = 0
  
  var animatableData: CGFloat {
    get { percentage }
    set { percentage = newValue }
  }
  
  func body(content: Content) -> some View {
    content
      .opacity(Double(percentage.rounded()))
  }
}

//#Preview {
//    FlipView()
//}
