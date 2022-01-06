import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'register.dart';
import 'view_checklist.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UserLogin(),
    );
  }
}

class UserLogin extends StatefulWidget {
  const UserLogin({Key? key}) : super(key: key);

  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  bool nameFound = true;
  bool passWrong = false;

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: content(context),
    );
  }

  Container content(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 100.0),
      child: Form(
        key: formKey,
        child: Column(children: [
          const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('Graphzen',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0))),
          input(username, 'Enter username', false),
          input(password, 'Enter password', true),
          login(context),
          register(context)
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
              ? passWrong
                  ? "Wrong password"
                  : null
              : nameFound
                  ? null
                  : 'Wrong username';
        },
        obscureText: type,
      ),
      margin: const EdgeInsets.only(top: 50.0),
    );
  }

  Container login(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: TextButton(
          child: const Text('Log in', style: TextStyle(color: Colors.black)),
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              final database =
                  openDatabase(join(await getDatabasesPath(), 'graphzen.db'));
              final db = await database;
              try {
                await db.query("userkeys WHERE alias = '${username.text}'");
                db.close();
                nameFound = true;
                passWrong = false;
                password.clear();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Checklist(user: username.text)));
              } catch (e) {
                setState(() {
                  nameFound = false;
                  passWrong = true;
                  formKey.currentState!.validate();
                });
              }
            }
          }),
      margin: const EdgeInsets.only(top: 50.0),
    );
  }

  TextButton register(BuildContext context) {
    return TextButton(
        child: const Text('Register',
            style: TextStyle(
                decoration: TextDecoration.underline, color: Colors.black)),
        onPressed: () {
          nameFound = true;
          passWrong = false;
          username.clear();
          password.clear();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Registration()));
        });
  }
}
