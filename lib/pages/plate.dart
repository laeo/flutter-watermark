import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:watersec/lib/painter/ImagePainter.dart' as painter;
import 'package:watersec/lib/watermark/watermark.dart';
import 'package:path_provider/path_provider.dart' as path;

class Plate extends StatefulWidget {
  final File image;

  Plate({@required this.image});

  @override
  _PlateState createState() => _PlateState();
}

class _PlateState extends State<Plate> {
  final _content = TextEditingController();

  String text = "";
  double fontSize = 12;
  double fontOpacity = 0.12;
  int textPadding = 2;

  Future<ui.Image> _image;

  @override
  void initState() {
    super.initState();
    _content.addListener(() {
      setState(() {
        text = _content.text;
      });
    });

    _image = _retrieveImage();
  }

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<ui.Image> _retrieveImage() async {
    var codec = await ui.instantiateImageCodec(widget.image.readAsBytesSync());
    var frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('编辑'),
      ),
      body: SingleChildScrollView(
        primary: true,
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder(
              future: _image,
              builder:
                  (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  double ratio = snapshot.data.height / snapshot.data.width;
                  return LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return Container(
                        width: constraints.maxWidth,
                        height: constraints.maxWidth * ratio,
                        child: CustomPaint(
                          painter: painter.ImagePainter(
                              image: snapshot.data,
                              text: text,
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Color.fromRGBO(0, 0, 0, fontOpacity),
                              ),
                              space: textPadding),
                          willChange: true,
                        ),
                      );
                    },
                  );
                } else {
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('水印内容'),
            ),
            TextField(
              controller: _content,
            ),
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('字体大小'),
            ),
            Slider(
                value: fontSize,
                min: 8,
                max: 50,
                divisions: 50,
                label: '$fontSize',
                onChanged: (value) {
                  setState(() {
                    fontSize = value.roundToDouble();
                  });
                }),
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('水印透明度'),
            ),
            Slider(
                value: fontOpacity * 100,
                min: 0,
                max: 100,
                divisions: 100,
                label: '$fontOpacity',
                onChanged: (value) {
                  setState(() {
                    fontOpacity = value / 100;
                  });
                }),
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('水印间距'),
            ),
            Slider(
                value: textPadding.roundToDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                label: '$textPadding',
                onChanged: (value) {
                  setState(() {
                    textPadding = value.round();
                  });
                }),
            ElevatedButton.icon(
              onPressed: _takeSnapshot,
              icon: Icon(Icons.save_alt),
              label: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _takeSnapshot() async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    ui.Image image = await _retrieveImage();
    Watermark.draw(
        canvas,
        image,
        text,
        TextStyle(fontSize: fontSize, color: Colors.black12),
        textPadding,
        Size(image.width.roundToDouble(), image.height.roundToDouble()));
    ui.Image pic =
        await recorder.endRecording().toImage(image.width, image.height);
    ByteData data = await pic.toByteData(format: ui.ImageByteFormat.png);

    if (await Permission.storage.request().isGranted) {
      Directory doc = await path.getApplicationDocumentsDirectory();
      File tmp = File('${doc.path}/watering.png');
      tmp.writeAsBytesSync(data.buffer.asUint8List());
      await GallerySaver.saveImage(tmp.path, albumName: 'watermark')
          .then((value) {
        print(value);
        Fluttertoast.showToast(msg: '已保存到相册中');
      }).catchError((e) {
        print(e);
      });
    }
  }
}
