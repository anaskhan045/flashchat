import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullPhotoScreen extends StatefulWidget {
  final String photoUrl;
  FullPhotoScreen({this.photoUrl});
  @override
  State createState() => FullPhotoScreenState();
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Done',
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ))
        ],
      ),
      body: Container(
          child: PhotoView(
              imageProvider: CachedNetworkImageProvider(widget.photoUrl))),
    );
  }
}
