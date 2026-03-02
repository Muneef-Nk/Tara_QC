// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:tara_qc/app/app_routes.dart';
// import '../../../app/routes/app_router.dart';
// import '../../../app/routes/app_routes.dart';

// class CameraScreen extends StatefulWidget {
//   final List<CameraDescription> cameras;

//   const CameraScreen({super.key, required this.cameras});

//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   bool _isFlashOn = false;
//   bool _isRecording = false;
//   CameraLensDirection _currentLens = CameraLensDirection.back;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   void _initializeCamera() {
//     final camera = widget.cameras.firstWhere(
//       (camera) => camera.lensDirection == _currentLens,
//       orElse: () => widget.cameras.first,
//     );

//     _controller = CameraController(camera, ResolutionPreset.high, enableAudio: false);

//     _initializeControllerFuture = _controller.initialize();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _takePicture() async {
//     try {
//       await _initializeControllerFuture;

//       final path = join(
//         (await getTemporaryDirectory()).path,
//         '${DateTime.now().millisecondsSinceEpoch}.jpg',
//       );

//       await _controller.takePicture().then((xfile) async {
//         // Simulate scan result
//         final resultData = {
//           'type': 'document',
//           'confidence': 0.95,
//           'text': 'Sample scanned document text',
//           'date': DateTime.now().toString(),
//         };

//         // Navigate to result screen
//         AppRouter.navigateTo(
//           AppRoutes.scanResult,
//           arguments: {'imagePath': xfile.path, 'resultData': resultData},
//         );
//       });
//     } catch (e) {
//       print('Error taking picture: $e');
//     }
//   }

//   Future<void> _switchCamera() async {
//     if (widget.cameras.length < 2) return;

//     setState(() {
//       _currentLens = _currentLens == CameraLensDirection.back
//           ? CameraLensDirection.front
//           : CameraLensDirection.back;
//     });

//     await _controller.dispose();
//     _initializeCamera();
//     setState(() {});
//   }

//   Future<void> _toggleFlash() async {
//     if (!_controller.value.isInitialized) return;

//     setState(() {
//       _isFlashOn = !_isFlashOn;
//     });

//     await _controller.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Camera'),
//         leading: IconButton(icon: const Icon(Icons.close), onPressed: () => AppRouter.goBack()),
//         actions: [
//           IconButton(
//             icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
//             onPressed: _toggleFlash,
//           ),
//         ],
//       ),
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return Stack(
//               children: [
//                 CameraPreview(_controller),
//                 Positioned(
//                   top: 20,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.5),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Text('Aim at document', style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 100,
//                   left: 0,
//                   right: 0,
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 250,
//                         height: 250,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'Position document within frame',
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.photo_library, size: 32),
//               onPressed: () => AppRouter.navigateTo(AppRoutes.gallery),
//               color: Colors.white,
//             ),
//             GestureDetector(
//               onTap: _takePicture,
//               child: Container(
//                 width: 70,
//                 height: 70,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 4),
//                 ),
//                 child: Container(
//                   margin: const EdgeInsets.all(8),
//                   decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
//                 ),
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.switch_camera, size: 32),
//               onPressed: _switchCamera,
//               color: Colors.white,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
