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
  final List<String> fishingPortTargets = ['鳥取港', '網代港', '浜坂・諸寄港'];
  List<String> _fishingMethods = ["底曳", "沿岸", "定置"];

  Widget _fishingPortTextField() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return fishingPortTargets.where((String option) {
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

//   return Dialog(
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: <Widget>[
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: TextField(
//             decoration: InputDecoration(hintText: "漁港名"),
//             controller: _cardTextController,
//           ),
//         ),
//         SizedBox(
//           height: 30.0,
//         ),
//         Center(
//           child: ElevatedButton(
//             onPressed: () async {
//               final date =
//                   DateTime.now().toLocal().toIso8601String(); // 現在の日時
//               final email = 'program@gmail.com'; // AddPostPage のデータを参照
//               // 投稿メッセージ用ドキュメント作成
//               await FirebaseFirestore.instance
//                   .collection('posts') // コレクションID指定
//                   .doc() // ドキュメントID自動生成
//                   .set({
//                 'text': _cardTextController.text.trim(),
//                 'email': email,
//                 'date': date
//               });
//               Navigator.of(context).pop();
//             },
//             child: Text("漁港追加"),
//           ),
//         )
//       ],
//     ),
//   );
// },
