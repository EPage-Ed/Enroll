//
//  License.swift
//  Enroll
//
//  Created by Edward Arenberg on 11/8/24.
//

import Foundation

enum LicenseStatus {
  case none
  case scanning
  case scanned
  case underage
  case verifying
  case active
  case moreinfo
  case inactive
}

struct License {
  let dict: [String: String]
  var fname = ""
  var mname = ""
  var lname = ""
  var dob = Date()
  var diss = Date()
  var dexp = Date()
  var gender = ""
  var eyeColor = ""
  var hairColor = ""
  var height = 0.0
  var street = ""
  var city = ""
  var state = ""
  var zip = ""
  var country = ""
  var ansi = ""
  var idNum = ""
  var docDisc = ""
  var fnameTrunc: Bool? = nil
  var mnameTrunc: Bool? = nil
  var lnameTrunc: Bool? = nil
  
  var ageYears : Int {
    let age = Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 0
    return age
  }
  var canVote : Bool {
    ageYears >= 18
  }
  
  init(code: String) {
    let df = DateFormatter()
    df.dateFormat = "MMddyyyy"
    
    let lines = code.components(separatedBy: .newlines)
    let d = lines.reduce(into: [String:String]()) {
      if $1.count > 3 {
        if $1.hasPrefix("ANSI") {
          $0["ANSI"] = String($1.suffix(from: $1.index($1.startIndex, offsetBy: 4)))
        } else {
          $0[String($1.prefix(3))] = String($1.suffix(from: $1.index($1.startIndex, offsetBy: 3)))
        }
      }
    }
    dict = d
    fname = d["DAC"] ?? ""
    mname = d["DAD"] ?? ""
    lname = d["DCS"] ?? ""
    dob = df.date(from: (d["DBB"] ?? "")) ?? Date()
    diss = df.date(from: (d["DBD"] ?? "")) ?? Date()
    dexp = df.date(from: (d["DBA"] ?? "")) ?? Date()
    let g = (d["DBC"] ?? "")
    gender = g == "1" ? "M" : g == "2" ? "F" : ""
    street = d["DAG"] ?? ""
    city = d["DAI"] ?? ""
    state = d["DAJ"] ?? ""
    zip = d["DAK"] ?? ""
    country = d["DCG"] ?? ""
    ansi = d["ANSI"] ?? ""
    docDisc = d["DCF"] ?? ""
    idNum = d["DAQ"] ?? ""
    if idNum.count == 0 {
      let a = ansi.components(separatedBy: "DAQ")
      if a.count > 1 {
        idNum = a.last ?? ""
      }
    }
    
    print(fname,mname,lname,dob,diss,dexp,gender,street,city,state,zip,country,idNum,docDisc)
  }
  
}
