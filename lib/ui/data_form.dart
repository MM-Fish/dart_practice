import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<List> childres = [
    ['test']
  ];
  String _speciesName = '';
  String _catchAmount = '';
  List<String> _catchUnitItems = ["case", "kg", "t", "匹"];
  String _catchUnit = 'case';
  List<String> _fishConditionItems = ["鮮魚", "活魚", "冷凍", "A", "B"];
  String _fishCondition = "鮮魚";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("漁獲データ登録"),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return SelectDatePage();
            }),
          );
        },
        child: Icon(Icons.check),
      ),
    );
  }

  TextEditingController _cardTextController = TextEditingController();
  // TextEditingController _taskTextController = TextEditingController();

  _buildBody() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('posts').get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          // 取得した投稿メッセージ一覧を元にリスト表示
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: documents.length + 1,
            itemBuilder: (context, index) {
              if (index == documents.length)
                return _buildAddCardWidget(context);
              else
                return _buildCard(context, index, documents[index]);
            },
          );
        } else {
          return _buildAddCardWidget(context);
        }
      },
    );
  }

  _showAddCard() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(hintText: "漁港名"),
                  controller: _cardTextController,
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final date =
                        DateTime.now().toLocal().toIso8601String(); // 現在の日時
                    final email = 'program@gmail.com'; // AddPostPage のデータを参照
                    // 投稿メッセージ用ドキュメント作成
                    await FirebaseFirestore.instance
                        .collection('posts') // コレクションID指定
                        .doc() // ドキュメントID自動生成
                        .set({
                      'text': _cardTextController.text.trim(),
                      'email': email,
                      'date': date
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("漁港追加"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  _showAddCardTask(int index, String documentId) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButton(
                  value: _fishCondition,
                  onChanged: (String? value) {
                    setState(() {
                      _fishCondition = value!;
                    });
                  },
                  items: _fishConditionItems
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                        value: value, child: Text(value));
                  }).toList(),
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: '魚種名（産地名称）',
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _speciesName = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'ケース数',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (String value) {
                    setState(() {
                      _catchAmount = value;
                    });
                  },
                ),
                DropdownButton(
                  value: _catchUnit,
                  onChanged: (String? value) {
                    setState(() {
                      _catchUnit = value!;
                    });
                  },
                  items: _catchUnitItems
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                        value: value, child: Text(value));
                  }).toList(),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // 漁獲量追加
                      await FirebaseFirestore.instance
                          .collection('posts') // コレクションID指定
                          .doc(documentId)
                          .collection('catches')
                          .doc() // ドキュメントID自動生成
                          .set({
                        'fishingPortId': documentId,
                        'species': _speciesName,
                        'num': _catchAmount,
                        'unit': _catchUnit,
                        'condition': _fishCondition,
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text("漁獲量追加"),
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget _buildCard(
      BuildContext context, int index, DocumentSnapshot document) {
    String cardTitle = document['text'];
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            width: 300.0,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 0),
                    color: Color.fromRGBO(127, 140, 141, 0.5),
                    spreadRadius: 1)
              ],
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            margin: const EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ListTile(
                    title: Text(
                      cardTitle,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('posts')
                            .doc(document.id)
                            .delete();
                      },
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(document.id)
                          .collection('catches')
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final List<DocumentSnapshot> innerDocuments =
                              snapshot.data!.docs;
                          // 取得した投稿メッセージ一覧を元にリスト表示
                          return ListView.builder(
                            itemCount: innerDocuments.length + 1,
                            itemBuilder: (context, index) {
                              if (index == innerDocuments.length)
                                return _buildAddCardTaskWidget(
                                    context, index, document.id);
                              else
                                return _buildCardTask(
                                    index, document.id, innerDocuments[index]);
                            },
                          );
                        } else {
                          return _buildAddCardWidget(context);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardWidget(context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            _showAddCard();
          },
          child: Container(
            width: 300.0,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 0),
                    color: Color.fromRGBO(127, 140, 141, 0.5),
                    spreadRadius: 2)
              ],
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.add,
                ),
                SizedBox(
                  width: 16.0,
                ),
                Text("漁港追加"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Container _buildCardTask(
      int index, String documentId, DocumentSnapshot innerDocument) {
    return Container(
      width: 300.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        color: Colors.blue[200],
        child: ListTile(
          title: Text(innerDocument['species'] +
              ' ' +
              innerDocument['num'].toString() +
              ' ' +
              innerDocument['unit']),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('posts')
                  .doc(documentId)
                  .collection('catches')
                  .doc(innerDocument.id)
                  .delete();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAddCardTaskWidget(
      BuildContext context, int index, String documentId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          _showAddCardTask(index, documentId);
        },
        child: Row(
          children: <Widget>[
            Icon(
              Icons.add,
            ),
            SizedBox(
              width: 16.0,
            ),
            Text("漁獲量追加"),
          ],
        ),
      ),
    );
  }
}

class SelectDatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('日付確認'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return ConfirmPage();
            }),
          );
        },
        child: Icon(Icons.check),
      ),
    );
  }
}

class ConfirmPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登録内容確認'),
      ),
    );
  }
}
