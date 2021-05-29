import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DialogRegisterFishingPort extends StatefulWidget {
  @override
  _DialogRegisterFishingPortState createState() =>
      _DialogRegisterFishingPortState();
}

class _DialogRegisterFishingPortState extends State<DialogRegisterFishingPort> {
  String _fishingPort = '';
  // final _fishingPortTargets = Map<String, List<dynamic>>();
  // final _prefectureTargets = Map<int, List<dynamic>>();
  // final _fishingMethods = Map<String, int>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('漁獲量登録'),
      children: <Widget>[
        _fishingPortTextField(),
        SizedBox(
          height: 30.0,
        ),
        _dataUpdateBottun(),
      ],
    );
  }

  Widget _fishingPortTextField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'ケース数',
      ),
      onChanged: (String value) {
        setState(() {
          _fishingPort = value;
        });
      },
    );
  }

  Widget _dataUpdateBottun() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          // 漁獲量追加
          await FirebaseFirestore.instance
              .collection('posts') // コレクションID指定
              .doc() // ドキュメントID自動生成
              .set({
            'fishingPort': _fishingPort,
          });
          Navigator.of(context).pop();
        },
        child: Text("漁獲量追加"),
      ),
    );
  }
}
