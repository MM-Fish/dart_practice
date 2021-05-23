import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:practice/ui/confirm_page_for_line.dart';

class ConfirmPage extends StatefulWidget {
  final String date;
  ConfirmPage(this.date);

  @override
  _ConfirmPageState createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  final _postDataController = StreamController<Map<String, dynamic>>();
  final _postData = Map<String, dynamic>();

  @override
  void initState() {
    super.initState();
    fetchPostData();
  }

  void fetchPostData() async {
    QuerySnapshot postSnapshot =
        await FirebaseFirestore.instance.collection('posts').get();
    postSnapshot.docs.forEach((doc) => {
          if (_postData.keys.toList().indexOf(doc['prefecture']) != -1)
            {
              if (_postData[doc['prefecture']]!
                      .keys
                      .toList()
                      .indexOf(doc['fishingPort']) !=
                  -1)
                {
                  _postData[doc['prefecture']]![doc['fishingPort']]![
                      doc['fishingMethod']] = doc.id
                }
              else
                {
                  _postData[doc['prefecture']]![doc['fishingPort']] =
                      <String, String>{
                    doc['fishingMethod'].toString(): doc.id,
                  }
                }
            }
          else
            {
              _postData[doc['prefecture']] = <String, dynamic>{
                'character': doc['character'],
                doc['fishingPort']: <String, String>{
                  doc['fishingMethod'].toString(): doc.id
                }
              }
            },
          _postDataController.add(_postData)
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登録内容確認'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: Text(widget.date),
            ),
            Container(
              child: StreamBuilder<Map<String, dynamic>>(
                stream: _postDataController.stream,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    print(snapshot.data);
                    return ListView.builder(
                        shrinkWrap: true, //追加
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.keys.length,
                        itemBuilder: (context, index) {
                          return _prefectureData(context, index, snapshot);
                        });
                  } else {
                    print('準備中');
                    return Text('準備中');
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
              return ConfirmPageForLine(widget.date);
            }),
          );
        },
        child: Icon(Icons.compare_arrows_rounded),
      ),
    );
  }

  Widget _prefectureData(
      BuildContext context, int index, AsyncSnapshot snapshot) {
    String prefecture = snapshot.data!.keys.toList()[index];
    String character = snapshot.data![prefecture]['character'];
    return Column(
      children: [
        Text(character + prefecture + character),
        ListView.builder(
          shrinkWrap: true, //追加
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data![prefecture].keys.length - 1,
          itemBuilder: (context, index) {
            return _fishingPortData(context, index, snapshot.data![prefecture]);
          },
        ),
      ],
    );
  }

  Widget _fishingPortData(
      BuildContext context, int index, Map dataInnerPrefecture) {
    index += 1;
    String character = dataInnerPrefecture['character'];
    String fishingPort = dataInnerPrefecture.keys.toList()[index];
    print(dataInnerPrefecture[fishingPort].keys.length);
    return Column(
      children: [
        Text(character + fishingPort),
        ListView.builder(
          shrinkWrap: true, //追加
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dataInnerPrefecture[fishingPort].keys.length,
          itemBuilder: (context, index) {
            return _fishingMethodData(
                context, index, dataInnerPrefecture[fishingPort]);
          },
        ),
      ],
    );
  }

  Widget _fishingMethodData(
      BuildContext context, int index, Map dataInnerFishingPort) {
    String fishingMethod = dataInnerFishingPort.keys.toList()[index];
    String documentId = dataInnerFishingPort[fishingMethod].toString();
    return Column(
      children: [
        Text('【' + fishingMethod + '】'),
        _catchData(documentId),
      ],
    );
  }

  Widget _catchData(documentId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(documentId)
          .collection('catches')
          .snapshots(),
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
    );
  }
}
