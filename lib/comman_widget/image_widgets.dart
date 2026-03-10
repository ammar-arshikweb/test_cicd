import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class ImageWidgets {
  static void showImageDialog(BuildContext context, String imageUrl, List<String> imageUrls) {
    final initialIndex = imageUrls.indexOf(imageUrl); // Get the index of the current image
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: MColors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          color: MColors.transparent,
          child: Center(
            child: PageView.builder(
              itemCount: imageUrls.length,
              controller: PageController(initialPage: initialIndex), // Start at the selected image
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => GlobalTap.safeTap(() {
                    Navigator.of(context).pop(); // Close dialog on tap
                  }),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 50,
                        right: 20,
                        child: InkWell(
                          onTap: () => GlobalTap.safeTap(() => Navigator.of(context).pop()),
                          child: Icon(Icons.close, color: MColors.white, size: 30),
                        ),
                      ),
                      InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: imageUrls[index],
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) {
                              return const Icon(Icons.error, color: MColors.white, size: 50);
                            },
                            imageBuilder:
                                (context, imageProvider) => Container(decoration: BoxDecoration(image: DecorationImage(image: imageProvider, fit: BoxFit.contain))),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(scale: animation, child: child);
      },
    );
  }

  static void showFileImageDialog(BuildContext context, String imagePath, List<String> imagePaths) {
    final initialIndex = imagePaths.indexOf(imagePath); // Get the index of the current image
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: MColors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: PageView.builder(
            itemCount: imagePaths.length,
            controller: PageController(initialPage: initialIndex),
            // Start at the selected image
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => GlobalTap.safeTap(() => Navigator.of(context).pop()), // Close dialog on tap
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.file(
                      File(imagePaths[index]),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, color: MColors.white, size: 50);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(scale: animation, child: child);
      },
    );
  }

  /// Optimized: Compress large images first, then add timestamp (much faster for 15-16MB images)
  static Future<XFile?> addTimestampFast(XFile imageFile) async {
    const int maxSizeInBytes = 1024 * 1024; // 1MB
    
    File file = File(imageFile.path);
    int fileSizeInBytes = await file.length();
    
    // Read and decode image once
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) return null;
    
    // Step 1: Only resize if extremely large (>5x target size) - less aggressive
    if (fileSizeInBytes > maxSizeInBytes * 5) {
      double compressionRatio = maxSizeInBytes / fileSizeInBytes;
      double scaleFactor = (compressionRatio * 2.0).clamp(0.6, 1.0); // Higher scale factor
      int newWidth = (image.width * scaleFactor).round();
      int newHeight = (image.height * scaleFactor).round();
      image = img.copyResize(image, width: newWidth, height: newHeight);
    }
    
    // Step 2: Add timestamp with proper positioning
    final timestamp = DateFormat(Constant.yyyy_MM_dd_HH_mm_ss).format(TimeUtils.getCurrentDateTime());
    
    // Calculate proper text dimensions based on font size
    const int charWidth = 28; // More accurate character width
    const int padding = 30;
    const int textPadding = 10;
    
    final textWidth = timestamp.length * charWidth;
    final textHeight = 55; // Proper height for arial48
    final xPos = (image.width - textWidth - padding).clamp(0, image.width - textWidth - 10);
    final yPos = (image.height - textHeight - padding).clamp(0, image.height - textHeight - 10);
    
    // Draw background rectangle with more padding
    img.fillRect(
      image,
      x1: xPos - textPadding,
      y1: yPos - textPadding,
      x2: xPos + textWidth - 20,
      y2: yPos + textHeight - 8,
      color: img.ColorRgba8(0, 0, 0, 255), // Slightly more opaque
    );
    
    // Draw timestamp text
    img.drawString(
      image,
      timestamp,
      font: img.arial48,
      x: xPos,
      y: yPos,
      color: img.ColorRgba8(255, 255, 255, 255),
    );
    
    // Step 3: Use higher quality settings to maintain image quality
    int quality = 92; // Start with high quality
    Uint8List encodedBytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
    
    // Step 4: Only reduce quality if significantly over size
    if (encodedBytes.length > maxSizeInBytes * 1.2) {
      quality = 88;
      encodedBytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
      
      if (encodedBytes.length > maxSizeInBytes * 1.15) {
        quality = 85;
        encodedBytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
      }
    }
    
    // Save final image
    final tempDir = await getTemporaryDirectory();
    final random = Random().nextInt(999999);
    final newFilePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_${random}_ts.jpg';
    final newFile = File(newFilePath);
    await newFile.writeAsBytes(encodedBytes);
    
    Log.e('Image processed: ${fileSizeInBytes} bytes → ${encodedBytes.length} bytes (Quality: $quality)');
    
    return XFile(newFile.path);
  }

}

class ShimmerPlaceholder extends StatefulWidget {
  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0, -0.3),
              end: Alignment(1.0, 0.3),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
