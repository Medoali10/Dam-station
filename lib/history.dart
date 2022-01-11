import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'utils/fade_animation.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<String> categories = [
    'volt',
    'power',
    "efficiency",
  ];
  List<String> unit = [
    'V',
    'W',
    "%"
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 300,
                child: DrawerHeader(
                    child: SizedBox(),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage('assets/cover.jpeg'))),

                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () => {Navigator.pushReplacementNamed(context, 'home')},
              ),
              ListTile(
                leading: Icon(Icons.border_color),
                title: Text('History'),
                onTap: () => {Navigator.pushReplacementNamed(context, 'history')},
              )
            ],
          ),
        ),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text('History',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
          actions: [
            TextButton(
              child: Text("Clear",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 20)
              ),
                onPressed: () {
                  FirebaseFirestore.instance.collection('history').get().then((snapshot) {
                    for (DocumentSnapshot ds in snapshot.docs){
                      ds.reference.delete();
                    }});
                },)
          ],
        ),
        body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('history').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot doc = snapshot.data!.docs[index];
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 30),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children:  [
                                        Text(doc["time"],
                                            style:
                                            TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  SizedBox(
                                    height: 300,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount: categories.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {},
                                          child: FadeAnimation(
                                              delay: (index + 1) * 200,
                                              isHorizontal: true,
                                              child: Container(
                                                height: 100,
                                                width: 300,
                                                child: Card(
                                                  child: ListTile(
                                                    leading: Text(
                                                        categories[index],
                                                        style: TextStyle(
                                                            fontSize: 24,
                                                            fontWeight: FontWeight.w700,
                                                            color: Colors.black)
                                                    ),
                                                    trailing: Text(doc[categories[index]].toString() + unit[index],
                                                        style: TextStyle(
                                                            fontSize: 24,
                                                            fontWeight: FontWeight.w700,
                                                            color: Colors.blue)),
                                                  ),
                                                  elevation: 8,
                                                  shadowColor: Colors.black,
                                                  margin: EdgeInsets.all(20),
                                                ),
                                              )
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }

                    );
                  } else {
                    return Text("No data");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
