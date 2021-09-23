import 'package:flutter/material.dart';
import 'chicken_lib.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'O2P',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'O2P'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);


  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  List<Chicken> chickens = List.empty(growable: true);


  void addChicken(Chicken? chicken){
    setState(
      () {
        if (chicken != null){ 
          chickens.add(chicken);
        }
        }
    );
  }

  void delChicken(String name){
    setState(
      () => chickens.removeWhere((element) => element.name == name)  
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: chickens
            .map((e) => chickenListItem(context, e))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
            context: context, 
            builder: (context) => chickenAddDialog(context)
          ).then((value) => addChicken(value)),
        tooltip: 'New chicken',
        child: const Icon(Icons.add),
      ), 
    );
  }

  Widget chickenListItem(BuildContext context, Chicken chicken){
  return Card(
    child: ListTile(
      title: Text(chicken.name),
      onLongPress: () => showDialog(
        context: context,
        builder: (context) =>  AlertDialog(
          title:  Text("Delete chicken ${chicken.name} ?"),
          actions:[
            ElevatedButton(
              onPressed: () => Navigator.pop(context,true), 
              child: const Text('Yes')
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context,false), 
              child: const Text('No')
            )
          ]
        )
      )
      .then((value) {if (value) delChicken(chicken.name);}),
    )
  );
}

}
