import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/all_constants.dart';

class ChatUser extends Equatable {
  final String id;
  final String photoUrl;
  final String displayName;
  final String aboutMe;
  final String email;

  const ChatUser(
      {required this.id,
      required this.photoUrl,
      required this.displayName,
      required this.aboutMe,
      required this.email});

  ChatUser copyWith({
    String? id,
    String? photoUrl,
    String? nickname,
    String? statue,
    String? gmail,
  }) =>
      ChatUser(
          id: id ?? this.id,
          photoUrl: photoUrl ?? this.photoUrl,
          displayName: nickname ?? displayName,
          aboutMe: statue ?? aboutMe,
          email: gmail ?? email);

  Map<String, dynamic> toJson() => {
        FirestoreConstants.displayName: displayName,
        FirestoreConstants.photoUrl: photoUrl,
        FirestoreConstants.aboutMe: aboutMe,
        FirestoreConstants.email: email,
      };
  factory ChatUser.fromDocument(DocumentSnapshot snapshot) {
    String photoUrl = "";
    String nickname = "";
    String email = "";
    String aboutMe = "";

    try {
      photoUrl = snapshot.get(FirestoreConstants.photoUrl);
      nickname = snapshot.get(FirestoreConstants.displayName);
      email = snapshot.get(FirestoreConstants.email);
      aboutMe = snapshot.get(FirestoreConstants.aboutMe);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return ChatUser(
        id: snapshot.id,
        photoUrl: photoUrl,
        displayName: nickname,
        aboutMe: aboutMe,
        email: email);
  }

  @override
  List<Object?> get props => [id, photoUrl, displayName, aboutMe, email];
}
