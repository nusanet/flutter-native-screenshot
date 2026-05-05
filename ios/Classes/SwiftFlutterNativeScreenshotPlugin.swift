import Flutter
import UIKit

public class SwiftFlutterNativeScreenshotPlugin: NSObject, FlutterPlugin {
  var controller :FlutterViewController!
      var messenger :FlutterBinaryMessenger
      var result :FlutterResult!
      var screenshotPath :String!

      init(controller: FlutterViewController, messenger: FlutterBinaryMessenger) {
          self.controller = controller
          self.messenger = messenger

          super.init()
      } // init()

      public static func register(with registrar: FlutterPluginRegistrar) {
          let channel = FlutterMethodChannel(name: "flutter_native_screenshot", binaryMessenger: registrar.messenger())

          let app = UIApplication.shared

          var controller: FlutterViewController?
          if #available(iOS 13.0, *) {
              controller = app.connectedScenes
                  .compactMap { $0 as? UIWindowScene }
                  .flatMap { $0.windows }
                  .first { $0.isKeyWindow }?
                  .rootViewController as? FlutterViewController
          }
          if controller == nil {
              controller = app.delegate?.window??.rootViewController as? FlutterViewController
          }

          guard let flutterController = controller else {
              return
          }

          let instance = SwiftFlutterNativeScreenshotPlugin(
              controller: flutterController,
              messenger: registrar.messenger()
          ) // let instance

          registrar.addMethodCallDelegate(instance, channel: channel)
      } // register()

      public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
          if call.method != "takeScreenshot" {
              result(FlutterMethodNotImplemented)

              return
          } // if

          self.result = result

          // FIX: add posibility to choose if gallery or some path
          takeScreenshot(view: controller.view)
      } // handle()

      func getScreenshotName() -> String {
          let format = DateFormatter()
          format.dateFormat = "yyyyMMddHHmmss"

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
