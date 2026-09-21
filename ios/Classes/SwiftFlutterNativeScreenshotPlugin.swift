import Flutter
import UIKit

public class SwiftFlutterNativeScreenshotPlugin: NSObject, FlutterPlugin {
  weak var registrar: FlutterPluginRegistrar?
      var result :FlutterResult!
      var screenshotPath :String!

      init(registrar: FlutterPluginRegistrar) {
          self.registrar = registrar

          super.init()
      } // init()

      public static func register(with registrar: FlutterPluginRegistrar) {
          let channel = FlutterMethodChannel(name: "flutter_native_screenshot", binaryMessenger: registrar.messenger())

          let instance = SwiftFlutterNativeScreenshotPlugin(
              registrar: registrar
          ) // let instance

          registrar.addMethodCallDelegate(instance, channel: channel)
      } // register()

      public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
          if call.method != "takeScreenshot" {
              result(FlutterMethodNotImplemented)

              return
          } // if

          // `registrar.viewController` is the officially supported accessor for the
          // root FlutterViewController under both classic and UIScene lifecycles; see
          // https://docs.flutter.dev/release/breaking-changes/uiscenedelegate. It has
          // to be read here (call time), not cached at `register(with:)` time: under
          // UIScene, registration runs from `application(_:didFinishLaunchingWithOptions:)`,
          // which fires before any scene has connected, so no view controller exists yet.
          guard let controller = registrar?.viewController else {
              result(nil)

              return
          } // guard no root FlutterViewController

          self.result = result

          // FIX: add posibility to choose if gallery or some path
          takeScreenshot(view: controller.view)
      } // handle()

      func getScreenshotName() -> String {
          let format = DateFormatter()
          format.dateFormat = "yyyymmddHHmmss"

          let fname :String = "native_screenshot-\(format.string(from: Date())).png"

          return fname
      } // getScreenshotName()

      func getScreenshotPath() -> URL? {
          let paths :[URL] = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

          guard let dir = paths.first else {
              return nil
          } // guard

          return dir.appendingPathComponent( getScreenshotName() )
      } // getScreenshotPath()

      func writeImageToDefaultPath(image: UIImage) -> String? {
          guard let imageData = image.pngData() else {
              return nil
          } // guard

          guard let path = getScreenshotPath() else {
              return nil
          } // guard

          guard let _ = try? imageData.write(to: path) else {
              return nil
          } // guard

          return path.path
      } // writeImageToDefaultPath()

      @objc
      func savedToGalleryDone(image: UIImage, error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
          if error == nil && self.screenshotPath != nil && !self.screenshotPath.isEmpty {
              result(self.screenshotPath)
          } else {
              result(nil)
          }
      } // savedToGalleryDone()

      func writeImageToGallery(image :UIImage) {
          UIImageWriteToSavedPhotosAlbum(
              image,
              self,
              #selector(savedToGalleryDone),
              nil
          ); // UIImageWriteToSavedPhotosAlbum()
      } // writeImageToGallery()

      func takeScreenshot(view: UIView, toImageGallery :Bool = true) {
          let scale :CGFloat = UIScreen.main.scale

          UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, scale)

          view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
          let optionalImage :UIImage? = UIGraphicsGetImageFromCurrentImageContext()
          UIGraphicsEndImageContext()

          guard let image = optionalImage else {
              result(nil)

              return
          } // guard no image

          guard let path = writeImageToDefaultPath(image: image) else {
              result(nil)

              return
          } // guard cannot write image

          self.screenshotPath = path

          writeImageToGallery(image: image)
      }
}
