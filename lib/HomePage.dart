import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'BiodataService.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Panggil Model
  Biodataservice? service;
  String? selectedDocId;
  @override
  void initState() {
    service = Biodataservice(db: FirebaseFirestore.instance);
    super.initState();
  }

  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final addressController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  prefixIcon: Icon(Icons.elderly),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: service?.getBiodata(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.connectionState == ConnectionState.none) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Error Fetching data: ${snapshot.data}");
                    } else if (snapshot.hasData &&
                        snapshot.data?.docs.isEmpty == true) {
                      return Text("No biodata found");
                    }

                    final documents = snapshot.data?.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: documents?.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(documents?[index]['name']),
                          subtitle: Text(documents?[index]['age']),
                          onTap: () {
                            nameController.text = documents?[index]['name'];
                            ageController.text = documents?[index]['age'];
                            addressController.text =
                                documents?[index]['address'];
                            selectedDocId = documents?[index].id;
                          },
                          trailing: IconButton(
                            onPressed: () {
                              if (documents?[index].id != null) {
                                service?.delete(documents![index].id);
                              }
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          final Name = nameController.text.trim();
          final Age = ageController.text.trim();
          final Address = addressController.text.trim();

          if (selectedDocId != null) {
            service?.update(
                selectedDocId!, {'name': Name, 'age': Age, 'address': Address});
          } else {
            service?.add({'name': Name, 'age': Age, 'address': Address});
          }

          if (Name.isEmpty || Age.isEmpty || Address.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All fields must be filled")));
            return;
          }
        },
      ),
    );
  }
}
