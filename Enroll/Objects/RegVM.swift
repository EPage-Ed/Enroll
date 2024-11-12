//
//  RegVM.swift
//  Enroll
//
//  Created by Edward Arenberg on 11/8/24.
//

import SwiftUI
import WebKit

final class WebHandler: NSObject, WKScriptMessageHandler {
  weak var model: SwiftUIWebViewRegisterModel?
  
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    print("Message:\n\(message.name)\n\(message.body)")
    if message.name == "adClicked" {
      print("Submitted Form...")
      model?.processing = true
      /*
      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        self.model?.nextStep()
        self.model?.processing = false
        //        self.model?.step2()
      }
       */
    }
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "estimatedProgress", let progress = model?.webView.estimatedProgress {
      print("Progress: \(progress)")
//      progressView.progress = Float(webView.estimatedProgress)
      if progress == 1.0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          print("Injecting JS")
          self.model?.nextStep()
        }
      }
    }
  }

}

final class SwiftUIWebViewRegisterModel: ObservableObject {
  
  var addressStr = "https://covr.sos.ca.gov"
  private var webHandler = WebHandler()
  var license : License?
  var step = 0
  
  @Published var isCitizen = false
  @Published var county = "None"
  var countyIndex = 0
  @Published var choosePartyPref = false
  @Published var partyPref = ""
  var partyPrefIndex = 0
  @Published var otherPartyPref = ""
  @Published var showNoPartyInfo = false
  @Published var hasSSN = false
  @Published var ssn4 = ""
  @Published var getStateVoteInfo = false
  @Published var getCountyVoteInfo = false
  
  @Published var processing = false
  
  var canRegister: Bool {
    isCitizen && county != "None" && (!choosePartyPref || choosePartyPref && ((partyPref.count > 0 && partyPref != "OTHER  PARTY") || (partyPref == "OTHER  PARTY" && otherPartyPref.trimmingCharacters(in: .whitespaces).count > 0)))
  }
  
  let webView: WKWebView
  
  func nextStep() {
    step += 1
    switch step {
    case 2: step2()
    case 3: step3()
    default: break
    }
  }
  
  func step2() {
    print("Step 2")
    let day = Calendar.current.component(.day, from: license!.dob)
    let month = Calendar.current.component(.month, from: license!.dob)
    let year = Calendar.current.component(.year, from: license!.dob)
    
    var script = """
     document.getElementById('IsUSCitizen').checked = true;
     document.getElementById('RegistrationChoice_1').checked = true;
     document.getElementById('FirstName').value = '\(license!.fname)';
     document.getElementById('LastName').value = '\(license!.lname)';
     document.getElementById('MonthOfBirth').value = '\(month)';
     document.getElementById('DayOfBirth').value = '\(day)';
     document.getElementById('YearOfBirth').value = '\(year)';
     document.getElementById('CaliforniaID').value = '\(license!.idNum)';
     document.getElementById('Home_StreetAddress').value = '\(license!.street)';
     document.getElementById('Home_City').value = '\(license!.city)';
     document.getElementById('Home_Zip').value = '\(license!.zip.prefix(5))';
     """
    if hasSSN {
      script.append("document.getElementById('SSN4').value = '\(ssn4)';\n")
    } else {
      script.append("document.getElementById('HasNoSSN').chekced = true;\n")
    }
    if countyIndex > 0 {
      print(countyIndex)
      script.append("document.getElementById('Home_CountyId').value = '\(countyIndex)';\n")
    }
    if choosePartyPref {
      print(partyPrefIndex, partyPref, otherPartyPref)
      script.append("document.getElementById('PoliticalPreferenceType_1').checked = true;\n")
      script.append("document.getElementById('PoliticalPartyId').value = '\(partyPrefIndex)';\n")
      if partyPref == "OTHER  PARTY" {
        script.append("document.getElementById('OtherPoliticalParty').value = '\(otherPartyPref)';\n")
      }
    } else {
      script.append("document.getElementById('PoliticalPreferenceType_2').checked = true;\n")
    }
    script.append("document.getElementById('VoterRegistrationForm').addEventListener('submit', function(event) {  event.preventDefault(); window.webkit.messageHandlers.adClicked.postMessage('submit'); this.submit(); });\n")
    webView.evaluateJavaScript(script)
    //    let script = WKUserScript(source: javaScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    //    webView.configuration.userContentController.addUserScript(script)
    processing = false
  }
  
  
  func step3() {
    print("Step 3")
    var script = """
     """
    
    if getStateVoteInfo {
      script.append("document.getElementById('IsVIG_True').checked = true;\n")
    } else {
      script.append("document.getElementById('IsVIG_False').checked = true;\n")
    }
    if getCountyVoteInfo {
      script.append("document.getElementById('IsSampleBallot_True').checked = true;\n")
    } else {
      script.append("document.getElementById('IsSampleBallot_False').checked = true;\n")
    }
    
    script.append("document.getElementById('VoterRegistrationForm').addEventListener('submit', function(event) {  event.preventDefault(); window.webkit.messageHandlers.adClicked.postMessage('submit'); this.submit(); });\n")
    webView.evaluateJavaScript(script)
    //    let script = WKUserScript(source: javaScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    //    webView.configuration.userContentController.addUserScript(script)
    processing = false
  }
  
  
  init() {
    //    webView = WKWebView(frame: .zero)
    
    let config = WKWebViewConfiguration()
    //    let preferences = WKPreferences()
    //    preferences.javaScriptEnabled = true
    //    config.preferences = preferences
    
    let userController = WKUserContentController()
    
    //    let javaScript = "showRewardsAd = function() { window.webkit.messageHandlers.adClicked.postMessage(); }"
    let javaScript = """
     document.getElementById('ClassificationType_1').checked = true;
     document.getElementById('VoterRegistrationForm').addEventListener('submit', function(event) {  event.preventDefault(); window.webkit.messageHandlers.adClicked.postMessage('submit'); this.submit(); });
     """
    let script = WKUserScript(source: javaScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    userController.addUserScript(script)
    userController.add(webHandler, name: "adClicked")
    config.userContentController = userController
    
    webView = WKWebView(frame: .zero, configuration: config)
    webHandler.model = self
    webView.addObserver(webHandler, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)

    //    webView.navigationDelegate = self
    //    loadUrl()
  }
  
  func loadUrl(license: License) {
    guard let url = URL(string: addressStr) else {
      return
    }
    
    webView.load(URLRequest(url: url))
    
  }
  
}

#Preview {
  RegisterView(rVM: SwiftUIWebViewRegisterModel(), license: .init(code: ""))
}
