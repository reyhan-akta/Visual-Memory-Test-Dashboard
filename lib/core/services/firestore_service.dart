import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{

  FirestoreService._internal();

  static final  FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get db => _firestore;

}