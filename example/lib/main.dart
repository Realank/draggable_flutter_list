import 'package:flutter/material.dart';
import 'package:draggable_flutter_list/draggable_flutter_list.dart';

void main() {
  runApp(new TestApp());
}

class TestApp extends StatelessWidget {
  TestApp({Key key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: new MyHomePage(
        title: 'Flutter Demo Home Page',
        key: key,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  MyHomePageState createState() => new MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  List<String> items = [
    '0',
    '1sfsdfdsfdsfsafafsafdsafsadfdsfdsfsafafsafdsafsadfdsfdsfsafafsafdsafsadfdsfdsfsafafsafdsafsadfdsfdsfsafafsafdsafsadfdsfdsfsafafsafdsafsadfdsfdsfsafafsafdsafsadfdsfdsfsafafsafdsafsadfdsfdsfsafafsafdsafsadfdsfdsfsafafsafdsafsadfdsfdsfsafafsafdsafsadfsadf',
    'd'
  ];
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new DragAndDropList(
        items.length,
        itemBuilder: (BuildContext context, index) {
          return new SizedBox(
            child: new Card(
              child: new ListTile(
                title: new Text(items[index]),
              ),
            ),
          );
        },
        onDragFinish: (before, after) {
          String data = items[before];
          items.removeAt(before);
          items.insert(after, data);
        },
        canDrag: (index) {
          return index < 5; //disable drag for index 3
        },
        canBeDraggedTo: (from, to) {
          return to < 5;
        },
        dragElevation: 8.0,
      ),
    );
  }
}
