import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'class.dart';
import 'config_check.dart';
import 'sign_task.dart';

class Checklist extends StatelessWidget {
  const Checklist({Key? key, required this.user}) : super(key: key);

  final String user;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Content(user: user));
  }
}

class Content extends StatefulWidget {
  const Content({Key? key, required this.user}) : super(key: key);
  final String user;

  @override
  _ContentState createState() => _ContentState(user);
}

class _ContentState extends State<Content> {
  final String username;

  _ContentState(this.username);

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: false, body: content(context));
  }

  List checklist = [];

  Container content(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 50.0, right: 50, top: 70.0),
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text("$username's Checklist",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20.0))),
        const Divider(
          color: Colors.black,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20.0),
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.69,
              child: ListView()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Ink(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10.0),
                  onTap: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ConfigCheck()))
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.grid_view_sharp,
                      size: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Ink(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10.0),
                  onTap: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignTask()))
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.add,
                      size: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        )
      ]),
    );
  }
}
