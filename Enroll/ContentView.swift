//
//  ContentView.swift
//  Enroll
//
//  Created by Edward Arenberg on 11/8/24.
//

import SwiftUI
import CodeScanner

struct ContentView: View {
  @State private var isPresentingScanner = false
  @State private var scannedCode: String?
  @State private var license = License(code: "")
  @State private var showInfo = false
  @State private var infoSize = 20.0
  @State private var progress = 0.0
  @State private var showRegister = false
  @StateObject private var model = SwiftUIWebViewModel()
  @StateObject private var rmodel = SwiftUIWebViewRegisterModel()
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.openURL) var openURL
  
  @State private var scanNum = 0
  
  // function to post a form to a url
  func postForm(url: URL, form: [String: String]) async -> Data? {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = form.map { "\($0.key)=\($0.value)" }.joined(separator: "&").data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    if let (data,response) = try? await URLSession.shared.data(for: request) {
      return data
    }
    return nil
  }
  
  var body: some View {
    ZStack {
      VStack(spacing: 10) {
        let _ = print(model.status)
        switch model.status {
        case .none:
          VStack {
            Text("Enroll").font(.system(size: 64, weight: .bold, design: .rounded))
              .foregroundStyle(.linearGradient(colors: [.red,(colorScheme == .light ? .gray : .white),.blue], startPoint: .leading, endPoint: .trailing))
              .padding()
            VStack {
              Text("Voter Registration Info")
              Text("Available in California")
            }
            .font(.footnote)
            /*
             .background {
             RoundedRectangle(cornerRadius: 25.0)
             .fill(.thickMaterial)
             //                  .strokeBorder(Color.white, lineWidth: 2)
             }
             */
            Spacer()
            Button("Scan Card") {
              isPresentingScanner = true
              model.status = .scanning
            }
            .buttonStyle(.borderedProminent)
            .font(.largeTitle).bold()
            .tint(colorScheme == .dark ? .clear : .black)
            .foregroundStyle(.linearGradient(colors: [.red,.white,.blue], startPoint: .leading, endPoint: .trailing))
            .background {
              RoundedRectangle(cornerRadius: 25.0)
                .fill(Color.clear)
                .strokeBorder(Color.white, lineWidth: 2)
              //              .background(.ultraThinMaterial)
            }
            .padding()
            Image("idCalmed")
              .padding()
            Spacer()
            Button("", systemImage: "info.circle") {
              withAnimation(.easeInOut(duration: 1)) {
                showInfo.toggle()
                //                infoSize = showInfo ? 300 : 20
              }
              //            isPresentingScanner = true
              //            model.status = .scanning
            }
            .font(.largeTitle).bold()
          }
        case .scanning:
          ProgressView()
        case .scanned:
          ZStack {
            SwiftUIWebView(webView: model.webView)
              .frame(width: 1, height: 1)
            VStack(alignment: .leading) {
              Text("Processing...")
                .padding(.leading)
              ProgressView(timerInterval: Date()...(Date().addingTimeInterval(10)), countsDown: false)
                .progressViewStyle(.linear)
                .foregroundStyle(.linearGradient(colors: [.red,.white,.blue], startPoint: .leading, endPoint: .trailing))
                .padding()
            }
          }
        case .underage:
          VStack(spacing: 20) {
            Text("Underage")
              .font(.title)
              .padding(.bottom, 20)
            Text("Must be 18 to Vote*")
              .font(.title2)
          }
          .foregroundStyle(Color.black)
          .padding(20)
          .background {
            RoundedRectangle(cornerRadius: 25.0)
              .foregroundStyle(.linearGradient(colors: [.red,.white,.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            //              .fill(Color.clear)
            //              .strokeBorder(Color.white, lineWidth: 2)
            //              .background(.ultraThinMaterial)
          }
          VStack {
            Button("Visit Voter Registration Site") {
              openURL(URL(string: "https://www.sos.ca.gov/elections/voter-registration")!)
            }
            Text("* Must be 18 by the date of the next election\nVisit the site to verify if eligible,\nor to pre-register to vote if age 16 or 17.")
              .font(.footnote)
              .multilineTextAlignment(.center)
          }
          .padding()
          Button("Start Over") {
            model.status = .none
          }
          .buttonStyle(.borderedProminent)
          .foregroundStyle(.linearGradient(colors: [.red,.white,.blue], startPoint: .leading, endPoint: .trailing))
          .tint(.black)
          .font(.title)
          .padding(.top, 40)
        case .verifying:
          ProgressView()
        case .moreinfo:
          VStack(spacing: 20) {
            Text("May Need More Info")
              .font(.title)
              .padding(.bottom, 20)
            Text("Visit Site to Verify")
              .font(.title2)
            Button("Verify") {
              openURL(URL(string: "https://verify.vote.org/your-status")!)
            }
            .font(.title)
            .tint(.black)
            .buttonStyle(.borderedProminent)
            .foregroundStyle(.linearGradient(colors: [.red,.white,.blue], startPoint: .leading, endPoint: .trailing))
          }
          .foregroundStyle(Color.black)
          .padding(20)
          .background {
            RoundedRectangle(cornerRadius: 25.0)
              .foregroundStyle(.linearGradient(colors: [.red,.white,.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            //              .fill(Color.clear)
            //              .strokeBorder(Color.white, lineWidth: 2)
            //              .background(.ultraThinMaterial)
          }
          Button("Start Over") {
            model.status = .none
          }
          .buttonStyle(.borderedProminent)
          .foregroundStyle(.linearGradient(colors: [.red,.white,.blue], startPoint: .leading, endPoint: .trailing))
          .tint(.black)
          .font(.title)
          .padding(.top, 40)
          
        case .active:
          VStack(spacing: 20) {
            Text("❤️ Registered to Vote ❤️")
              .font(.title)
              .padding(.bottom, 20)
            Text("Next Election")
              .font(.title2)
            Text(model.electionName)
              .font(.title3)
            Text(model.electionDate)
              .font(.title3)
            Button("More Info") {
              openURL(URL(string: "http://www.sos.ca.gov/elections/upcoming-elections")!)
            }
            .foregroundStyle(Color.blue)
            .font(.title2)
          }
          .foregroundStyle(Color.black)
          .padding(20)
          .background {
            RoundedRectangle(cornerRadius: 25.0)
              .foregroundStyle(.linearGradient(colors: [.red,.white,.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            //              .fill(Color.clear)
            //              .strokeBorder(Color.white, lineWidth: 2)
            //              .background(.ultraThinMaterial)
          }
          Button("Start Over") {
            model.status = .none
          }
          .buttonStyle(.borderedProminent)
          .foregroundStyle(.linearGradient(colors: [.red,.white,.blue], startPoint: .leading, endPoint: .trailing))
          .tint(.black)
          .font(.title)
          .padding(.top, 40)
        case .inactive:
          Spacer()
          VStack(spacing: 40) {
            Text("No Registration Found")
            Button("Register to Vote") {
              //              openURL(URL(string: "https://covr.sos.ca.gov")!)
              showRegister = true
            }
            .buttonStyle(.borderedProminent)
            .foregroundStyle(.linearGradient(colors: [.red,.white,.blue], startPoint: .leading, endPoint: .trailing))
            .tint(.black)
          }
          .font(.title)
          .foregroundStyle(Color.black)
          .padding(20)
          .background {
            RoundedRectangle(cornerRadius: 25.0)
              .foregroundStyle(.linearGradient(colors: [.red,.white,.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            //              .fill(Color.clear)
            //              .strokeBorder(Color.white, lineWidth: 2)
            //              .background(.ultraThinMaterial)
          }
          
          VStack(spacing: 20) {
            HStack {
              Link("Why Register?", destination: URL(string:"https://www.thecivicscenter.org/why-register-and-vote")!)
                .font(.title)
                .foregroundStyle(.linearGradient(colors: [.red,.blue], startPoint: .leading, endPoint: .trailing))
              Spacer()
            }
            .padding(4)
            .padding(.horizontal, 20)
            .background {
              RoundedRectangle(cornerRadius: 25.0)
                .fill(Color.clear)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
            }
            HStack {
              Link("Resons to Register", destination: URL(string:"https://www.mentoring.org/wp-content/uploads/2020/08/reasons-register-vote.pdf")!)
                .font(.title)
                .foregroundStyle(.linearGradient(colors: [.red,.blue], startPoint: .leading, endPoint: .trailing))
              Spacer()
            }
            .padding(4)
            .padding(.horizontal, 20)
            .background {
              RoundedRectangle(cornerRadius: 25.0)
                .fill(Color.clear)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
            }

          }
          .padding()
          .padding(.horizontal, 20)
          
          Button("Start Over") {
            model.status = .none
          }
          .buttonStyle(.borderedProminent)
          .foregroundStyle(.linearGradient(colors: [.red,.white,.blue], startPoint: .leading, endPoint: .trailing))
          .tint(.black)
          .font(.title)
          .padding(.top, 40)
          
          Spacer()
        }
        
      }
      
      if showInfo {
        FlipView(frontView: Text("How to Use").font(.title), backView: InfoView(showInfo: $showInfo)) // , showBack: $showInfo)
          .frame(width: infoSize - 10, height: infoSize)
          .background(.ultraThinMaterial)
          .clipShape(RoundedRectangle(cornerRadius: 25.0))
          .padding()
      }
      
    }
    .onChange(of: showInfo) { _,show in
      withAnimation(.easeInOut(duration: 1)) {
        infoSize = showInfo ? 400 : 20
      }
    }
    .sheet(isPresented: $isPresentingScanner) {
      //      CodeScannerView(codeTypes: [.qr]) { response in
      CodeScannerView(codeTypes: [.pdf417]) { response in
        if case let .success(result) = response {
          license = License(code: result.string)
          scannedCode = result.string
          print(license.dict)
          
          switch scanNum {
          case 0: model.status = .underage
          case 1:
            model.status = .scanned
            model.loadUrl(license: license)
          case 2: model.status = .inactive
          default: break
          }
          scanNum = (scanNum + 1) % 3

          /*
          if license.canVote {
            model.status = .inactive
//            model.status = .scanned
//            model.loadUrl(license: license)
          } else {
            model.status = .underage
          }
           */
          //          model.status = .scanned
          //          model.loadUrl(license: license)
          isPresentingScanner = false
        }
      }
    }
    .sheet(isPresented: $showRegister) {
      RegisterView(rVM: rmodel, license: license)
    }
  }
}

#Preview {
  ContentView()
}
#Preview {
  ContentView()
    .environment(\.locale, .init(identifier: "es"))
}
