import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'class.dart';

class Registration extends StatelessWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(resizeToAvoidBottomInset: false, body: Register());
  }
}

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = GlobalKey<FormState>();
  FocusNode focus = FocusNode();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  bool nameTaken = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 100.0),
      child: Form(
        key: formKey,
        child: Column(children: [
          const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('Register',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0))),
          input(username, 'Enter username', false),
          input(password, 'Enter password', true),
          register(context),
        ]),
      ),
    );
  }

  Container input(
      TextEditingController controller, String placeholder, bool type) {
    return Container(
      child: TextFormField(
        decoration: InputDecoration(
            hintText: placeholder,
            labelText: placeholder,
            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 3, color: Colors.blue),
              borderRadius: BorderRadius.circular(15),
            )),
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter text';
          }
          return type
              ? null
              : nameTaken
                  ? 'Username taken'
                  : null;
        },
        obscureText: type,
      ),
      margin: const EdgeInsets.only(top: 50.0),
    );
  }

  Container register(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: TextButton(
          child: const Text(
            'Register',
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              final database =
                  openDatabase(join(await getDatabasesPath(), 'graphzen.db'),
                      onCreate: (db, version) {
                return db.execute(
                  'CREATE TABLE userkeys(alias TEXT, pub TEXT, priv TEXT)',
                );
              }, version: 1);
              final db = await database;
              try {
                List temp1 =
                    await db.query("userkeys WHERE alias = '${username.text}'");
                Pair pair = SEA.pair();
                await db.insert('userkeys', {
                  'alias': username.text,
                  'pub': pair.pub,
                  'priv': pair.priv,
                });

                db.close();
                nameTaken = false;
                username.clear();
                password.clear();
                Navigator.pop(context);
              } catch (e) {
                setState(() {
                  nameTaken = true;
                  formKey.currentState!.validate();
                });
              }
            }
          }),
      margin: const EdgeInsets.only(top: 50.0),
    );
  }
}
