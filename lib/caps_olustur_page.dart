import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';

class CapsOlusturPage extends StatefulWidget {
  @override
  _CapsOlusturPageState createState() => _CapsOlusturPageState();
}

class _CapsOlusturPageState extends State<CapsOlusturPage> {
  final GlobalKey globalKey = new GlobalKey();
  final picker = ImagePicker();

  String headerText = "";
  String footerText = "";

  PickedFile _image; // cihazdan alacağımız resim için
  File _imageFile; // seçilen resime yazı eklendikten sonraki dosya için

  bool imageSelected = false;

  Random rng =
      new Random(); // kendimize ait resim için random resim adları için

  // CİHAZDAN RESİM ALMA
  Future getImage() async {
    var image;
    try {
      image = await picker.getImage(source: ImageSource.gallery);
    } catch (platformException) {
      print("İzin Yok " + platformException);
    }
    setState(() {
      if (image != null) {
        imageSelected = true;
        _image = image;
      }
    });
    new Directory('storage/emulated/0/' + 'texttoimage')
        .create(recursive: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Caps Oluştur'),
        actions: [
          IconButton(
              icon: Icon(Icons.add_a_photo),
              onPressed: () {
                getImage();
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 14),
              // SCREENSHOT ALINACAK ALAN
              RepaintBoundary(
                key: globalKey,
                child: Stack(
                  children: <Widget>[
                    // SEÇİLEN RESİM
                    _image != null
                        ? Container(
                            alignment: Alignment.center,
                            child: Image.file(
                              File(_image.path),
                              height: 300,
                              fit: BoxFit.fitHeight,
                            ),
                          )
                        : Container(),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // ÜST YAZI
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              headerText.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 26,
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 3.0,
                                    color: Colors.black87,
                                  ),
                                  Shadow(
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 8.0,
                                    color: Colors.black87,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Spacer(),
                          // ALT YAZI
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                footerText.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 26,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(2.0, 2.0),
                                      blurRadius: 3.0,
                                      color: Colors.black87,
                                    ),
                                    Shadow(
                                      offset: Offset(2.0, 2.0),
                                      blurRadius: 8.0,
                                      color: Colors.black87,
                                    ),
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              imageSelected
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            onChanged: (val) {
                              setState(() {
                                headerText = val;
                              });
                            },
                            decoration: InputDecoration(hintText: "Üst Yazı"),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          TextField(
                            onChanged: (val) {
                              setState(() {
                                footerText = val;
                              });
                            },
                            decoration: InputDecoration(hintText: "Alt Yazı"),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          RaisedButton(
                            onPressed: () {
                              // TODOd
                              takeScreenshot();
                            },
                            child: Text("Kaydet"),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      child: Center(
                        child: Text("Resim Seçiniz"),
                      ),
                    ),
              _imageFile != null ? Image.file(_imageFile) : Container(),
            ],
          ),
        ),
      ),
      floatingActionButton: _imageFile != null
          ? FloatingActionButton(
              tooltip: "Paylaş",
              onPressed: () {
                Share.shareFiles([_imageFile.path],
                    text: headerText + " " + footerText);
              },
              child: Icon(Icons.share_outlined),
            )
          : null,
    );
  }

  takeScreenshot() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print(pngBytes);
    File imgFile = new File('$directory/screenshots${rng.nextInt(200)}.png');
    setState(() {
      _imageFile = imgFile;
    });
    imgFile.writeAsBytes(pngBytes);
    _savefile(_imageFile);
    //saveFileLocal();
  }

  _savefile(File file) async {
    await _askPermission();
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(await file.readAsBytes()));
    print(result);
  }

  _askPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.photos]);
  }
}
