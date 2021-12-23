import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'package:shrf2/utils/fade_animation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'history.dart';
import 'package:intl/intl.dart';
import 'loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

double power = 0;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
      '/': (context) => Loading(),
        'home': (context) => MyHomePage(),
        'history': (context) => History(),
      },
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> categories = [
    'Volt',
    'Power',
    "efficiency",
  ];
  List<String> unit = [
    'V',
    'W',
    "%"
  ];
  late List productImages = [
    0,
    0,
    0,
  ];
  final CollectionReference history = FirebaseFirestore.instance.collection('history');
  late List<LiveData> chartData;
  late var timer;
  late ChartSeriesController _chartSeriesController;
  late FlutterLocalNotificationsPlugin localNotification;
  final databaseRef = FirebaseDatabase.instance.reference(); //database reference object

  @override
  void initState() {
    chartData = getChartData();
    if (mounted) {
      timer = Timer.periodic( Duration(seconds: 1), updateDataSource,);
    }
    super.initState();
    // android settings initialiizer
    var androidIntialize =  AndroidInitializationSettings("ic_launcher");

    // IOS settings Initializer

    var iOSIntialize = IOSInitializationSettings();
    //Initilization Settings

    var initialzationSettings = InitializationSettings(
        android: androidIntialize , iOS: iOSIntialize
    );

    // setting up local notification

    localNotification = FlutterLocalNotificationsPlugin();
    localNotification.initialize(initialzationSettings);

    databaseRef.onValue.listen((event) {
      if(event.snapshot.exists){
        productImages[0] = event.snapshot.value["vin"];
        productImages[1] = event.snapshot.value["vin"] * 0.1; //volt * current
        productImages[2] = event.snapshot.value["vin"] * 0.1 / event.snapshot.value['flowRate'] * 0.11433333333 * 2;
        history.add({
          "time": DateFormat('yyyy-MM-dd \n kk:mm:ss')
            .format(DateTime.now())
            .toString(),
          "volt" : productImages[0],
          "power" : productImages[1],
          "efficiency" : productImages[2],
        });
      }
    });
  }
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: SizedBox(),
                decoration: BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('assets/cover.jpeg'))),
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
          backgroundColor: const Color(0xffF7F8FA),
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            elevation: 0,
            backgroundColor: Colors.white,
            title: const Text('Dam station',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Container(
                              color: Colors.white,
                              height: 100,
                              child: Stack(
                                overflow: Overflow.visible,
                                children: <Widget>[
                                  Positioned(
                                    right: -40.0,
                                    top: -40.0,
                                    child: InkResponse(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: CircleAvatar(
                                        child: Icon(Icons.close,
                                        color: Colors.black,),
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("About"),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ),
                          );
                        });
                  },
                  icon: const Icon(Icons.help, color: Colors.black))
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                FadeAnimation(
                  delay: 0,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                      height: 280,
                      width: double.infinity,
                    child: SfCartesianChart(
                        series: <LineSeries<LiveData, int>>[
                          LineSeries<LiveData, int>(
                            onRendererCreated: (ChartSeriesController controller) {
                              _chartSeriesController = controller;
                            },
                            dataSource: chartData,
                            color: Colors.blue,
                            xValueMapper: (LiveData sales, _) => sales.time,
                            yValueMapper: (LiveData sales, _) => sales.power,
                          )
                        ],
                        primaryXAxis: NumericAxis(
                            majorGridLines: const MajorGridLines(width: 0),
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            interval: 1,
                            title: AxisTitle(text: 'Time (seconds)')),
                        primaryYAxis: NumericAxis(
                            axisLine: const AxisLine(width: 0),
                            majorTickLines: const MajorTickLines(size: 0),
                            title: AxisTitle(text: 'Power (W)'))),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Values',
                          style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
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
                                trailing: Text(productImages[index].toString() + unit[index],
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
                const SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ));
  }

  int time = 0;
  void updateDataSource(Timer timer) {
   if(time > 10){
     chartData.removeAt(0);
   }
    chartData.add(LiveData(time++, productImages[1]));
    _chartSeriesController.updateDataSource(
        addedDataIndex: chartData.length - 1, removedDataIndex: 0);
   setState(() {});
  }

  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, 0),
    ];
  }
}

class LiveData {
  LiveData(this.time, this.power);
  final int time;
  final num power;
}

