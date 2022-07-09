
// void onNewCameraSelected(CameraDescription cameraDescription) async {
//   final previousCameraController = controller;
//   // Instantiating the camera controller
//   final CameraController cameraController = CameraController(
//     cameraDescription,
//     ResolutionPreset.high,
//     imageFormatGroup: ImageFormatGroup.jpeg,
//   );
//
//   // Dispose the previous controller
//   await previousCameraController.dispose();
//
//   // Replace with the new controller
//   if (mounted) {
//     setState(() {
//       controller = cameraController;
//     });
//   }
//
//   // Update UI if controller updated
//   cameraController.addListener(() {
//     if (mounted) setState(() {});
//   });
//
//   // Initialize controller
//   try {
//     await cameraController.initialize();
//   } on CameraException catch (e) {
//     logger.e('Error initializing camera:', e);
//   }
//
//   // Update the Boolean
//   if (mounted) {
//     setState(() {
//       _isCameraInitialized = controller.value.isInitialized;
//     });
//   }
// }



// WidgetsBinding.instance.addObserver(this);

// controller = CameraController(_cameras[0], ResolutionPreset.max);
// controller.initialize().then((_) {
//   if (!mounted) {
//     return;
//   }
//
//   setState(() {onNewCameraSelected(_cameras[0]);});
// }).catchError((Object e) {
//   if (e is CameraException) {
//     switch (e.code) {
//       case 'CameraAccessDenied':
//         logger.w('User denied camera access.');
//         controller.initialize().then((_) {
//           if (!mounted) {
//             return;
//           }
//           setState(() {});
//         }).catchError((Object e) {
//           if (e is CameraException) {
//             switch (e.code) {
//               case 'CameraAccessDenied':
//                 logger.i('User denied camera access.');
//                 break;
//               default:
//                 logger.i('Handle other errors.');
//                 break;
//             }
//           }
//         });
//         break;
//       default:
//         logger.i('Handle other errors.');
//         break;
//     }
//   }
// });
// }
