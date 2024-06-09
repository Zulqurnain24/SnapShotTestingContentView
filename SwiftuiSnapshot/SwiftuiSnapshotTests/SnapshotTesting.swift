//
//  SnapshotTesting.swift
//  SwiftuiSnapshotTests
//
//  Created by Mohammad Zulqurnain on 09/06/2024.
//

import SwiftUI

struct SnapshotTesting {

    enum SnapshotError: Error {
        case couldNotGenerateImage
    }

    static func isTestPassed<V: View>(view: V, mseTolerance: CGFloat) throws -> Bool {
        // Set up the hosting controller
        let hostingController = UIHostingController(rootView: view)

        // Define the frame and size for the view
        hostingController.view.bounds = UIScreen.main.bounds
        hostingController.view.setNeedsLayout()

        // Render the view hierarchy into an image
        let renderer = UIGraphicsImageRenderer(size: hostingController.view.bounds.size)
        let screenshot = renderer.image { _ in
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }

        // Use the captured screenshot
        let image = UIImageView(image: screenshot).image

        // Path to the snapshot directory in the application's root directory
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let snapshotDirectoryURL = documentsURL.appendingPathComponent("\(V.self).png")

        // Create the snapshot directory if it doesn't exist
        try? FileManager.default.createDirectory(at: snapshotDirectoryURL, withIntermediateDirectories: true, attributes: nil)

        // Path to the reference image within the snapshot directory
        let referenceImageURL = snapshotDirectoryURL.appendingPathComponent("\(V.self).png")

        if !FileManager.default.fileExists(atPath: referenceImageURL.path) {
            // If reference image doesn't exist, save the rendered image as the reference image
            try image?.pngData()?.write(to: referenceImageURL)
            try isTestPassed(view: view, mseTolerance: mseTolerance)
        }

        // Load the reference image
        guard let referenceImage = UIImage(contentsOfFile: referenceImageURL.path) else {
            return false
        }

        guard let image = image else { throw SnapshotError.couldNotGenerateImage  }
        let mse: CGFloat = calculateMeanSquaredError(image: image, referenceImage: referenceImage)

        return  mse <= mseTolerance
    }

    // Calculate Mean Squared Error (MSE) between two images
    static func calculateMeanSquaredError(image: UIImage, referenceImage: UIImage) -> CGFloat {
        guard let imageData = image.pngData(), let referenceImageData = referenceImage.pngData() else {
            return CGFloat.greatestFiniteMagnitude
        }

        let imagePixels = imageData.withUnsafeBytes { Data($0) }
        let referenceImagePixels = referenceImageData.withUnsafeBytes { Data($0) }

        guard imagePixels.count == referenceImagePixels.count else {
            return CGFloat.greatestFiniteMagnitude
        }

        var sum: CGFloat = 0.0
        for (index, pixel) in imagePixels.enumerated() {
            let referencePixel = referenceImagePixels[index]
            sum += CGFloat(pixel) - CGFloat(referencePixel)
        }

        let mse = sum / CGFloat(imagePixels.count)
        return mse
    }
}

