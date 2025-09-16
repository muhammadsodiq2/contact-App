import 'package:contact_app/src/madel/contact_madel.dart';
import 'package:flutter/material.dart';

import '../../dataBase/data_base_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ContactMadel> contacts = [];

  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  Future refreshContacts() async {
    final data = await DatabaseHelper.instance.readAllContacts();
    setState(() => contacts = data);
  }

  void _addContact() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Yangi contact qo'shish"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Ism")),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: "Telefon")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Bekor qilish")),
          ElevatedButton(
              onPressed: () async {
                await DatabaseHelper.instance.create(ContactMadel(
                  name: nameController.text,
                  phone: phoneController.text,
                ));
                Navigator.pop(context);
                refreshContacts();
              },
              child: Text("Saqlash"))
        ],
      ),
    );
  }

  void _editContact(ContactMadel contact) async {
    final nameController = TextEditingController(text: contact.name);
    final phoneController = TextEditingController(text: contact.phone);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Contactni tahrirlash"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Ism")),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: "Telefon")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Bekor qilish")),
          ElevatedButton(
              onPressed: () async {
                await DatabaseHelper.instance.update(ContactMadel(
                  id: contact.id,
                  name: nameController.text,
                  phone: phoneController.text,
                ));
                Navigator.pop(context);
                refreshContacts();
              },
              child: Text("Yangilash"))
        ],
      ),
    );
  }

  void _deleteContact(int id) async {
    await DatabaseHelper.instance.delete(id);
    refreshContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contacts")),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final c = contacts[index];
          return ListTile(
            title: Text(c.name),
            subtitle: Text(c.phone),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editContact(c);
                } else if (value == 'delete') {
                  _deleteContact(c.id!);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Edit"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Delete"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        child: Icon(Icons.add),
      ),
    );
  }
}
