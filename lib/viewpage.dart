import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'DBHelper.dart';
import 'insertpage.dart';

class viewpage extends StatefulWidget {
  const viewpage({Key? key}) : super(key: key);

  @override
  State<viewpage> createState() => _viewpageState();
}

class _viewpageState extends State<viewpage> {
  List<Map<String, Object?>> l = List.empty(growable: true);
  List<Map<String, Object?>> s = List.empty(growable: true);

  bool status = false;
  Database? db;

  @override
  void initState() {
    super.initState();
    getAllData();
  }

  getAllData() async {
    db = await DBHelper().createDtatabase();

    String qry = "SELECT * FROM Test ";
    List<Map<String, Object?>> x = await db!.rawQuery(qry);
    l.addAll(x);
    print(l);

    l.sort(
      (a, b) => a['name'].toString().compareTo(b['name'].toString()),
    );
    s.addAll(l);

    status = true;
    setState(() {});
  }

  bool search = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: search
          ? AppBar(
              title: TextField(
                onChanged: (value) {
                  s.clear();
                  if (value.isEmpty) {
                    s.addAll(l);
                  } else {
                    for (int i = 0; i < l.length; i++) {
                      if (l[i]['name']
                              .toString()
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          l[i]['contact'].toString().contains(value)) {
                        s.add(l[i]);
                      }
                    }
                  }
                  setState(() {});
                },
                autofocus: true,
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        search = false;
                        s.clear();
                        s.addAll(l);
                      });
                    },
                    icon: Icon(Icons.close))
              ],
            )
          : AppBar(
              title: Text("Contact Book"),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        search = true;
                      });
                    },
                    icon: Icon(Icons.search))
              ],
            ),
      body: status
            ? (search
              ? (s.length > 0
                  ? ListView.builder(
                      itemCount: s.length,
                      itemBuilder: (context, index) {
                        Map m = s[index];

                        return ListTile(
                          onLongPress: () {
                            showDialog(
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Delete"),
                                    content: Text(
                                        "are you sure want to delete this contact"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            int id = m['id'];
                                            String q =
                                                "DELETE FROM Test WHERE  id= '$id'";
                                            db!.rawDelete(q).then(
                                              (value) {
                                                l.removeAt(index);
                                                setState(() {});
                                              },
                                            );
                                          },
                                          child: Text("Yes")),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("No"))
                                    ],
                                  );
                                },
                                context: context);
                          },
                          leading: Text("${m['name'].toString().split("")[0]}"),
                          title: Text("${m['name']}"),
                          subtitle: Text("${m['contact']}"),
                          trailing: IconButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return insertpage(
                                      "update",
                                      map: m,
                                    );
                                  },
                                ));
                              },
                              icon: Icon(Icons.edit)),
                        );
                      },
                    )
                      : Center(child: Text("No Data Found")))
                        : (l.length > 0
                          ? ListView.builder(
        itemCount: l.length,
        itemBuilder: (context, index) {
          Map m = l[index];

          return ListTile(
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Delete"),
                    content: Text(
                        "are you sure want to delete this contact"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            int id = m['id'];
                            String q =
                                "DELETE FROM Test WHERE  id= '$id'";
                            db!.rawDelete(q).then(
                                  (value) {
                                l.removeAt(index);
                                setState(() {});
                              },
                            );
                          },
                          child: Text("Yes")),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("No"))
                    ],
                  );
                },
              );
            },
            leading:
            Text("${m['name'].toString().split("")[0]}"),
            title: Text("${m['name']}"),
            subtitle: Text("${m['contact']}"),
            trailing: IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return insertpage(
                        "update",
                        map: m,
                      );
                    },
                  ));
                },
                icon: Icon(Icons.edit)),
          );
        },
      )
              : Center(child: Text("No Data Found"))))
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return insertpage("insert");
            },
          ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
