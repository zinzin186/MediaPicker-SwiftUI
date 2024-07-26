//
//  Created by Alex.M on 27.05.2022.
//

import Foundation
import Photos

public struct Album: Identifiable {
    public let id: String
    public let title: String?
    public let preview: PHAsset?
    public let imageCount: Int
}

extension Album {
    public func getThumbnailURL() async -> URL? {
        await preview?.getThumbnailURL()
    }
}

struct AlbumModel {
    let preview: AssetMediaModel?
    let source: PHAssetCollection
}

extension AlbumModel: Identifiable {
    public var id: String {
        source.localIdentifier
    }

    public var title: String? {
        source.localizedTitle
    }
    
    func getAssets() -> PHFetchResult<PHAsset> {
        let photosOptions = PHFetchOptions()
        photosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        photosOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        return PHAsset.fetchAssets(in: source, options: photosOptions)
      }

}

extension AlbumModel: Equatable {}

extension AlbumModel {
    func toAlbum() -> Album {
        Album(id: id, title: title, preview: preview?.asset, imageCount: self.getAssets().count)
    }
}
