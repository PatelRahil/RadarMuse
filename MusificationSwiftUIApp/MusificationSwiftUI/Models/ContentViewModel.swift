//
//  ContentViewModel.swift
//  MusificationSwiftUI
//
//  Created by Rahil Patel on 6/15/19.
//  Copyright © 2019 Rahil. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class ContentViewModel: ObservableObject {
    var didChange = PassthroughSubject<ContentViewModel, Never>()
    @Published var trackedArtists: [Artist] = []
    @Published var genres: [Genre] = []
    @Published var searchedArtists: [Artist] = []
    @Published var displayedAlbums: [Album] = []
    @Published var displayedSongs: [Song] = []
    @Published var selectedArtist: Artist = Artist()
    @Published var recentSongs: [Song] = []
    @Published var recentDate: String = ""
    @Published var presentPushArtist: Bool = false
    @Published var isLoading: Bool = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(onRecievePushArtist), name: .didRecievePushArtist, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onLoading), name: .didRecieveLoadingSignal, object: nil)

    }
    
    func fetchTrackedArtists() {
        
    }
    func fetchGenres() {
        MusicRequest.getGenres(success: { genres in
            DispatchQueue.main.async { self.genres = genres }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func searchArtists(with prefix: String, limit: Int = defaultSongItemsLimit) {
        MusicRequest.getArtistsStarting(with: prefix, limit: limit, success: { artists in
            DispatchQueue.main.async {
                self.searchedArtists = artists
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func fetchAlbums(for artist: Artist) {
        artist.downloadAlbums(success: { albums in
            DispatchQueue.main.async {
                self.displayedAlbums = albums
            }
        }) { error in
            print(error.localizedDescription)
        }
    }
    func fetchSongs(for genre: Genre, limit: Int) {
        MusicRequest.getSongs(genreID: genre.id, limit: limit, success: { songs in
            DispatchQueue.main.async {
                self.displayedSongs = songs
            }
        }) { error in
            print(error.localizedDescription)
        }
    }
    func fetchArtist(named: String, success: @escaping () -> Void) {
        MusicRequest.getArtist(artistName: named, success: { artist in
            DispatchQueue.main.async {
                self.selectedArtist = artist
            }
            success()
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    func getRecentSongs(for artist: Artist) {
        let req = FirebaseRequest()
        req.getRecentSongs(for: artist.id) { (songs, date) in
            DispatchQueue.main.async {
                self.recentDate = date
                self.recentSongs = songs
            }
        }
    }
    func resetSelectedArtist() {
        self.selectedArtist = Artist()
        self.recentSongs = []
        self.recentDate = ""
        self.displayedAlbums = []
    }
    
    @objc func onRecievePushArtist(_ notification: Notification) {
        guard let artist = notification.object as? Artist else { return }
        self.selectedArtist = artist
        self.fetchAlbums(for: artist)
        self.getRecentSongs(for: artist)
        self.presentPushArtist = true
    }
    @objc func onLoading(_ notification: Notification) {
        self.isLoading = true
    }
}
