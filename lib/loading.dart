import 'package:flutter/material.dart';

class Loading extends StatefulWidget {

  @override
  _Loading createState() => _Loading();
}

class _Loading extends State<Loading> {

void nextRoute(){
Future.delayed(Duration(seconds: 3),() {
Navigator.pushReplacementNamed(context, 'home');
});
}

  @override
  void initState(){
    super.initState();
  nextRoute();
  }
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
     body:Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
       children: <Widget>[
        Image(image: AssetImage('assets/cover.jpeg'))
        ,Text("Dam station",
        style: TextStyle(fontSize: 50,
        color: Colors.black))],
)
     ),
    );
  }
  }
