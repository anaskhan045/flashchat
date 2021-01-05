import 'package:flutter/material.dart';


circularProgress() {
  return Container(child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.lightBlueAccent),
    ),
  ));
}

linearProgress() {
  return Container(child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.lightBlueAccent),
    ),
  ));
}

