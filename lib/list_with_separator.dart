import 'package:flutter/material.dart';

import 'contact.dart';

class LongListWithSeparator extends StatelessWidget {
  List<Contact> listOfItems = [];

  LongListWithSeparator({super.key, required this.listOfItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.separated(
        itemCount: listOfItems.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () {
              print('Clicked on item #$index'); // Print to console
            },
            title: Text(listOfItems[index].fullName),
            subtitle: Text(
                '${listOfItems[index].email} ${listOfItems[index].phoneNumber}'),
            leading: Container(
              height: 50,
              width: 50,
              color: listOfItems[index].friend ? Colors.green : Colors.amber,
            ),
            trailing: const Icon(Icons.edit),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      ),
    );
  }
}
