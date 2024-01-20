import 'package:flutter/material.dart';
import 'my_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class AddCountry extends StatefulWidget {
  const AddCountry({super.key});

  @override
  State<AddCountry> createState() => _AddCountryState();
}

class _AddCountryState extends State<AddCountry> {
  final formKey = GlobalKey<FormState>();
  String? countryName, currencyCode, flagUnicode, ratioFrom, ratioTo;

  // Country name must be alghabetic. Spaces are allowed.
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

  void insertCountry(Function(bool success) update) async{
    try{
      final url = Uri.https("currencies-exchange.000webhostapp.com", "insertCountry.php");
      final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: convert.jsonEncode(<String, String>{
            'countryName':'$countryName', 'currencyCode':'$currencyCode', 'ratioFrom':'$ratioFrom', 'ratioTo': '$ratioTo', 'flagUnicode':'$flagUnicode'
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully added Country'), backgroundColor: Colors.indigo,));
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add Country')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Country"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20,),
                SizedBox(
                  width: 250,
                  child: MyTextFormField(
                    keyboardType: TextInputType.text,
                    inputBorder: const OutlineInputBorder(),
                    hintText: "Enter Country Name:",
                    onSaved: (value) => setState(() => countryName = value),
                    validator: (value){
                      if(value == null || value.isEmpty) return "Required!";
                      return validateCountryName(value);
                    },
                  ),
                ),
                const SizedBox(height: 16,),
                SizedBox(
                  width: 250,
                  child: MyTextFormField(
                    keyboardType: TextInputType.text,
                    inputBorder: const OutlineInputBorder(),
                    hintText: "Enter Currency Code:",
                    onSaved: (value) => setState(() => currencyCode = value),
                    validator: (value){
                      if(value == null || value.isEmpty) return "Required!";
                      return validateCurrencyCode(value);
                    },
                  ),
                ),
                const SizedBox(height: 16,),
                SizedBox(
                  width: 250,
                  child: MyTextFormField(
                    keyboardType: TextInputType.number,
                    inputBorder: const OutlineInputBorder(),
                    hintText: "Enter Ratio From USD:",
                    onSaved: (value) => setState(() => ratioFrom = value),
                    validator: (value){
                      if(value == null || value.isEmpty) return "Required!";
                      return validateRatio(value);
                    },
                  ),
                ),
                const SizedBox(height: 16,),
                SizedBox(
                  width: 250,
                  child: MyTextFormField(
                    keyboardType: TextInputType.number,
                    inputBorder: const OutlineInputBorder(),
                    hintText: "Enter Ratio To USD:",
                    onSaved: (value) => setState(() => ratioTo = value),
                    validator: (value){
                      if(value == null || value.isEmpty) return "Required!";
                      return validateRatio(value);
                    },
                  ),
                ),
                const SizedBox(height: 16,),
                SizedBox(
                  width: 250,
                  child: MyTextFormField(
                    keyboardType: TextInputType.text,
                    inputBorder: const OutlineInputBorder(),
                    hintText: "Enter Flag Unicode:",
                    onSaved: (value) => setState(() => flagUnicode = value),
                    validator: (value){
                      if(value == null || value.isEmpty) return "Required!";
                      return validateFlagUnicode(value);
                    },
                  ),
                ),
                const SizedBox(height: 18,),
                ElevatedButton.icon(
                  onPressed: (){
                    final isValid = formKey.currentState!.validate();
                    if(isValid){
                      formKey.currentState!.save();
                      insertCountry(update);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add", style: TextStyle(fontSize: 18),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
