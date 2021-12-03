import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:okpeadmin/adminchattest.dart';
import 'package:okpeadmin/chat_screen.dart';
import 'package:okpeadmin/constants.dart';
import 'package:okpeadmin/no_network.dart';
import 'package:okpeadmin/provider/selector.dart';
import 'package:okpeadmin/send_Notification.dart';
import 'package:okpeadmin/services/api.dart';
import 'package:okpeadmin/services/firebase.dart';
import 'package:okpeadmin/users.dart';
import 'package:okpeadmin/widgets.dart';
import 'package:okpeadmin/youtube_webview.dart';
import 'package:provider/provider.dart';

import 'facebook.dart';
import 'facebook.dart';
import 'youtube_webview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PlatformViewsService.synchronizeToNativeViewHierarchy(false);

  await Firebase.initializeApp();
  Diohelp.init();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final internetconnection = Connectivity()
      .onConnectivityChanged
      .listen((ConnectivityResult result) async {
    // whenevery connection status is changed.
    if (result == ConnectivityResult.none) {
      //there is no any connection

    } else if (result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile) {
      //connection is from wifi
      token = await messaging.getToken();
      await messaging.subscribeToTopic('admin');
      print(token);
    }
  });

  notifacationHandel();
  FirebaseMessaging.onBackgroundMessage(firebaseonbackground);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: SelectorProvider()),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          debugShowCheckedModeBanner: false,
          home: MyHomePage(),
        ));
  }
}

// String selectedUrl = 'https://www.youtube.com/c/%D8%A7%D9%84%D8%B5%D9%81%D8%AD%D8%A9%D8%A7%D9%84%D8%B1%D8%B3%D9%85%D9%8A%D8%A9%D9%84%D9%84%D8%AD%D8%A7%D8%AC%D8%B9%D9%82%D8%A8%D9%8A';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  StreamSubscription<ConnectivityResult> internetconnection;
  bool isoffline = true;
  TabController tabController;
  GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    internetconnection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // whenevery connection status is changed.
      if (result == ConnectivityResult.none) {
        //there is no any connection
        setState(() {
          isoffline = true;
        });
      } else if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        //connection is from wifi
        setState(() {
          isoffline = false;
        });
      }
    });
    tabController = TabController(vsync: this, length: 3);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      floatingActionButton: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
        child: FloatingActionButton(
          child: Icon(
            Icons.notifications,
          ),
          onPressed: () {
            scaffoldkey.currentState.showBottomSheet((context) {
              return SendNotification();
            });
          },
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: TabBar(
            labelPadding: EdgeInsets.only(top: 7),
            controller: tabController,
            // padding: EdgeInsets.zero,
            tabs: [
              Tab(
                  child: Text(
                "Youtube",
                style: TextStyle(color: Colors.black),
              )),
              Tab(
                  child: Text(
                "Facebook",
                style: TextStyle(color: Colors.black),
              )),
              Tab(
                  child: Text(
                "Chats",
                style: TextStyle(color: Colors.black),
              ))
            ]),
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          isoffline ? nonet(context) : WebViewExample(),
          isoffline ? nonet(context) : WebViewExample1(),
          UsersList()
        ],
      ),
    );
  }
}
