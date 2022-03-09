import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class Chicken {
  String id;
  String name;
  int eggsCount;

  Chicken(this.id, this.name, this.eggsCount);

  factory Chicken.fromJson(Map<String, dynamic> data) {
    return Chicken(
        data['id'] as String, data['name'] as String, data['eggsCount'] as int);
  }

  void addEggs() {
    eggsCount++;
  }
}

class ChickenListWidget extends StatefulWidget {
  const ChickenListWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChickenHomeWidgetState();
}

class _ChickenHomeWidgetState extends State<ChickenListWidget> {
  List<Chicken> chickens = List.empty(growable: true);

  void delChicken(String name) {
    setState(() => chickens.removeWhere((element) => element.name == name));
  }

  @override
  initState() {
    super.initState();
    _getAllChickens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
          children: chickens.map((e) => chickenListItem(context, e)).toList()),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
                context: context,
                builder: (context) => chickenAddDialog(context))
            .then((value) => _addChicken(value)),
        tooltip: 'New chicken',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget chickenListItem(BuildContext context, Chicken chicken) {
    return Card(
        child: ListTile(
      title: Text(chicken.name),
      onLongPress: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text("Delete chicken ${chicken.name} ?"),
                  actions: [
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Yes')),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('No'))
                  ])).then((value) {
        if (value) delChicken(chicken.name);
      }),
    ));
  }

  _getAllChickens() async {
    String graphqlRequest = '''query MyQuery {
          getAll {
            id
            eggsCount
            name
          }
        }''';
    List<Chicken> list = List.empty();
    try {
      GraphQLOperation operation = Amplify.API.query(
          request: GraphQLRequest<String>(
              document: graphqlRequest,
              apiName: "appsync-api_AMAZON_COGNITO_USER_POOLS"));
      var response = await operation.response;
      Map<String, dynamic> value = jsonDecode(response.data);
      List<dynamic> getAllResponse = value['getAll'] as List<dynamic>;

      setState(() {
        chickens =
            getAllResponse.map((data) => Chicken.fromJson(data)).toList();
      });
    } catch (error) {
      print("getAll graphql request failed");
      print(error);
    }
  }

  void _addChicken(Chicken? chicken) async {
    String graphQLDocument = '''
    mutation chicken(\$id:ID!,\$eggsCount:Int,\$name:String!) {
      create(chicken: {
        id: \$id,
        eggsCount:\$eggsCount,
        name:\$name
      }) 
      {
        id
        eggsCount
        name
      }
    }''';
    if (chicken != null) {
      try {
        var operation = Amplify.API.mutate(
            request: GraphQLRequest<String>(
          document: graphQLDocument,
          apiName: "appsync-api_AMAZON_COGNITO_USER_POOLS",
          variables: {
            'id': chicken.id,
            'name': chicken.name,
            'eggsCount': chicken.eggsCount,
          },
        ));
        var response = await operation.response;
        print(response.data);
        if (response.errors.isEmpty) {
          setState(() => chickens.add(chicken));
        }
      } catch (error) {
        print("create graphql request failed");
        print(error);
      }
    }
  }
}

Widget chickenAddDialog(BuildContext context) {
  final TextEditingController controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
            title: const Text('New chicken'),
            content: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Name'),
                  TextFormField(
                    controller: controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter some text";
                      }
                      return null;
                    },
                  )
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Add'),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Chicken chicken = Chicken(Uuid().v1(), controller.text, 0);
                    Navigator.pop(context, chicken);
                  }
                },
              ),
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ));
}
