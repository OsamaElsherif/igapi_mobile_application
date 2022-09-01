import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic>? _userData;
  AccessToken? _accessToken;
  bool _checking = true;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _checkFirstLoggedIn();
  }

  void _checkFirstLoggedIn() async {
    final accessToken = await FacebookAuth.instance.accessToken;

    setState(() {
      _checking = false;
    });

    if (accessToken != null) {
      print(accessToken.toJson());
      final userData = await FacebookAuth.instance.getUserData();

      _accessToken = accessToken;
      setState(() {
        _userData = userData;
      });
    } else {
      _login();
    }
  }

  _login() async {
    final LoginResult loginResult = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile', 'instagram_basic', 'pages_show_list', 'instagram_manage_insights', 'pages_read_engagement'], loginBehavior: LoginBehavior.webOnly
    );

    if (loginResult.status == LoginStatus.success) {
      // getting the access token after logging in
      _accessToken = loginResult.accessToken;

      // get normal user data
      final userData = await FacebookAuth.instance.getUserData();
      _userData = userData;
    } else {
      print(loginResult.status);
      print(loginResult.message);
    }

    setState(() {
      _checking = false;
    });
  }

  _logout() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
    _userData = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("IGAPI LOGIN AUTH")),
        body: _checking ? Center(
          child: CircularProgressIndicator(),
        ) 
        : Center(
            child: Column(
          children: [
            _userData != null
                ? Text("name: ${_userData!['name']} ")
                : Container(),
            _userData != null
                ? Text("email: ${_userData!['email']} ")
                : Container(),
            _userData != null
                ? Text("ID: ${_userData!['id']} ")
                : Container(),
            _userData != null
                ? Container(
                    child: Image.network(_userData!['picture']['data']['url']),
                  )
                : Container(),
            SizedBox(
              height: 20,
            ),
            CupertinoButton(
                onPressed: _userData != null ? _logout : _login,
                color: Colors.blue,
                child: Text(
                  _userData != null ? 'Logout' : 'Login',
                  style: const TextStyle(color: Colors.white),
                ))
          ],
        )),
      ),
    );
  }
}
