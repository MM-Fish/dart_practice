import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:practice/ui/login.dart';
// import 'package:provider/provider.dart';

// // 更新可能なデータ
// class UserState extends ChangeNotifier {
//   User? user;

//   void setUser(User newUser) {
//     user = newUser;
//     notifyListeners();
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'catch data form',
      theme: ThemeData(
        // テーマカラー
        primarySwatch: Colors.blue,
      ),
      // home: CatchDataListPage(),
      home: LoginPage(),
      // builder: (BuildContext context, Widget widget) {
      //   Widget error = Text('...rendering error...');
      //   if (widget is Scaffold || widget is Navigator)
      //     error = Scaffold(body: Center(child: error));
      //   ErrorWidget.builder = (FlutterErrorDetails errorDetails) => error;
      //   return widget;
      // },
    );
  }
}
