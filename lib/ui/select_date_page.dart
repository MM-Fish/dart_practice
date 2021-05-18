import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectDatePage extends StatefulWidget {
  @override
  _SelectDatePageState createState() => _SelectDatePageState();
}

class _SelectDatePageState extends State<SelectDatePage> {
  var _labelText = (DateFormat.MMMMEEEEd('ja')).format(DateTime.now());

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      locale: const Locale("ja"),
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (selected != null) {
      setState(() {
        _labelText = (DateFormat.MMMMEEEEd('JA')).format(selected);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('日付確認'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                _labelText,
                style: TextStyle(fontSize: 18),
              ),
              IconButton(
                icon: Icon(Icons.date_range),
                onPressed: () => _selectDate(context),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return ConfirmPage(_labelText);
            }),
          );
        },
        child: Icon(Icons.check),
      ),
    );
  }
}

class ConfirmPage extends StatelessWidget {
  final String date;
  ConfirmPage(this.date);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登録内容確認'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Text(this.date),
          ),
          Container(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('posts')
                  .doc('slUZ91BWMLak1ApEk5dt')
                  .collection('catches')
                  .get(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView(
                    shrinkWrap: true, //追加
                    physics: const NeverScrollableScrollPhysics(),
                    children: documents.map((document) {
                      if (document['condition'] == '鮮魚')
                        return Text(document['species'] +
                            ' ' +
                            document['num'].toString() +
                            ' ' +
                            document['unit']);
                      else {
                        return Text(document['species'] +
                            '(' +
                            document['condition'][0] +
                            ')' +
                            ' ' +
                            document['num'].toString() +
                            ' ' +
                            document['unit']);
                      }
                    }).toList(),
                  );
                } else {
                  return Text('漁獲無し');
                }
                ;
              },
            ),
          ),
        ],
      ),
    );
  }
}
