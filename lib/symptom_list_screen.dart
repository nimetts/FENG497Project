import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SymptomListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gönderilen Semptomlar'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('symptoms')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Henüz semptom gönderilmedi.'));
          }
          final symptoms = snapshot.data!.docs;
          return ListView.builder(
            itemCount: symptoms.length,
            itemBuilder: (context, index) {
              final data = symptoms[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(
                    data['symptoms'] ?? 'Semptom bilgisi eksik',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    data['timestamp']?.toDate().toString() ?? 'Zaman bilgisi eksik',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
