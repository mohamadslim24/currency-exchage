import 'dart:ffi';

import 'package:flutter/material.dart';
import 'my_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

final countryFields = ["countryName", "currencyCode", "ratioFromUSD", "ratioToUSD", "flagUnicode"];

class EditCountry extends StatefulWidget {
  const EditCountry({super.key});

  @override
  State<EditCountry> createState() => _EditCountryState();
}

class _EditCountryState extends State<EditCountry> {
  final formKey = GlobalKey<FormState>();
  String? id, newVal;
  String currentField = countryFields.first;

  String? validateId(String input){
    int? id = int.tryParse(input);
    if(id == null) return "Invalid ID!";
    if(id <= 0) return "ID musst be positive";
    return null;
  }

  String? validateNewVal(String value){
    switch(currentField){
      case "countryName":
        return validateCountryName(value);
        break;
      case "currencyCode":
        return validateCurrencyCode(value);
        break;
      case "ratioFromUSD":
      case "ratioToUSD":
        return validateRatio(value);
        break;
      case "flagUnicode":
        return validateFlagUnicode(value);
        break;
      default:
        throw Exception("Incorrect argument value given");
    }
  }

  String? validateCountryName(String name){
    name = name.trim().toLowerCase();
    if(name.length < 3) return "Name is too short";
    for(int ascii in name.codeUnits){
      if(ascii != 32 && (ascii < 97 || ascii > 122)) return "Alghabetic only or spaces";
    }
    return null;
  }

  String? validateCurrencyCode(String code){
    code = code.trim().toLowerCase();
    if(code.length < 3) return "Code is too short";
    for(int ascii in code.codeUnits){
      if(ascii < 97 || ascii > 122) return "Alghabetic only";
    }
    return null;
  }

  String? validateRatio(String ratio){
    double? ratioVal = double.tryParse(ratio);
    if(ratioVal == null) return "Ratio From USD is invalid!";
    if(ratioVal < 0) return "Negative value given!";
    return null;
  }

  String? validateFlagUnicode(String flagUnicode){
    flagUnicode = flagUnicode.trim().toLowerCase();
    // TODO: ~BONUS~ validate unicode with the exact correct pattern.
    if(flagUnicode.length < 9) return "Flag unicde is too short";
    for(int ascii in flagUnicode.codeUnits){
      if((ascii < 97 || ascii > 122) && (ascii < 48 && ascii > 57) && ascii != 92 && ascii != 123 && ascii != 125) return "Invalid Flag Unicode!";
    }
    return null;
  }

  void editCountry(Function(bool success) update) async{
    try{
      final url = Uri.https("currencies-exchange.000webhostapp.com", "editCountry.php");
      final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: convert.jsonEncode(<String, String>{
            'id':'$id', 'field':currentField, 'newVal': '$newVal'
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully editted country'), backgroundColor: Colors.indigo,));
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to edit country')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Country"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: 250,
                    child: MyTextFormField(
                      inputBorder: const OutlineInputBorder(),
                      keyboardType: TextInputType.number,
                      hintText: "Enter country ID:",
                      onSaved: (value) => setState(() => id = value),
                      validator: (value){
                        if(value == null || value.isEmpty) return "Required!";
                        return validateId(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 18,),
                  MyDropDownMenu(
                    list: countryFields,
                    initialSelection: countryFields.first,
                    action: (field) => currentField = field!,
                  ),
                  const SizedBox(height: 18,),
                  SizedBox(
                    width: 250,
                    child: MyTextFormField(
                      inputBorder: const OutlineInputBorder(),
                      keyboardType: TextInputType.number,
                      hintText: "Enter new value:",
                      onSaved: (value) => setState(() => newVal = value),
                      validator: (value){
                        if(value == null || value.isEmpty) return "Required!";
                        return validateNewVal(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16,),
                  ElevatedButton.icon(
                    label: const Text("Edit", style: TextStyle(fontSize: 18),),
                    icon: const Icon(Icons.edit),
                    onPressed: (){
                      final isValid = formKey.currentState!.validate();
                      if(isValid){
                        formKey.currentState!.save();
                        editCountry(update);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
