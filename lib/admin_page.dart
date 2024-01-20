import 'package:flutter/material.dart';
import 'add_country_page.dart';
import 'remove_country_page.dart';
import 'edit_country_page.dart';

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: (){
              // TODO
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20,),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: (){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AddCountry(),)
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Country", style: TextStyle(fontSize: 18),),
              ),
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: (){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const RemoveCountry(),)
                  );
                },
                icon: const Icon(Icons.delete),
                label: const Text("Remove Country", style: TextStyle(fontSize: 18),),
              ),
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: (){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const EditCountry(),)
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit Country", style: TextStyle(fontSize: 18),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
