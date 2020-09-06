import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:path/path.dart' as path;
import 'dart:math' as math;

class Plate extends StatefulWidget {
  final File image;

  Plate({@required this.image});

  @override
  _PlateState createState() => _PlateState();
}

class _PlateState extends State<Plate> {
  final _content = TextEditingController();
  final GlobalKey _repaintKey = GlobalKey();

  String text = "";
  double fontSize = 22;

  @override
  void initState() {
    super.initState();
    _content.addListener(() {
      setState(() {
        text = _content.value.text;
      });
    });
  }

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = ImageSizGetter.getSize(widget.image);
    var ratio = MediaQuery.of(context).devicePixelRatio;
    // calc size in dp.
    var w = size.width / ratio / 5;
    var h = size.height / ratio / 5;
    print(w);
    print(h);

    return Scaffold(
      appBar: AppBar(
        title: Text('编辑'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            RepaintBoundary(
              key: _repaintKey,
              child: Container(
                width: w,
                height: h,
                decoration: BoxDecoration(color: Colors.black12),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  overflow: Overflow.clip,
                  children: [
                    Image.file(widget.image,
                        fit: BoxFit.cover, width: w, height: h),
                    SizedBox(
                      height: math.max(w, h) * 2,
                      width: math.max(w, h) * 2,
                      child: Transform.rotate(
                        angle: -math.pi / 4,
                        child: Text(
                          (text + '  ') * (w * h * 2 ~/ (fontSize * fontSize)),
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.black12,
                          ),
                          maxLines: null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextField(
              controller: _content,
              decoration: InputDecoration(labelText: '水印文本'),
            ),
            Text('字体大小'),
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
            RaisedButton.icon(
              onPressed: _takeSnapshot,
              icon: Icon(Icons.camera_alt),
              label: Text('保存'),
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).primaryTextTheme.button.color,
            ),
          ],
        ),
      ),
    );
  }

  void _takeSnapshot() async {
    RenderRepaintBoundary boundary =
        _repaintKey.currentContext.findRenderObject();
    ui.Image out = await boundary.toImage(pixelRatio: 5.0);
    ByteData data = await out.toByteData(format: ui.ImageByteFormat.png);

    var name = path.basenameWithoutExtension(widget.image.path) + '_marked.png';
    await ImageGallerySaver.saveImage(data.buffer.asUint8List(),
        quality: 100, name: name);
    Fluttertoast.showToast(msg: '已保存到相册');
  }
}
