import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sociopost/_screens/_cloudAssets.dart';
import 'package:sociopost/_screens/_editor.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{

  AnimationController _animationController;
  final picker = ImagePicker();


  @override
  void initState() {
    // TODO: implement initState
    _askPermissions();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000)
    );
    Timer(Duration(milliseconds: 300),()=>_animationController.forward());
    super.initState();
  }

  _askPermissions() async {
    var status = await Permission.storage.status;
    if (status.isUndetermined || status.isDenied) {
      await Permission.storage.request();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image.asset(
            "_assets/back-home.jpg",
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
          ),
          Positioned(
            top: 50.0,
            right: 0,
            left: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0,0.5),
                    end: Offset.zero
                  ).animate(_animationController),
                  child: FadeTransition(
                    opacity: _animationController,
                    child: Container(
                        width: 140.0,
                        margin: EdgeInsets.only(
                          top: 60.0
                        ),
                        child: Image.asset("_assets/logo.png")
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(vertical: 30.0,horizontal: 10.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withAlpha(150),
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Text(
                    "اپنی پسند کی تصویر کا انتخاب کریں ، اپنا مواد شامل کریں اور ایک ٹیپ کے ساتھ اپنے سوشل میڈیا سرکل میں شئیر کریں",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "urdu",
                      fontSize: 19.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 100,
            child: Column(
              children: [
                OnlineAssetsButton(),
                SizedBox(height: 10.0,),
                pickFromCameraButton(),
                SizedBox(height: 10.0,),
                pickFromGalleryButton()
              ],
            ),
          ),
          Positioned(
            bottom: 20.0,
            left: 20.0,
            child: IconButton(
              color: Colors.pink,
              icon: Icon(Icons.help_outline_outlined,color:Colors.white,size: 32,),
              onPressed: () => showModalBottomSheet(
                backgroundColor: Colors.white.withOpacity(0.3),
                isDismissible: true,
                context: context,
                builder: (_) => Container(
                  child: Padding(
                    padding: EdgeInsets.all(60.0),
                    child: Text(
                        "For issue or improvement Suggestion\n"+
                            "Make query for developers\n"+
                            "support@hellodearcode.com",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            color: Colors.white,
                        )
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: IconButton(
              color: Colors.pink,
              icon: Icon(Icons.warning_amber_outlined,color:Colors.white,size: 32,),
              onPressed: () => showModalBottomSheet(
                backgroundColor: Colors.redAccent.withOpacity(0.4),
                isDismissible: true,
                context: context,
                builder: (_) => Container(
                  child: Padding(
                    padding: EdgeInsets.all(60.0),
                    child: Text(
                        "NOTE: You must need to configure Urdu Layout Keyboard as you default keypad for writing urdu",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            color: Colors.white,
                        )
                    ),
                  ),
                ),
              ),
            )
          )
        ],
      ),
    );
  }

  // --online Assets Button
  Widget OnlineAssetsButton() => FlatButton(
    minWidth: 140.0,
    padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
    child: Row(
      children: [
        Icon(Icons.cloud_download_outlined,color: Colors.white),
        SizedBox(width: 10.0,),
        Text("آن لائن تصاویر",style: TextStyle(color: Colors.white,fontSize: 16.0,fontFamily: "urdu"),)
      ],
    ),
    color: Colors.purple.withOpacity(0.6),
    onPressed: () => Navigator.push(context, MaterialPageRoute(
        builder: (context) => CloudAssets()
    )),
  );

  // -- Camera Picker
  Widget pickFromCameraButton() => FlatButton(
    minWidth: 140.0,
    padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
    child: Row(
      children: [
        Icon(Icons.camera,color: Colors.white),
        SizedBox(width: 10.0,),
        Text("کیمرہ",style: TextStyle(color: Colors.white,fontSize: 16.0,fontFamily: "urdu",),)
      ],
    ),
    color: Colors.purple.withOpacity(0.6),
    onPressed: () => getImageFromCamera(),
  );


  // -- Camera Picker
  Widget pickFromGalleryButton() => FlatButton(
    minWidth: 140.0,
    padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
    child: Row(
      children: [
        Icon(Icons.photo,color: Colors.white),
        SizedBox(width: 10.0,),
        Text("گیلری",style: TextStyle(color: Colors.white,fontSize: 16.0,fontFamily: "urdu",),)
      ],
    ),
    color: Colors.purple.withOpacity(0.5),
    onPressed: () => getImageFromGallery(),
  );

  getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {

      File tempCropped = await ImageCropper.cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: "Crop Image",
            toolbarWidgetColor: Colors.white,
            cropGridColor: Theme.of(context).primaryColor,
            cropFrameColor: Theme.of(context).primaryColor,
            toolbarColor: Theme.of(context).primaryColor,
            statusBarColor: Theme.of(context).primaryColor.withOpacity(0.7),
            activeControlsWidgetColor: Theme.of(context).primaryColor,
          )
      );

      // -- Push Editor
      if (tempCropped != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Editor(
                  file_image: tempCropped,
                )
            )
        );
      }
    } else {
      print('No image selected.');
    }
  }


  getImageFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File TempCropped = await ImageCropper.cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: "Crop Image",
            toolbarWidgetColor: Colors.white,
            cropGridColor: Theme.of(context).primaryColor,
            cropFrameColor: Theme.of(context).primaryColor,
            toolbarColor: Theme.of(context).primaryColor,
            statusBarColor: Theme.of(context).primaryColor.withOpacity(0.7),
            activeControlsWidgetColor: Theme.of(context).primaryColor,
          )
      );

      // -- Push Editor
      if (TempCropped != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Editor(
                  file_image: TempCropped,
                )
            )
        );
      }
    } else {
      print('No image selected.');
    }
  }
}
