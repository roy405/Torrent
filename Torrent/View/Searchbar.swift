//
//  Searchbar.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    @Binding var isEditing: Bool
    var placeholder: String

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, isEditing: $isEditing)
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        @Binding var isEditing: Bool

        init(text: Binding<String>, isEditing: Binding<Bool>) {
            _text = text
            _isEditing = isEditing
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            print("Search bar text changed to: \(searchText)")
            text = searchText
        }

        func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
            print("Search bar should begin editing.")
            isEditing = true
            return true
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            print("Search bar cancel button clicked.")
            isEditing = false
            searchBar.resignFirstResponder()
        }
    }
}

