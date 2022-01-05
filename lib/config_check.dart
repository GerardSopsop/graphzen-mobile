import 'package:flutter/material.dart';

import 'view_task.dart';
import 'class.dart';

class ConfigCheck extends StatelessWidget {
  const ConfigCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Content());
  }
}

class Content extends StatefulWidget {
  const Content({Key? key}) : super(key: key);

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(),
    );
  }
}
