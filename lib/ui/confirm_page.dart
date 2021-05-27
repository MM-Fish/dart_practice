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
  final _postDataController = StreamController<List<dynamic>>.broadcast();
  // final List<dynamic> _postData = [];
  final _postData = Map<String, dynamic>();
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

  final _copiedTextDataController = StreamController<String>();
  final List<dynamic> prefectures = [];
  final List<dynamic> fishingPorts = [];
  final List<dynamic> fishingMethods = [];
  String _copiedTextData = '';
  void fetchPostData() async {
    QuerySnapshot postSnapshot =
        await FirebaseFirestore.instance.collection('posts').get();
    postSnapshot.docs.forEach((doc) async {
      if (prefectures.indexOf(doc['prefecture']) != -1) {
        if (fishingPorts.indexOf(doc['fishingPort']) != -1) {
          _copiedTextData += doc['fishingMethod'].toString();
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
                  innerDoc['unit'];
            });
          });
        } else {
          fishingPorts.add(doc['fishingPort']);
          _copiedTextData +=
              doc['character'].toString() + doc['fishingPort'].toString();
          _copiedTextData += doc['fishingMethod'].toString();
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
                  innerDoc['unit'];
            });
          });
        }
      } else {
        prefectures.add(doc['prefecture']);
        _copiedTextData += doc['character'].toString() +
            doc['prefecture'].toString() +
            doc['character'].toString();
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
                  innerDoc['unit'];
            });
          });
        } else {
          fishingPorts.add(doc['fishingPort']);
          _copiedTextData +=
              doc['character'].toString() + doc['fishingPort'].toString();
          _copiedTextData += doc['fishingMethod'].toString();
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
                  innerDoc['unit'];
            });
          });
        }
      }
      _copiedTextDataController.add(_copiedTextData);
      // _postDataController.add(_postData)
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
    // return Text('linePage');
    return StreamBuilder(
      stream: _copiedTextDataController.stream,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return IconButton(
            icon: Icon(Icons.content_copy),
            onPressed: () {
              _copyToClipboard(snapshot.data!.toString());
            },
          );
        } else {
          return IconButton(
            icon: Icon(Icons.content_copy),
            onPressed: () {
              _copyToClipboard('test');
            },
          );
        }
      },
    );
  }

  Widget _sashimoriPage() {
    return Text('linePage');
  }

  // Widget _linePage() {
  //   return Card(
  //     child: ListView(
  //       children: <Widget>[
  //         IconButton(
  //           icon: Icon(Icons.content_copy),
  //           onPressed: _copyToClipboard,
  //         ),
  //         Text('【' +
  //             widget.date.replaceAll('曜日', ')').replaceAll('日', '日(') +
  //             '漁獲速報】'),
  //         StreamBuilder<List<dynamic>>(
  //           stream: _postDataController.stream,
  //           builder: (context, snapshot) {
  //             if (snapshot.data != null) {
  //               print(snapshot.data);
  //               return ListView.builder(
  //                   shrinkWrap: true, //追加
  //                   physics: const NeverScrollableScrollPhysics(),
  //                   itemCount: snapshot.data!.length,
  //                   itemBuilder: (context, index) {
  //                     // return _prefectureData(context, index, snapshot);
  //                     return Text(
  //                         snapshot.data![index]['fishingPort'].toString());
  //                   });
  //             } else {
  //               print('準備中');
  //               return Text('準備中');
  //             }
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

