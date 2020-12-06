import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateCollection {
  CollectionReference _update = Firestore.instance.collection('update');
  Stream<List<Map<String, dynamic>>> getUpdates() {
    print('Getting Updates');
    return _update.orderBy('date', descending: true).snapshots().map(fromQSS);
  }

  List<Map<String, dynamic>> fromQSS(QuerySnapshot querySnapshot) {
    print('QSS ${querySnapshot.documents.length}');
    return querySnapshot.documents.map((e) => e.data).toList();
  }

  UpdateModel fromDocSnap(DocumentSnapshot dss) {
    print(dss.data);
    return UpdateModel(dss.data);
  }
}

class UpdateModel {
  String title, desc;
  List<String> links;
  Timestamp date;

  UpdateModel(Map<String, dynamic> map) {
    title = map['title'];
    desc = map['desc'];
    links = map['links'];
    date = map['date'];
  }

  @override
  String toString() {
    return 'Title : $title Desc : $desc Links : $links Date : $date';
  }
}
