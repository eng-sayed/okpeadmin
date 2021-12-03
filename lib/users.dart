import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:okpeadmin/chat_screen.dart';
import 'package:okpeadmin/datetime_handler.dart';
import 'package:okpeadmin/provider/selector.dart';
import 'package:okpeadmin/services/custom_user_model.dart';
import 'package:okpeadmin/services/firebase.dart';
import 'package:okpeadmin/widgets.dart';
import 'package:provider/provider.dart';

class UsersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DeleteWidget(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
              stream: getUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final list = snapshot.data.docs
                    .map((e) => User.fromMap(e.data()))
                    .toList();
                return ListView.builder(
                  key: Key("${Random().nextDouble()}"),
                  itemBuilder: (context, index) {
                    return listBuilder(
                      user: list[index],
                    );
                  },
                  itemCount: list.length,
                );
              }),
        ),
      ],
    );
  }
}

class listBuilder extends StatefulWidget {
  listBuilder({Key key, this.user}) : super(key: key);
  User user;
  @override
  _listBuilderState createState() => _listBuilderState();
}

class _listBuilderState extends State<listBuilder> {
  User user;
  bool selected = false;

  @override
  void initState() {
    // TODO: implement initState
    user = widget.user;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      selected = Provider.of<SelectorProvider>(context, listen: false)
          .selectToDelete
          .any((element) => element.id == user.id);
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SelectorProvider>(context, listen: false);
    return ListTile(
      onLongPress: () {
        selectChat(provider);
      },
      selected: selected,
      leading: CircleAvatar(
        backgroundColor:
            Colors.primaries[min(user.firstName.characters.length, 17)],
        child: selected
            ? Icon(Icons.check)
            : Text(user.firstName.characters.first.toUpperCase()),
      ),
      title: Text(user.firstName),
      subtitle: Text(user.lastMessege),
      trailing: Text(dateNow(user.updatedAt)),
      tileColor: user.seen ? Colors.transparent : Colors.blue.withOpacity(0.2),
      onTap: () {
        provider.selectToDelete.isNotEmpty
            ? selectChat(provider)
            : navto(ChatScreen(user: user), context);
      },
    );
  }

  void selectChat(SelectorProvider provider) {
    if (selected) {
      final selectedUser = provider.selectToDelete
          .firstWhere((element) => user.id == element.id);
      selected = false;
      provider.selectToDelete.remove(selectedUser);
      setState(() {});
      provider.notifyListeners();
    } else {
      selected = true;
      provider.selectToDelete.add(user);
      setState(() {});
      provider.notifyListeners();
    }
  }
}

class DeleteWidget extends StatefulWidget {
  DeleteWidget({Key key}) : super(key: key);

  @override
  _DeleteWidgetState createState() => _DeleteWidgetState();
}

class _DeleteWidgetState extends State<DeleteWidget> {
  @override
  Widget build(BuildContext context) {
    return Provider.of<SelectorProvider>(context).selectToDelete.isEmpty
        ? SizedBox()
        : IconButton(
            onPressed: () async {
              deleteDialog(context);
            },
            icon: Icon(Icons.delete),
          );
  }
}

Future<void> deleteDialog(BuildContext context) async {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Do you want to delete those chats?"),
          actions: [
            TextButton(
              onPressed: () async {
                Provider.of<SelectorProvider>(context, listen: false)
                    .selectToDelete
                    .forEach((user) async {
                  await deleteChat(user.id);
                  Provider.of<SelectorProvider>(context, listen: false)
                      .selectToDelete = [];
                  Provider.of<SelectorProvider>(context, listen: false)
                      .notifyListeners();
                });

                Navigator.pop(context);
              },
              child: Text("Yes"),
            ),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("No")),
          ],
        );
      });
}
