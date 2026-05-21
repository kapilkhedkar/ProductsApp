//
//  ImageLoader.swift
//  ProductsApp
//
//  Created by Kapil Khedkar on 21/05/26.
//

import UIKit

// MARK: - ImageLoader
// Thread-safe lazy image loader backed by an in-memory NSCache.
// Each cell calls load(url:token:completion:) and cancels via the returned token
// when the cell is reused – preventing stale image flicker.

final class ImageLoader {

    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()
    private var activeTasks: [URL: URLSessionDataTask] = [:]
    private let lock = NSLock()

    private init() {
        cache.countLimit  = 100          // max 100 images in memory
        cache.totalCostLimit = 50 * 1024 * 1024  // ~50 MB
    }
    
    @discardableResult
    func load(url: URL, completion: @escaping (UIImage?) -> Void) -> UUID {
        let token = UUID()

        if let cached = cache.object(forKey: url as NSURL) {
            completion(cached)
            return token
        }

        lock.lock()
        if activeTasks[url] != nil {
            lock.unlock()
            return token
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self.cache.setObject(image, forKey: url as NSURL,
                                 cost: data.count)
            self.lock.lock()
            self.activeTasks.removeValue(forKey: url)
            self.lock.unlock()
            DispatchQueue.main.async { completion(image) }
        }

        activeTasks[url] = task
        lock.unlock()
        task.resume()

        return token
    }

    func cancel(url: URL) {
        lock.lock()
        activeTasks[url]?.cancel()
        activeTasks.removeValue(forKey: url)
        lock.unlock()
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}
