//
//  WebVM.swift
//  Enroll
//
//  Created by Edward Arenberg on 11/8/24.
//

import WebKit

final class SwiftUIWebViewModel: ObservableObject {
  
  var addressStr = "https://voterstatus.sos.ca.gov"
  @Published var status : LicenseStatus = .none // .inactive
  var electionDate = ""
  var electionName = ""
//  var electionDate = "November 05, 2024"
//  var electionName = "November 5, 2024, General Election"

  let webView: WKWebView
  
  init() {
    webView = WKWebView(frame: .zero)
    //    webView.navigationDelegate = self
    //    loadUrl()
  }
  
  func loadUrl(license: License) {
    guard let url = URL(string: addressStr) else {
      return
    }
    
    /*
     webView.configuration.userContentController.addUserScript(WKUserScript( source: """
     window.userscr ="hey this is prior injection";
     """, injectionTime: .atDocumentStart, forMainFrameOnly: false))
     */
    
    let day = Calendar.current.component(.day, from: license.dob)
    let month = Calendar.current.component(.month, from: license.dob)
    let year = Calendar.current.component(.year, from: license.dob)
    
    webView.configuration.userContentController.addUserScript(WKUserScript( source: """
function doSubmitForm() {
  document.getElementById('BtnNext').click();
//  document.getElementById('VoterStatusAuthenticateForm').submit();
}
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
document.getElementById('FirstName').value = '\(license.fname)';
document.getElementById('LastName').value = '\(license.lname)';
document.getElementById('DateOfBirthMonth').value = '\(month)';
document.getElementById('DateOfBirthDay').value = '\(day)';
document.getElementById('YearOfBirth').value = '\(year)';
document.getElementById('CdlStateId').value = '\(license.idNum)';
// document.getElementById('Ssn4').value = '3005';
document.getElementById('HasNoSSN4').checked = true;
// setTimeout(doSubmitForm, 5000);
sleep(6000).then(() => { doSubmitForm(); });
""", injectionTime: .atDocumentEnd, forMainFrameOnly: false))
    
    
    let wkNav = webView.load(URLRequest(url: url))
    // You will have the chance in 8 seconds to open Safari debugger if needed. PS: Also put a breakpoint to injectJS function.
    
    /*
     wkNav!.publisher(for: \.effectiveContentMode, options: .new)
     //      .filter { !$0 }
     .receive(on: DispatchQueue.main)
     .sink { _ in
     Task {
     try? await Task.sleep(nanoseconds: 2_000_000_000)
     await self.injectJS()
     }
     }
     */
    
    /*
     Task {
     try? await Task.sleep(nanoseconds: 10_000_000_000)
     Task { @MainActor in
     await self.injectJS()
     }
     /*
      DispatchQueue.main.async {
      Task {
      await self.injectJS()
      }
      }
      */
     }
     */
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
      Task { @MainActor in
        await self.injectJS()
        //        self.status = .inactive
      }
    }
    
  }
  
  @MainActor
  func injectJS() async {
    print("Injecting JS")
    do {
      //      try? await webView.evaluateJavaScript("document.getElementById('BtnNext').click();")
      //      print(res)
      try await Task.sleep(nanoseconds: 1_000_000_000)
      
      print("Get HTML")
      if let html = (try await webView.evaluateJavaScript("document.documentElement.outerHTML.toString()")) as? String {
        
        if html.range(of: "We may need more information to find your record") != nil {
          self.status = .moreinfo
          return
        }
        
        /*
         print(html)
         }
         
         
         webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { html, error in
         if let html = html as? String {
         */
        if let bidx = html.range(of: "DD_DisplayStatus")?.upperBound,
           let cidx = html.range(of: "class=\"\">", range: bidx..<html.endIndex)?.lowerBound,
           let eidx = html.range(of: "</span>", range: cidx..<html.endIndex)?.lowerBound {
          let status = html[html.index(cidx, offsetBy: 9)..<eidx].trimmingCharacters(in: .whitespacesAndNewlines)
          print(status)
          
          // Upcoming Elections
          if let bidx = html.range(of: "Upcoming Elections")?.upperBound,
             let cidx = html.range(of: "<td>", range: bidx..<html.endIndex)?.lowerBound,
             let eidx = html.range(of: "</td>", range: html.index(cidx, offsetBy: 4)..<html.endIndex)?.lowerBound,
             let c2idx = html.range(of: "<td>", range: eidx..<html.endIndex)?.lowerBound,
             let e2idx = html.range(of: "</td>", range: html.index(c2idx, offsetBy: 4)..<html.endIndex)?.lowerBound
          {
            electionDate = html[html.index(cidx, offsetBy: 4)..<eidx].trimmingCharacters(in: .whitespacesAndNewlines)
            electionName = html[html.index(c2idx, offsetBy: 4)..<e2idx].trimmingCharacters(in: .whitespacesAndNewlines)
            self.status = .active
          } else {
            // url = https://www.sos.ca.gov/elections/upcoming-elections
            webView.load(URLRequest(url: URL(string: "https://www.sos.ca.gov/elections/upcoming-elections")!))
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
              Task { @MainActor in
                if let html = (try await self.webView.evaluateJavaScript("document.documentElement.outerHTML.toString()")) as? String {
                  if let bidx = html.range(of: "Upcoming Statewide Elections")?.upperBound,
                     let cidx = html.range(of: "<li><a", range: bidx..<html.endIndex)?.lowerBound,
                     let c2idx = html.range(of: "\">", range: cidx..<html.endIndex)?.lowerBound,
                     let eidx = html.range(of: "</a>", range: html.index(c2idx, offsetBy: 2)..<html.endIndex)?.lowerBound
                  {
                    self.electionName = "Statewide Election"
                    self.electionDate = html[html.index(c2idx, offsetBy: 2)..<eidx].trimmingCharacters(in: .whitespacesAndNewlines)
                  }
                }
                self.status = .active
              }
            }
                
          }
          print(electionDate,electionName)
          
          
        } else {
          self.status = .inactive
        }
        
        //        print(html)
        //        }
      }
    } catch {
      print("Error injecting JS\n\(error.localizedDescription)")
    }
    /*
     webView.evaluateJavaScript("""
     window.temp = "hey here!";
     document.getElementById("content").style.color = "blue";
     """)
     */
  }
}


