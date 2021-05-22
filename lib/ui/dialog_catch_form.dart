import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DialogCatchForm extends StatefulWidget {
  final String documentId;
  final String fishingPortDocsId;
  DialogCatchForm(this.documentId, this.fishingPortDocsId);

  @override
  _DialogCatchFormState createState() => _DialogCatchFormState();
}

class _DialogCatchFormState extends State<DialogCatchForm> {
  String _speciesName = '';
  int _category1 = 0;
  int _category2 = 0;
  String _catchAmount = '';
  List<String> _catchUnitItems = ["case", "kg", "t", "匹"];
  String _catchUnit = 'case';
  List<String> _fishConditionItems = ["鮮魚", "活魚", "冷凍", "A", "B"];
  String _fishCondition = "鮮魚";
  List<String> searchResults = [];
  final _searchTargets = Map<String, List>();

  @override
  void initState() {
    super.initState();
    fetchSearchTarget();
  }

  void fetchSearchTarget() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('fishing_ports')
        .doc(widget.fishingPortDocsId)
        .collection('validations')
        .get();
    snapshot.docs.forEach((doc) => {
          _searchTargets[doc['santi_name']] = [
            doc['haishin_name'],
            doc['category1'],
            doc['category2']
          ]
        });
  }

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
          _speciesName = _searchTargets[selection]![0].toString();
          _category1 = _searchTargets[selection]![1];
          _category2 = _searchTargets[selection]![2];
        });
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
          // 漁獲量追加
          await FirebaseFirestore.instance
              .collection('posts') // コレクションID指定
              .doc(widget.documentId)
              .collection('catches')
              .doc() // ドキュメントID自動生成
              .set({
            'fishingPortId': widget.documentId,
            'species': _speciesName,
            'num': _catchAmount,
            'unit': _catchUnit,
            'condition': _fishCondition,
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