//   Widget _sashimoriPage() {
//     return SingleChildScrollView(
//       child: Column(
//         children: <Widget>[
//           Text('【' +
//               widget.date.replaceAll('曜日', ')').replaceAll('日', '日(') +
//               '漁獲速報】'),
//           StreamBuilder<Map<String, dynamic>>(
//             stream: _postDataController.stream,
//             builder: (context, snapshot) {
//               if (snapshot.data != null) {
//                 print(snapshot.data);
//                 return ListView.builder(
//                     shrinkWrap: true, //追加
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: snapshot.data!.keys.length,
//                     itemBuilder: (context, index) {
//                       return _prefectureDataSashimori(context, index, snapshot);
//                     });
//               } else {
//                 print('準備中');
//                 return Text('準備中');
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _prefectureData(
//       BuildContext context, int index, AsyncSnapshot snapshot) {
//     String prefecture = snapshot.data!.keys.toList()[index];
//     String character = snapshot.data![prefecture]['character'];
//     return Column(
//       children: [
//         Text(character + prefecture + character),
//         ListView.builder(
//           shrinkWrap: true, //追加
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: snapshot.data![prefecture].keys.length - 1,
//           itemBuilder: (context, index) {
//             return _fishingPortData(context, index, snapshot.data![prefecture]);
//           },
//         ),
//       ],
//     );
//   }

//   Widget _prefectureDataSashimori(
//       BuildContext context, int index, AsyncSnapshot snapshot) {
//     String prefecture = snapshot.data!.keys.toList()[index];
//     return Container(
//       child: Column(
//         children: [
//           Text(prefecture),
//           ListView.builder(
//             shrinkWrap: true, //追加
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: snapshot.data![prefecture].keys.length - 1,
//             itemBuilder: (context, index) {
//               return _fishingPortDataSashimori(
//                   context, index, snapshot.data![prefecture]);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _fishingPortData(
//       BuildContext context, int index, Map dataInnerPrefecture) {
//     index += 1;
//     String character = dataInnerPrefecture['character'];
//     String fishingPort = dataInnerPrefecture.keys.toList()[index];
//     print(dataInnerPrefecture[fishingPort].keys.length);
//     return Column(
//       children: [
//         Text(character + fishingPort),
//         ListView.builder(
//           shrinkWrap: true, //追加
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: dataInnerPrefecture[fishingPort].keys.length,
//           itemBuilder: (context, index) {
//             return _fishingMethodData(
//                 context, index, dataInnerPrefecture[fishingPort]);
//           },
//         ),
//       ],
//     );
//   }

//   Widget _fishingPortDataSashimori(
//       BuildContext context, int index, Map dataInnerPrefecture) {
//     index += 1;
//     String character = dataInnerPrefecture['character'];
//     String fishingPort = dataInnerPrefecture.keys.toList()[index];
//     print(dataInnerPrefecture[fishingPort].keys.length);
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.blue.shade200),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         children: [
//           Text(character + fishingPort),
//           ListView.builder(
//             shrinkWrap: true, //追加
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: dataInnerPrefecture[fishingPort].keys.length,
//             itemBuilder: (context, index) {
//               return _fishingMethodDataSashimori(
//                   context, index, dataInnerPrefecture[fishingPort]);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _fishingMethodData(
//       BuildContext context, int index, Map dataInnerFishingPort) {
//     String fishingMethod = dataInnerFishingPort.keys.toList()[index];
//     String documentId = dataInnerFishingPort[fishingMethod].toString();
//     return Column(
//       children: [
//         Text('【' + fishingMethod + '】'),
//         _catchData(documentId),
//         Text(''),
//       ],
//     );
//   }

//   Widget _fishingMethodDataSashimori(
//       BuildContext context, int index, Map dataInnerFishingPort) {
//     String fishingMethod = dataInnerFishingPort.keys.toList()[index];
//     String documentId = dataInnerFishingPort[fishingMethod].toString();
//     return Column(
//       children: [
//         Text('【' + fishingMethod + '】'),
//         _catchDataSashimori(documentId),
//         Text(''),
//       ],
//     );
//   }

//   Widget _catchData(documentId) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('posts')
//           .doc(documentId)
//           .collection('catches')
//           .snapshots(),
//       builder: (context, snapshot) {
//         // データが取得できた場合
//         if (snapshot.hasData) {
//           final List<DocumentSnapshot> documents = snapshot.data!.docs;
//           return Column(
//             children: documents.map((document) {
//               if (document['condition'] == '鮮魚')
//                 return Text(document['species'] +
//                     document['num'].toString() +
//                     document['unit']);
//               else {
//                 return Text(document['species'] +
//                     '(' +
//                     document['condition'][0] +
//                     ')' +
//                     document['num'].toString() +
//                     document['unit']);
//               }
//             }).toList(),
//           );
//         } else {
//           return Container(child: Text('漁獲無し'));
//         }
//       },
//     );
//   }

//   Widget _catchDataSashimori(documentId) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('posts')
//           .doc(documentId)
//           .collection('catches')
//           .snapshots(),
//       builder: (context, snapshot) {
//         // データが取得できた場合
//         if (snapshot.hasData) {
//           final List<DocumentSnapshot> documents = snapshot.data!.docs;
//           return SizedBox(
//             width: 3000,
//             // constraints: BoxConstraints.expand(),
//             child: Card(
//               child: Column(
//                 children: documents.map((document) {
//                   if (document['condition'] == '鮮魚')
//                     return Text(document['species'] +
//                         document['num'].toString() +
//                         document['unit']);
//                   else {
//                     return Text(document['species'] +
//                         '(' +
//                         document['condition'][0] +
//                         ')' +
//                         document['num'].toString() +
//                         document['unit']);
//                   }
//                 }).toList(),
//               ),
//             ),
//           );
//         } else {
//           return Container(child: Text('漁獲無し'));
//         }
//       },
//     );
//   }
}
