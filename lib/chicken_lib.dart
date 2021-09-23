import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Chicken{

  String name;
  int eggsCount;

  Chicken(this.name,this.eggsCount);

  void addEggs(){
    eggsCount++;
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
                    validator: (value){
                      if (value == null || value.isEmpty){
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
                  if(formKey.currentState!.validate()){
                    Chicken chicken = Chicken(controller.text,0);
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



