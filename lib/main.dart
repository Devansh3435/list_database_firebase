import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
} 

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore List App',
      home: ListScreen(),
    );
  }
}

class ListScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final firestoreInstance = FirebaseFirestore.instance;

  void addListItem(String title, String description) {
    firestoreInstance.collection("lists").doc("myList").update({
      "data": FieldValue.arrayUnion([{"title": title, "description": description}])
    });
  }

  void deleteList() {
    firestoreInstance.collection("lists").doc("myList").delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore List'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              deleteList();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: firestoreInstance.collection('lists').doc('myList').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator()); // Loading indicator while fetching data
                }

                var listData = snapshot.data!.data() as Map<String, dynamic>;
                var dataItems = listData['data'] as List<dynamic>;

                return ListView.builder(
                  itemCount: dataItems.length,
                  itemBuilder: (context, index) {
                    var item = dataItems[index];
                    return ListTile(
                      title: Text(item['title']),
                      subtitle: Text(item['description']),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String title = _titleController.text;
                    String description = _descriptionController.text;
                    if (title.isNotEmpty && description.isNotEmpty) {
                      addListItem(title, description);
                      _titleController.clear();
                      _descriptionController.clear();
                    }
                  },
                  child: Text('Add Item'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
