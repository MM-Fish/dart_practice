import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:practice/ui/confirm_page_for_line.dart';

class ConfirmPageForSashimori extends StatelessWidget {
  final String date;
  ConfirmPageForSashimori(this.date);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('sashimori用登録内容確認'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: Text(this.date),
            ),
            Container(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('posts').get(),
                builder: (context, snapshot) {
                  // データが取得できた場合
                  if (snapshot.hasData) {
                    final List<DocumentSnapshot> documents =
                        snapshot.data!.docs;
                    // 取得した投稿メッセージ一覧を元にリスト表示
                    return ListView.builder(
                      shrinkWrap: true, //追加
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        return _catchData(context, documents[index]);
                      },
                    );
                  } else {
                    return Text('漁獲無し');
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return ConfirmPageForLine(this.date);
            }),
          );
        },
        child: Icon(Icons.compare_arrows_rounded),
      ),
    );
  }

  Widget _catchData(BuildContext context, DocumentSnapshot document) {
    String fishingPort = document['fishingPort'];
    String fishingMethod = document['fishingMethod'];
    return Column(
      children: [
        Text(fishingPort),
        Text('【' + fishingMethod + '】'),
        FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('posts')
              .doc(document.id)
              .collection('catches')
              .orderBy('date')
              .get(),
          builder: (context, snapshot) {
            // データが取得できた場合
            if (snapshot.hasData) {
              final List<DocumentSnapshot> documents = snapshot.data!.docs;
              return ListView(
                shrinkWrap: true, //追加
                physics: const NeverScrollableScrollPhysics(),
                children: documents.map((document) {
                  if (document['condition'] == '鮮魚')
                    return Text(document['species'] +
                        document['num'].toString() +
                        document['unit']);
                  else {
                    return Text(document['species'] +
                        '(' +
                        document['condition'][0] +
                        ')' +
                        document['num'].toString() +
                        document['unit']);
                  }
                }).toList(),
              );
            } else {
              return Text('漁獲無し');
            }
          },
        ),
      ],
    );
  }
}
