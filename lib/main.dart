import 'package:camera/camera.dart';
import 'package:camera_application/app.dart';
import 'package:flutter/material.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(Camera(cameras: cameras),);
}

class Camera extends StatelessWidget {
  final List<CameraDescription> cameras;
  const Camera({super.key,required this.cameras});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraApp(cameras: cameras,),);
  }
}
