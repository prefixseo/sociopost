import 'dart:io';
import 'dart:typed_data';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:toast/toast.dart';

class Editor extends StatefulWidget {

  File file_image;

  Editor({
   Key key,
    this.file_image
  }) : super(key: key);

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  Offset offset = Offset.zero;
  Offset creditsOffset = Offset.zero;
  TextEditingController _textInputController = TextEditingController();
  TextEditingController _creditsController = TextEditingController();
  GlobalKey _captureglobalKey = new GlobalKey();
  Uint8List imageInMemory;
  bool working = false;
  String creditsText = "INSTA | @cactus_writes";

  // -- Settings
  double _fontSize = 24.0;
  String _fontFamily = "";
  String _text = "";
  double _opacity = 0.5;
  TextDirection _stdtextDirection = TextDirection.rtl;

  Color pickerColor = Color(0xffffffff);
  Color currentColor = Color(0xffffffff);

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }
  @override
  void initState(){
    _creditsController.text = creditsText;
    creditsOffset = Offset(40,220);
  }

  // -- Open Color Picker
  openColorPicker() {
    showDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Got it'),
            onPressed: () {
              setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  // -- Show Text Input
  showTextInput() {
    showDialog(
      context: context,
      child: AlertDialog(
        title: const Text("Enter Multiline Text"),
        content: SingleChildScrollView(
            child: TextField(
              keyboardType: TextInputType.multiline,
              controller: _textInputController,
              maxLines: 5,
              textDirection: _stdtextDirection,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter Text on Image",
                  labelText: "Text On Image"
              ),
              style: TextStyle(
                  fontSize: 16.0
              ),
            )
        ),
        actions: [
          FlatButton(
            child: const Text('Done'),
            onPressed: () {
              setState(() => _text = _textInputController.text);
              Navigator.of(context).pop();
            },
          ),
        ],
      )
    );
  }

  // -- focus remover
  _removeFocus(){
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  // -- download in downloads gallery
  download_intoGallery() async {
      RenderRepaintBoundary boundary =
      _captureglobalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      final file_name = DateTime.now().millisecondsSinceEpoch;
      final path = '/storage/emulated/0/socioposter';
      final checkPathExistence = await Directory(path).exists();
      // -- directory creation and file save
      if(!checkPathExistence){
        await Directory(path).create(recursive: true);
      }
      File file = File(
          '/storage/emulated/0/socioposter/' + file_name.toString() + ".png"
      );
      file.writeAsBytesSync(pngBytes);
      Toast.show(
        "Post Exported To Gallery",
        context,
        gravity: Toast.CENTER,
        duration: Toast.LENGTH_LONG,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
  }

  // -- Generate Image
  _capturensharePng() async {
    try {
      imageCache.clear();
      setState(() {
        working = false;
      });

      RenderRepaintBoundary boundary =
      _captureglobalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      setState(() {
        working = false;
      });
      // share Image
      await Share.file('Social Post', 'mypost.png', pngBytes, 'image/png', text: 'https://hellodearcode.com');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomPadding: true,
        appBar: AppBar(
          title: Text('Post Editor'),
          actions: [
            (_textInputController.text.length > 1) ?
            IconButton(
              color: Colors.white.withAlpha(50),
              onPressed: _capturensharePng,
              icon: Icon(Icons.share,color: Colors.white),
            )
                :
            Center()
            ,
            (_textInputController.text.length > 1) ?
            IconButton(
              color: Colors.white.withAlpha(50),
              onPressed: () => download_intoGallery(),
              icon: Icon(Icons.save_alt,color: Colors.white),
            )
                :
            Center()
          ],
        ),
        body: GestureDetector(
          onTap: _removeFocus,
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                        child: RepaintBoundary(
                          key: _captureglobalKey,
                          child: Stack(
                            children: [
                              Image.file(
                                widget.file_image,
                                width: MediaQuery.of(context).size.width,
                                height: 400.0,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                height: 400.0,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(_opacity),
                                ),
                                child: Center(),
                              ),
                              Container(
                                child: Positioned(
                                  left: offset.dx,
                                  top: offset.dy,
                                  child: GestureDetector(
                                      onPanUpdate: (details) {
                                        setState(() {
                                          offset = Offset(offset.dx + details.delta.dx,
                                              offset.dy + details.delta.dy);
                                        });
                                      },
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width - 50,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text(
                                                _text,
                                                textAlign: TextAlign.center,
                                                textDirection: _stdtextDirection,
                                                style: TextStyle(
                                                    fontSize: _fontSize,
                                                    color: pickerColor,
                                                    fontFamily: _fontFamily
                                                )
                                            ),
                                          ),
                                        ),
                                      )),
                                ),
                              ),
                              Positioned(
                                left: creditsOffset.dx,
                                top: creditsOffset.dy,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    setState(() {
                                      creditsOffset = Offset(creditsOffset.dx + details.delta.dx,
                                          creditsOffset.dy + details.delta.dy);
                                    });
                                  },
                                  child: Text(
                                    creditsText,
                                    style: TextStyle(
                                      color: Color(0x44ffffff),
                                      fontSize: 20.0
                                    ),
                                  ),
                                )
                              )
                            ],
                          ),
                        )
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Center(
                          child: FlatButton(
                            child: Row(
                              children: [
                                Icon(Icons.translate_outlined,color: Colors.white,),
                                SizedBox(width: 5.0,),
                                Text("اردو", style: TextStyle(color: Colors.white,fontSize: 17.0,fontFamily: "urdu"))
                              ],
                            ),
                            color: Theme.of(context).primaryColor,
                            onPressed: (){
                              if(_stdtextDirection == TextDirection.ltr){
                                _textInputController.clear();
                              }
                              setState(() {
                                _stdtextDirection = TextDirection.rtl;
                                _fontFamily = "urdu";
                              });
                              showTextInput();
                            },
                          ),
                        ),
                        Center(
                          child: FlatButton(
                            child: Row(
                              children: [
                                Icon(Icons.g_translate_rounded,color: Colors.white,),
                                SizedBox(width: 5.0,),
                                Text("English", style: TextStyle(color: Colors.white))
                              ],
                            ),
                            color: Theme.of(context).primaryColor,
                            onPressed: (){
                              if(_stdtextDirection == TextDirection.rtl){
                                _textInputController.clear();
                              }
                              setState(() {
                                _stdtextDirection = TextDirection.ltr;
                                _fontFamily = "";
                              });
                              showTextInput();
                            },
                          ),
                        ),

                      ],
                    ),
                    (_text.length > 1)
                        ?
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "Size & Color"
                          ),
                          Expanded(
                            child: Slider(
                                activeColor: Theme.of(context).primaryColor,
                                inactiveColor: Theme.of(context).primaryColor.withAlpha(100),
                                value: _fontSize,
                                min: 12.0,
                                max: 72.0,
                                onChanged: (_size) {
                                  _removeFocus();
                                  setState(() {
                                    _fontSize = _size;
                                  });
                                }
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.color_lens_outlined,size: 28,color: Theme.of(context).primaryColor,),
                            onPressed: openColorPicker,
                          ),
                          _opacityMenuButton(),
                        ],
                      ),
                    ) : Center(),
                    SizedBox(height: 10.0,),
                    Text(
                      " -- Credits Setting -- ",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor.withAlpha(150)
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Container(
                      height: 70.0,
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        controller: _creditsController,
                        maxLengthEnforced: true,
                        maxLength: 25,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: (){
                              _removeFocus();
                              setState(() {
                                creditsText = _creditsController.text;
                              });
                            },
                            icon: Icon(Icons.check,size: 28,color:Theme.of(context).primaryColor),
                          )
                        ),
                        style: TextStyle(
                            fontSize: 16.0
                        ),
                      ),
                    )
                  ],
                ),
              ),
              !working
                  ?
              Center()
                  :
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.black.withAlpha(120),
                  child: Center(
                      child: CircularProgressIndicator()
                  )
              )
            ],
          ),
        )
    );
  }

  // -- -- Color Button
  Widget _opacityMenuButton() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.opacity,
        color: Theme.of(context).primaryColor,
        size: 28,
      ),
      onSelected: (c) {
        _removeFocus();
        double x = double.parse(c);
        setState(() {
          _opacity = x;
        });
      },
      itemBuilder: (BuildContext context) {
        return {0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0}.map((choice) {
          return PopupMenuItem<String>(
            value: choice.toString(),
            height: 30.0,
            child: Center(
              child: Text(
                  choice.toString().replaceAll(".", "")
              ),
            ),
          );
        }).toList();
      },
    );
  }
}
