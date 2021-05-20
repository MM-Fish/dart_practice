import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice/ui/select_date_page.dart';
import 'package:practice/ui/dialog_catch_form.dart';
import 'package:practice/ui/dialog_fishing_port_method_form.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('date')
          .snapshots(),
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
        builder: (_) {
          return DialogFishingPortMethodForm();
        });
  }

  _showAddCardTask(int index, String documentId) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return DialogCatchForm(documentId);
        });
  }

  Widget _buildCard(
      BuildContext context, int index, DocumentSnapshot document) {
    String cardTitle =
        document['fishingPort'] + ' 【' + document['fishingMethod'] + '】';
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
            child: SingleChildScrollView(
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
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .doc(document.id)
                            .collection('catches')
                            .orderBy('date')
                            .snapshots(),
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
                                  return _buildCardTask(index, document.id,
                                      innerDocuments[index]);
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
