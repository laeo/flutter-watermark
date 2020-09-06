import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:watersec/pages/plate.dart';

class HomePage extends StatelessWidget {
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('水印安全'),
      ),
      body: Container(
        child: Center(
          child: GestureDetector(
            onTap: () async {
              final picked = await picker.getImage(source: ImageSource.gallery);
              final image = File(picked.path);
              if (ImageSizGetter.isJpg(image) || ImageSizGetter.isPng(image)) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Plate(image: image)));
              } else {
                Fluttertoast.showToast(msg: '图片只支持 JPG 和 PNG 两种格式哟');
              }
            },
            child: Container(
              width: 180,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Center(
                child: Text(
                  '点击选择图片',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
