import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DialogCatchForm extends StatefulWidget {
  final String documentId;
  DialogCatchForm(this.documentId);

  @override
  _DialogCatchFormState createState() => _DialogCatchFormState();
}

class _DialogCatchFormState extends State<DialogCatchForm> {
  String _santiName = '';
  String _haishinName = '';
  int _category1 = 0;
  int _category2 = 0;

  @override
  void initState() {
    super.initState();
  }

  Widget _santiTextField() {
    return TextField(
      decoration: InputDecoration(
        hintText: '産地名称',
      ),
      onChanged: (String value) {
        setState(() {
          _santiName = value;
        });
      },
    );
  }

  Widget _haishinTextField() {
    return TextField(
      decoration: InputDecoration(
        hintText: '配信名称',
      ),
      onChanged: (String value) {
        setState(() {
          _haishinName = value;
        });
      },
    );
  }

  Widget _category1TextField() {
    return TextField(
      decoration: InputDecoration(
        hintText: '分類1(🐟1, 🦐2, 🦑/🐙3, 🦀4, 🐚5)',
      ),
      keyboardType: TextInputType.number,
      onChanged: (String value) {
        setState(() {
          _category1 = int.parse(value);
        });
      },
    );
  }

  Widget _category2TextField() {
    return TextField(
      decoration: InputDecoration(
        hintText: '分類2(鮪1, 青物2, カレイ3, その他10)',
      ),
      keyboardType: TextInputType.number,
      onChanged: (String value) {
        setState(() {
          _category2 = int.parse(value);
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
              .collection('fishing_ports') // コレクションID指定
              .doc(widget.documentId)
              .collection('validations')
              .doc() // ドキュメントID自動生成
              .set({
            'haishin_name': _haishinName,
            'santi_name': _santiName,
            'category1': _category1,
            'category2': _category2,
          });
          Navigator.of(context).pop();
        },
        child: Text("漁獲量追加"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('漁獲量登録'),
      children: <Widget>[
        _santiTextField(),
        _haishinTextField(),
        _category1TextField(),
        _category2TextField(),
        SizedBox(
          height: 30.0,
        ),
        _dataUpdateBottun(),
      ],
    );
  }
}
