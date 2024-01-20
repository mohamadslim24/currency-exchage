import 'package:flutter/material.dart';
import 'my_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class RemoveCountry extends StatefulWidget {
  const RemoveCountry({super.key});

  @override
  State<RemoveCountry> createState() => _RemoveCountryState();
}

class _RemoveCountryState extends State<RemoveCountry> {
  final formKey = GlobalKey<FormState>();
  String? id;

  String? validateId(String input){
    int? id = int.tryParse(input);
    if(id == null) return "Invalid ID!";
    if(id <= 0) return "ID musst be positive";
    return null;
  }

  void deleteCountry(Function(bool success) update) async{
    try{
      final url = Uri.https("currencies-exchange.000webhostapp.com", "deleteCountry.php");
      final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: convert.jsonEncode(<String, String>{
            'id':'$id'
          })).timeout(const Duration(seconds: 5));
      if(response.statusCode == 200){
        update(true);
      }
      else {
        update(false);
      }
    }catch(e){
      update(false);
    }
  }

  void update(bool success){
    if(success){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted country'), backgroundColor: Colors.indigo,));
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete country')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Remove Country"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20,),
                SizedBox(
                  width: 250,
                  child: MyTextFormField(
                    hintText: "Enter Country ID:",
                    keyboardType: TextInputType.number,
                    inputBorder: const OutlineInputBorder(),
                    onSaved: (value) => setState(() => id = value),
                    validator: (value){
                      if(value == null || value.isEmpty) return "Required!";
                      return validateId(value);
                    }
                  ),
                ),
                const SizedBox(height: 16,),
                ElevatedButton.icon(
                  onPressed: (){
                    final isValid = formKey.currentState!.validate();
                    if(isValid){
                      formKey.currentState!.save();
                      deleteCountry(update);
                    }
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text("Remove", style: TextStyle(fontSize: 18),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
