import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DialogFishingPortMethodForm extends StatefulWidget {
  @override
  _DialogFishingPortMethodFormState createState() =>
      _DialogFishingPortMethodFormState();
}

class _DialogFishingPortMethodFormState
    extends State<DialogFishingPortMethodForm> {
  String _fishingPort = '';
  String _fishingMethod = '底曳';
  final fishingPortTargets = Map<String, String>();
  final List<String> _fishingMethods = [];

  @override
  void initState() {
    super.initState();
    fetchFishingMethod();
    fetchFishingPort();
  }

  void fetchFishingMethod() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('fishing_methods').get();
    snapshot.docs
        .forEach((doc) => {_fishingMethods.add(doc['fishing_method'])});
  }

  void fetchFishingPort() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('fishing_regions').get();
    snapshot.docs
        .forEach((doc) => {_fishingMethods[doc['prefecture']] = doc.id});
  }

  Widget _fishingPortTextField() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return fishingPortTargets.keys.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        setState(() {
          _fishingPort = selection;
        });
        print('You just selected $selection');
      },
    );
  }

  Widget _fishingMethodButton() {
    return DropdownButton(
      value: _fishingMethod,
      onChanged: (String? value) {
        setState(() {
          _fishingMethod = value!;
        });
      },
      items: _fishingMethods.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    );
  }

  Widget _dataUpdateBottun() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final date = DateTime.now().toLocal().toIso8601String(); // 現在の日時
          // 漁獲量追加
          await FirebaseFirestore.instance
              .collection('posts') // コレクションID指定
              .doc() // ドキュメントID自動生成
              .set({
            'date': date,
            'fishingPort': _fishingPort,
            'fishingMethod': _fishingMethod,
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
        _fishingPortTextField(),
        _fishingMethodButton(),
        SizedBox(
          height: 30.0,
        ),
        _dataUpdateBottun(),
      ],
    );
  }
}
