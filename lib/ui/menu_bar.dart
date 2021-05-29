import 'package:flutter/material.dart';
import 'package:practice/ui/data_form.dart';
import 'package:practice/ui/admin/register_species.dart';

Widget menuBar(BuildContext context) {
  return Drawer(
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        SizedBox(
          height: 88,
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Menu',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
        ListTile(
          title: Text('漁獲データ登録'),
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) {
                return HomePage();
              }),
            );
          },
        ),
        ListTile(
          title: Text('着信名称と配信名称の登録'),
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) {
                return RegisterSpeciesPage();
              }),
            );
          },
        ),
      ],
    ),
  );
}
