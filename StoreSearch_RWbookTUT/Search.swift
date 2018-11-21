//
//  Search.swift
//  StoreSearch_RWbookTUT
//
//  Created by Emin Roblack on 11/21/18.
//  Copyright © 2018 emiN Roblack. All rights reserved.
//

import Foundation

typealias SearchComplete = (Bool) -> Void

class Search {
  
  var searchResults: [SearchResult] = []
  var hasSearched = false
  var isLoading = false
  
  private var dataTask: URLSessionDataTask? = nil

  
  //MARK:- Search Logic
  func performSearch(for text: String, category: Int,
                     completion: @escaping SearchComplete) {
    
  if !text.isEmpty {
  dataTask?.cancel()
  
  isLoading = true
  hasSearched = true
  searchResults = []
  
  let url = iTunesURL(searchText: text, category: category)
  
  let session = URLSession.shared
  dataTask = session.dataTask(with: url, completionHandler: {
  data, response, error in
    var success = false
  // Was the search cancelled?
  if let error = error as NSError?, error.code == -999 {
  return
  }
  
  if let httpResponse = response as? HTTPURLResponse,
  httpResponse.statusCode == 200, let data = data {
  self.searchResults = self.parse(data: data)
  self.searchResults.sort(by: <)
  
  print("Success!")
  self.isLoading = false
  success = true
  }
  
  
    if !success {
      self.hasSearched = false
      self.isLoading = false
    }
    
    DispatchQueue.main.async {
      completion(success)
    }
  })
    dataTask?.resume()
    }
  }
  //------------------------------------------------------------------------
  
  
  
  //MARK:- Helper methods - PARSE!
  //-------------------------------------------------------------
  private func iTunesURL(searchText: String, category: Int) -> URL {
    
    let kind: String
    switch category {
    case 1: kind = "musicTrack"
    case 2: kind = "software"
    case 3: kind = "ebook"
    default: kind = ""
    }
    
    let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    let urlString = String(format: "https://itunes.apple.com/search?term=%@&limin=200&entity=%@", encodedText, kind)
    let url = URL(string: urlString)
    return url!
  }

  private func parse(data: Data) -> [SearchResult] {
    do {
      let decoder = JSONDecoder()
      let result = try decoder.decode(ResultArray.self, from: data)
      return result.results
    } catch {
      print("JSON Error: \(error)")
      return []
    }
  }
  //------------------------------------------------------------------------
  
  
  
}
