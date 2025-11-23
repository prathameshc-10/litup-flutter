import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Party {
  final String id;
  final String time;
  final String title;
  final String host; // keep this for display after fetching username
  final String dateTime;
  final String imageUrl;
  final bool rsvped;
  final List<IconData> tags;
  final String? message;
  final String createdBy; 

  Party({
    required this.id,
    this.dateTime = "Date not defined",
    this.time = "time not defined",
    required this.title,
    this.host = "Host not defined",
    required this.imageUrl,
    this.rsvped = false,
    this.tags = const [],
    this.message,
    this.createdBy = "",
  });

  factory Party.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Party(
      id: doc.id,
      title: data['name'] ?? 'Unnamed Party',
      dateTime: data['date'] ?? 'Date not set',
      time: data['time'] ?? 'Time not set',
      host: data['hostName'] ?? 'Unknown Host',
      imageUrl: data['posterUrl'] ?? '',
      createdBy: data['createdBy'] ?? '',
    );
  }

  factory Party.fromMap(Map<String, dynamic> map) {
    return Party(
      id: map['id'],
      title: map['name'] ?? '',
      host: map['host'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      dateTime: map['dateTime'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': title,
      'host': host,
      'imageUrl': imageUrl,
      'dateTime': dateTime,
    };
  }
}
