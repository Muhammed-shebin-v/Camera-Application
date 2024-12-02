import 'dart:io';

import 'package:camera/camera.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:media_scanner/media_scanner.dart';

class CameraApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraApp({super.key,required this.cameras});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
    late CameraController cameraController;
    late Future<void>cameraValue;
    List<File>imageList=[];
    bool isFlashon=false;
    bool isRearcamera=false;

    Future<File> saveImage(XFile image) async
{
  final downloadPatch =await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
  final fileName='${DateTime.now().millisecondsSinceEpoch}.png';
  final file=File('$downloadPatch/$fileName');

  try{
    await file.writeAsBytes(await image.readAsBytes());
  }catch(_){}
  return file;
}
    void takePicture() async {
      XFile? image;
      if(cameraController.value.isTakingPicture || !cameraController.value.isInitialized){
        return;
      }
      if(isFlashon==false){
        await cameraController.setFlashMode(FlashMode.off);
      }else{
        await cameraController.setFlashMode(FlashMode.torch);
      }
      image = await cameraController.takePicture();
      if(cameraController.value.flashMode==FlashMode.torch){
        setState(() {
          cameraController.setFlashMode(FlashMode.off);
        });
      }
      final file=await saveImage(image);
      setState(() {
        imageList.add(file);
      });
      MediaScanner.loadMedia(path: file.path);
    }
  void startCamera(int camera) {
  if (camera < 0 || camera >= widget.cameras.length) {
    print('Error: Camera index is out of bounds');
    return;
  }
  try {
    cameraController = CameraController(
      widget.cameras[camera],
      ResolutionPreset.high,
      enableAudio: false,
    );
    cameraValue = cameraController.initialize();
  } catch (e) {
    print('Error initializing camera: $e');
  }
}


    @override
  void initState() {
    startCamera(0);
    super.initState();
  }
    @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed:takePicture,foregroundColor: Colors.black,
        child: const Icon(Icons.camera_alt,size: 40,),),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          FutureBuilder(future: cameraValue, builder: (context,snapshot){
            if(snapshot.connectionState==ConnectionState.done){
              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: 100,
                    child: CameraPreview(cameraController),
                    ),
                ),

              );
            }else{
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 5,top: 10),
                child:Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          isFlashon=!isFlashon;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle
                          ),
                          child: Padding(padding: const EdgeInsets.all(10),
                          child:isFlashon?
                          const Icon(Icons.flash_on,color: Colors.white,size: 30,):
                          const Icon(Icons.flash_off,color: Colors.white,size: 30,),),
                        ),
                      ),
                    ),
                    const Gap(10),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          isRearcamera=!isRearcamera;
                        });
                        isRearcamera?startCamera(0):startCamera(1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle
                          ),
                          child: Padding(padding: const EdgeInsets.all(10),
                          child:isRearcamera?
                          const Icon(Icons.camera_rear,color: Colors.white,size: 30,):
                          const Icon(Icons.camera_front,color: Colors.white,size: 30,),),
                        ),
                      ),
                    ),
                    const Gap(10),
                  ],
                )
                ),
            ),

            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(padding: const EdgeInsets.only(left: 7,bottom: 75),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: imageList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context,index){
                        return Padding(padding: const EdgeInsets.all(2),
                        child: ClipRRect(borderRadius: BorderRadius.circular(10),
                        child: Image(
                          height: 100,
                          width: 100,
                          opacity: const AlwaysStoppedAnimation(07),
                          image: FileImage(File(imageList[index].path),
                          ),
                          fit: BoxFit.cover,

                        ),),) ;
                        

                      }),
                    ),),
                    

                  )

                ],
              ),

            )
        ],
      ),

    );
  }
}