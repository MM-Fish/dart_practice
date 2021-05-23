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
  final _fishingPortTargets = Map<String, List<dynamic>>();
  final _prefectureTargets = Map<int, List<dynamic>>();
  final _fishingMethods = Map<String, int>();

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
        .forEach((doc) => {_fishingMethods[doc['fishing_method']] = doc['id']});
  }

  void fetchFishingPort() async {
    QuerySnapshot prefectureSnapshot =
        await FirebaseFirestore.instance.collection('prefectures').get();
    prefectureSnapshot.docs.forEach((doc) => {
          _prefectureTargets[doc['id']] = [doc['prefecture'], doc['character']]
        });
    QuerySnapshot fishingPortSnapshot =
        await FirebaseFirestore.instance.collection('fishing_ports').get();
    fishingPortSnapshot.docs.forEach((doc) => {
          _fishingPortTargets[doc['fishing_port']] = [
            doc.id,
            doc['id'],
            doc['prefecture_id'],
            _prefectureTargets[doc['prefecture_id']]![0],
            _prefectureTargets[doc['prefecture_id']]![1],
          ]
        });
  }

  Widget _fishingPortTextField() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return _fishingPortTargets.keys.where((String option) {
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
      items: _fishingMethods.keys.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
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
            'fishingPortDocsId': _fishingPortTargets[_fishingPort]![0],
            'fishingPortId': _fishingPortTargets[_fishingPort]![1],
            'fishingMethodId': _fishingMethods[_fishingMethod],
            'prefectureId': _fishingPortTargets[_fishingPort]![2],
            'fishingPort': _fishingPort,
            'fishingMethod': _fishingMethod,
            'prefecture': _fishingPortTargets[_fishingPort]![3],
            'character': _fishingPortTargets[_fishingPort]![4],
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
