//
//  DownloadedViewController.swift
//  Relisten
//
//  Created by Alec Gorge on 5/26/18.
//  Copyright © 2018 Alec Gorge. All rights reserved.
//

import UIKit

import Siesta
import AsyncDisplayKit

class DownloadedViewController: ShowListViewController<[CompleteShowInformation]>, UIViewControllerRestoration {
    public required init(artist: Artist) {
        super.init(artist: artist, tourSections: true)
        
        self.restorationIdentifier = "net.relisten.DownloadedViewController.\(artist.slug)"
        self.restorationClass = type(of: self)
        
        refreshOnAppear = true
        title = "Downloaded Shows"
        
        latestData = loadOffline()
        
        MyLibrary.shared.offline.sources(byArtist: artist).observeWithValue { [weak self] (os, changes) in
            guard let s = self else { return }
            
            let offlineSources = os.asCompleteShows()
            if !(offlineSources == s.latestData) {
                s.loadData(offlineSources)
            }
        }.dispose(to: &disposal)
    }
    
    public required init(useCache: Bool, refreshOnAppear: Bool, style: UITableView.Style = .plain) {
        fatalError("init(useCache:refreshOnAppear:) has not been implemented")
    }
    
    public required init(artist: SlimArtistWithFeatures, tourSections: Bool, enableSearch: Bool) {
        fatalError()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func extractShowsAndSource(forData data: [CompleteShowInformation]) -> [ShowWithSingleSource] {
        return data.map({ ShowWithSingleSource(show: $0.show, source: $0.source) })
    }
    
    func loadOffline() -> [CompleteShowInformation] {
        return MyLibrary.shared.offline.sources(byArtist: artist).asCompleteShows()
    }
    
    // This is silly. Texture can't figure out that our subclass implements this method due to some shenanigans with generics and the swift/obj-c bridge, so we have to do this.
    override public func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return super.tableNode(tableNode, nodeBlockForRowAt: indexPath)
    }
    
    //MARK: State Restoration
    static public func viewController(withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
        // Decode the artist object from the archive and init a new artist view controller with it
        do {
            if let artistData = coder.decodeObject(forKey: ShowListViewController<YearWithShows>.CodingKeys.artist.rawValue) as? Data {
                let encodedArtist = try JSONDecoder().decode(Artist.self, from: artistData)
                let vc = MyLibraryViewController(artist: encodedArtist)
                return vc
            }
        } catch { }
        return nil
    }
}
