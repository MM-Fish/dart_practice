import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfirmPage extends StatefulWidget {
  final String date;
  ConfirmPage(this.date);

  @override
  _ConfirmPageState createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage>
    with SingleTickerProviderStateMixin {
  final _tab = <Tab>[
    Tab(text: 'Line', icon: Icon(Icons.message)),
    Tab(text: 'Sashimori', icon: Icon(Icons.apartment)),
  ];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    fetchPostData();
    _tabController = TabController(vsync: this, length: _tab.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // int i = 0;
  // void fetchPostData() async {
  //   await FirebaseFirestore.instance
  //       .collection('posts')
  //       .get()
  //       .then((QuerySnapshot snapshot) {
  //     snapshot.docs.forEach((doc) {
  //       // print(doc['character']);
  //       _postData.add({
  //         'prefecture': doc['prefecture'],
  //         'fishingPort': doc['fishingPort'],
  //         'fishingMethod': doc['fishingMethod'],
  //         'character': doc['character'],
  //         'catches': []
  //       });
  //       FirebaseFirestore.instance
  //           .collection('posts')
  //           .doc(doc.id)
  //           .collection('catches')
  //           .get()
  //           .then((QuerySnapshot innerSnapshot) {
  //         innerSnapshot.docs.forEach((innerDoc) {
  //           _postData[i]['catches'].add({
  //             'condition': innerDoc['condition'],
  //             'species': innerDoc['species'],
  //             'num': innerDoc['num'],
  //             'unit': innerDoc['unit']
  //           });
  //         });
  //         i += 1;
  //       });
  //     });
  //     _postDataController.add(_postData);
  //   });
  // }

  final _copiedTextDataController = StreamController<String>.broadcast();
  final List<dynamic> prefectures = [];
  final List<dynamic> fishingPorts = [];
  final List<dynamic> fishingMethods = [];
  String _copiedTextData = '';
  void fetchPostData() async {
    _copiedTextData +=
        '【' + widget.date.replaceAll('曜日', ')').replaceAll('日', '日(') + '漁獲速報】';
    QuerySnapshot postSnapshot =
        await FirebaseFirestore.instance.collection('posts').get();
    postSnapshot.docs.forEach((doc) async {
      if (prefectures.indexOf(doc['prefecture']) != -1) {
        if (fishingPorts.indexOf(doc['fishingPort']) != -1) {
          _copiedTextData += '\n';
          _copiedTextData += '【' + doc['fishingMethod'].toString() + '】' + '\n';
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(doc.id)
              .collection('catches')
              .get()
              .then((QuerySnapshot innerSnapshot) {
            innerSnapshot.docs.forEach((innerDoc) {
              _copiedTextData += innerDoc['condition'] +
                  innerDoc['species'] +
                  innerDoc['num'] +
                  innerDoc['unit'] +
                  '\n';
            });
          });
        } else {
          fishingPorts.add(doc['fishingPort']);
          _copiedTextData += doc['character'].toString() +
              doc['fishingPort'].toString() +
              '\n';
          _copiedTextData += '【' + doc['fishingMethod'].toString() + '】' + '\n';
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(doc.id)
              .collection('catches')
              .get()
              .then((QuerySnapshot innerSnapshot) {
            innerSnapshot.docs.forEach((innerDoc) {
              _copiedTextData += innerDoc['condition'] +
                  innerDoc['species'] +
                  innerDoc['num'] +
                  innerDoc['unit'] +
                  '\n';
            });
          });
        }
      } else {
        prefectures.add(doc['prefecture']);
        _copiedTextData += '\n';
        _copiedTextData += doc['character'].toString() +
            doc['prefecture'].toString() +
            doc['character'].toString() +
            '\n';
        if (fishingPorts.indexOf(doc['fishingPort']) != -1) {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(doc.id)
              .collection('catches')
              .get()
              .then((QuerySnapshot innerSnapshot) {
            innerSnapshot.docs.forEach((innerDoc) {
              _copiedTextData += innerDoc['condition'] +
                  innerDoc['species'] +
                  innerDoc['num'] +
                  innerDoc['unit'] +
                  '\n';
            });
          });
        } else {
          fishingPorts.add(doc['fishingPort']);
          _copiedTextData += doc['character'].toString() +
              doc['fishingPort'].toString() +
              '\n';
          _copiedTextData += '【' + doc['fishingMethod'].toString() + '】' + '\n';
          FirebaseFirestore.instance
              .collection('posts')
              .doc(doc.id)
              .collection('catches')
              .get()
              .then((QuerySnapshot innerSnapshot) {
            innerSnapshot.docs.forEach((innerDoc) {
              _copiedTextData += innerDoc['condition'] +
                  innerDoc['species'] +
                  innerDoc['num'] +
                  innerDoc['unit'] +
                  '\n';
            });
          });
        }
      }
      _copiedTextDataController.add(_copiedTextData);
    });
  }

  Future<void> _copyToClipboard(String copiedText) async {
    print(_copiedTextData);
    await Clipboard.setData(ClipboardData(text: copiedText));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Copied to clipboard'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('登録内容確認'),
          bottom: TabBar(
            controller: _tabController,
            tabs: _tab,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _linePage(),
            _sashimoriPage(),
          ],
        ));
  }

  Widget _linePage() {
    return StreamBuilder(
      stream: _copiedTextDataController.stream,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return Column(
            children: [
              IconButton(
                icon: Icon(Icons.content_copy),
                onPressed: () {
                  _copyToClipboard(snapshot.data!.toString());
                },
              ),
              Text(snapshot.data!.toString()),
            ],
          );
        } else {
          return Text('漁獲なし');
        }
      },
    );
  }

  Widget _sashimoriPage() {
    return Text('linePage');
  }
}
