import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DialogCatchForm extends StatefulWidget {
  final String documentId;
  DialogCatchForm(this.documentId);

  @override
  _DialogCatchFormState createState() => _DialogCatchFormState();
}

class _DialogCatchFormState extends State<DialogCatchForm> {
  String _speciesName = '';
  String _catchAmount = '';
  List<String> _catchUnitItems = ["case", "kg", "t", "匹"];
  String _catchUnit = 'case';
  List<String> _fishConditionItems = ["鮮魚", "活魚", "冷凍", "A", "B"];
  String _fishCondition = "鮮魚";

  // final List<String> searchTargets = ['赤ガレイ', 'エテガレイ', 'ハタハタ'];

  final _searchTargets = Map<String, String>();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('validations').get();
    snapshot.docs.forEach(
        (doc) => {_searchTargets[doc['santiName']] = doc['haishinName']});
  }

  List<String> searchResults = [];

  Widget _conditionButton() {
    return DropdownButton(
      value: _fishCondition,
      onChanged: (String? value) {
        setState(() {
          _fishCondition = value!;
        });
      },
      items: _fishConditionItems.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    );
  }

  Widget _speciesTextField() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return _searchTargets.keys.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        setState(() {
          _speciesName = _searchTargets[selection].toString();
        });
        print('You just selected $selection');
      },
    );
  }

  Widget _numberTextField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'ケース数',
      ),
      keyboardType: TextInputType.number,
      onChanged: (String value) {
        setState(() {
          _catchAmount = value;
        });
      },
    );
  }

  Widget _unitButton() {
    return DropdownButton(
      value: _catchUnit,
      onChanged: (String? value) {
        setState(() {
          _catchUnit = value!;
        });
      },
      items: _catchUnitItems.map<DropdownMenuItem<String>>((String value) {
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
              .doc(widget.documentId)
              .collection('catches')
              .doc() // ドキュメントID自動生成
              .set({
            'date': date,
            'fishingPortId': widget.documentId,
            'species': _speciesName,
            'num': _catchAmount,
            'unit': _catchUnit,
            'condition': _fishCondition,
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
        _conditionButton(),
        _speciesTextField(),
        _numberTextField(),
        _unitButton(),
        SizedBox(
          height: 30.0,
        ),
        _dataUpdateBottun(),
      ],
    );
  }
}
