//
//  RegisterView.swift
//  Enroll
//
//  Created by Edward Arenberg on 11/8/24.
//

import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack(alignment: .top) {
      RoundedRectangle(cornerRadius: 5.0)
        .stroke(lineWidth: 3)
        .frame(width: 25, height: 25)
        .cornerRadius(5.0)
        .overlay {
          Image(systemName: configuration.isOn ? "checkmark" : "")
        }
      configuration.label
    }
    .onTapGesture {
      withAnimation(.spring()) {
        configuration.isOn.toggle()
      }
    }
  }
}
extension ToggleStyle where Self == CheckboxToggleStyle {
  static var checkmark: CheckboxToggleStyle { CheckboxToggleStyle() }
}


struct RegisterView: View {
  @ObservedObject var rVM : SwiftUIWebViewRegisterModel
  var license : License
  @State private var showRegister = false
  @State private var showRegisterInfo = false
  @State private var showInfo = false
  
  private let counties = [
    "Alameda", "Alpine", "Amador", "Butte", "Calaveras", "Colusa", "Contra Costa", "Del Norte",
    "El Dorado", "Fresno", "Glenn", "Humboldt", "Imperial", "Inyo", "Kern", "Kings", "Lake", "Lassen",
    "Los Angeles", "Madera", "Marin", "Mariposa", "Mendocino", "Merced", "Modoc", "Mono", "Monterey",
    "Napa", "Nevada", "Orange", "Placer", "Plumas", "Riverside", "Sacramento", "San Benito", "San Bernardino",
    "San Diego", "San Francisco", "San Joaquin", "San Luis Obispo", "San Mateo", "Santa Barbara", "Santa Clara",
    "Santa Cruz", "Shasta", "Sierra", "Siskiyou", "Solano", "Sonoma", "Stanislaus", "Sutter", "Tehama", "Trinity",
    "Tulare", "Tuolumne", "Ventura", "Yolo", "Yuba"
  ]
  private let parties = [
    ("AMERICAN INDEPENDENT  PARTY", 1),
    ("DEMOCRATIC  PARTY", 3),
    ("GREEN  PARTY", 4),
    ("LIBERTARIAN  PARTY", 5),
    ("PEACE AND FREEDOM  PARTY", 6),
    ("REPUBLICAN  PARTY", 7),
    ("OTHER  PARTY", 8)
  ]
  
  var body: some View {
    VStack {
      Text("Register to Vote")
        .font(.title)
      
      ScrollView {
        Toggle(isOn: $rVM.isCitizen) {
          Text("I am a U.S. citizen and resident of California.")
        }
        .toggleStyle(.checkmark)
        .font(.title2)
        .padding()
        
        HStack {
          HStack(spacing: 0) {
            Menu("Select County") {
              ForEach(counties, id: \.self) { county in
                Button(county) {
                  rVM.county = county
                  rVM.countyIndex = (counties.firstIndex(where: { $0 == county }) ?? -1) + 1
                }
              }
            }
            Image(systemName: "arrowtriangle.down").font(.body)
          }
          .padding(8)
          .background {
            RoundedRectangle(cornerRadius: 5.0)
              .stroke(lineWidth: 3)
          }
          .padding(.trailing, 10)
          
          Text(rVM.county)
          Spacer()
        }
        .font(.title2)
        .padding()
        
        VStack {
          Toggle(isOn: $rVM.hasSSN) {
            Text("I have a Social Security Number")
          }
          if rVM.hasSSN {
            HStack {
              Text("Last 4 digits:")
              Spacer()
              TextField("Digits", text: $rVM.ssn4)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .overlay(
                  RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.teal)
                )
            }
          }
        }
        .font(.title2)
        .padding()
        
        Toggle(isOn: $rVM.choosePartyPref) {
          HStack {
            Text("Do you want to choose a political party preference?")
              .padding(.trailing, 8)
              .overlay(alignment: .topTrailing) {
                Button("", systemImage: "info.circle") {
                  rVM.showNoPartyInfo.toggle()
                }
                .offset(x: 30, y: -10)
                .alert("If you do not choose a party, you may not be able to vote for some parties’ candidates at a primary election for U.S. President, or for a party’s central committee.", isPresented: $rVM.showNoPartyInfo) {
                }
              }
          }
        }
        .font(.title2)
        .padding()
        
        if rVM.choosePartyPref {
          HStack(alignment: .top) {
            HStack(spacing: 0) {
              Menu("Select Party") {
                ForEach(parties, id: \.self.0) { party in
                  Button(party.0) {
                    rVM.partyPref = party.0
                    rVM.partyPrefIndex = party.1 // parties.firstIndex(where: { $0 == party }) ?? 0
                  }
                }
              }
              Image(systemName: "arrowtriangle.down").font(.body)
            }
            .padding(8)
            .background {
              RoundedRectangle(cornerRadius: 5.0)
                .stroke(lineWidth: 3)
            }
            .padding(.trailing, 10)
            
            Text(rVM.partyPref)
            Spacer()
          }
          .font(.title2)
          .padding()
        }
        
        if rVM.partyPref == "OTHER  PARTY" {
          TextField("Enter Party Name", text: $rVM.otherPartyPref)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .overlay(
              RoundedRectangle(cornerRadius: 20)
                .stroke(Color.teal)
            )
            .font(.title2)
            .padding(.horizontal)
        }
        
        Toggle(isOn: $rVM.getStateVoteInfo) {
          Text("I want to get my state voter information guide by mail before each statewide election.")
            .padding(.horizontal, 8)
        }
        .font(.title2)
        .padding()
        
        Toggle(isOn: $rVM.getCountyVoteInfo) {
          Text("I want to get my county voter information guide by mail before each election.")
            .padding(.horizontal, 8)
        }
        .font(.title2)
        .padding()
        
      }
      
      Spacer()
      Button("Register") {
        showRegisterInfo.toggle()
      }
      .buttonStyle(.borderedProminent)
      .disabled(!rVM.canRegister)
      .foregroundStyle(.linearGradient(colors: [.red,.white,.blue], startPoint: .leading, endPoint: .trailing))
      .tint(.black)
      .font(.title)
      .padding(.bottom)
    }
    .alert("You will be presented with the official California Voter Registration form. Review the pre-filled information and make any changes as desired.", isPresented: $showRegisterInfo) {
      Button("Cancel", role: .cancel) { }
      Button("Continue") {
        rVM.step = 0
        rVM.license = license
        rVM.loadUrl(license: license)
        showRegister.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
          showInfo = true
        }
      }
    }
    .sheet(isPresented: $showRegister) {
      ZStack {
        SwiftUIWebView(webView: rVM.webView)
          .alert("", isPresented: $showInfo, actions: { }, message: {
            Text("Review the following forms. Most of the required information will be pre-filled.\n Make any changes as desired.")
          })
        //        .alert("Entries with a * are required", isPresented: .constant(true)) { }
        if rVM.processing {
          VStack {
            Text("Processing...")
            ProgressView()
          }
          .padding()
          .background {
            RoundedRectangle(cornerRadius: 20)
              .fill(.ultraThinMaterial)
          }
        }
      }
    }
  }
}

