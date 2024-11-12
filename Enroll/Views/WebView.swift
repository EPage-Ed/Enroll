//
//  WebView.swift
//  Enroll
//
//  Created by Edward Arenberg on 11/8/24.
//

import SwiftUI
import WebKit

struct SwiftUIWebView: UIViewRepresentable {
  typealias UIViewType = WKWebView
  
  let webView: WKWebView
  
  func makeUIView(context: Context) -> WKWebView {
    webView
  }
  func updateUIView(_ uiView: WKWebView, context: Context) {
  }
}
