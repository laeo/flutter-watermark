import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:watersec/pages/plate.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Center(
              child: Text(
                '水印',
                style: TextStyle(
                    fontSize: 180,
                    fontWeight: FontWeight.bold,
                    fontFamily: "HuangYouTi",
                    letterSpacing: 40),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final picked = await ImagePickerSaver.pickImage(
                        source: ImageSource.gallery);
                    final image = File(picked.path);
                    if (ImageSizGetter.isJpg(image) ||
                        ImageSizGetter.isPng(image)) {
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
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('说明：本软件为开源软件，无权限要求，全程本地操作，不联网，请放心使用。'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
