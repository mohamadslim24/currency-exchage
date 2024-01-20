import 'package:currency_exchange/my_widgets.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final formKey = GlobalKey<FormState>();
  String? fname, lname, email, password, rpassword;

  String? validateName(String name){
    name = name.trim();
    if(name.length < 3){
      return "At least 3 characters!";
    }

    for(int ascii in name.toUpperCase().codeUnits){
      if((ascii < 65 || ascii > 90) && ascii != 32){
        return "alphabetical and spaces only!";
      }
    }
    return null;
  }

  bool validateEmail(String email){
    final parts = email.split("@");
    if(parts.length != 2) return false;
    final usernamePart = parts[0];
    if(usernamePart.isEmpty) return false;
    if(usernamePart.startsWith(".") || usernamePart.endsWith(".")) return false;
    final domainPart = parts[1];
    bool isDot = false;
    for(int ascii in usernamePart.toLowerCase().codeUnits){
      if(ascii < 46) return false;
      if(ascii > 46 && ascii < 48) return false;
      if(ascii > 57 && ascii < 97) return false;
      if(ascii > 122) return false;

      if(ascii == 46){
        if(isDot) return false;
        isDot = true;
      }
      else {
        isDot = false;
      }
    }
    final domains = domainPart.split(".");
    if(domains.length < 2) return false;
    for(String domain in domains){
      if(domain.isEmpty) return false;
      for(int ascii in domain.toLowerCase().codeUnits){
        if(ascii < 48) return false;
        if(ascii > 57 && ascii < 97) return false;
        if(ascii > 122) return false;
      }
    }
    return true;
  }

  String? validatePassword(String password){
    if(password.length < 8) return "At least 8 characters";
    int uppers = 0, lowers = 0, numbers = 0, symbols = 0;
    for(int ascii in password.codeUnits){
      if(ascii >= 48 && ascii <= 57) { numbers++; }
      else if(ascii >= 41 && ascii <= 90) { uppers++; }
      else if(ascii >= 97 && ascii <= 122) { lowers++; }
      else { symbols++; }
    }
    if(uppers == 0) return "At least one capital letter!";
    if(lowers == 0) return "At least one small letter!";
    if(numbers == 0) return "At least one number!";
    if(symbols == 0) return "At least one symbol!";

    this.password = password;
    return null;
  }

  void insertUser(Function(bool success) update) async{
    try{
      final url = Uri.https("currencies-exchange.000webhostapp.com", "insertUser.php");
      final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: convert.jsonEncode(<String, String>{
            'fname': '$fname', 'lname': '$lname', 'email': '$email', 'password': '$password'
          })).timeout(const Duration(seconds: 10));
      if(response.statusCode == 200){
        update(true);
      }
    }catch(e){
      update(false);
    }
  }

  void update(bool success){
    if(success){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully added user'), backgroundColor: Colors.indigo,));
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const Login(),)
      );
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add user')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: 250,
                      child: MyTextFormField(
                        inputBorder: const OutlineInputBorder(),
                        keyboardType: TextInputType.text,
                        hintText: "Enter First Name:",
                        onSaved: (value) => setState(() => fname = value!.trim()),
                        validator: (value){
                          if(value == null || value.isEmpty) {
                            return "Required!";
                          }
                          return validateName(value);
                        },
                      ),
                    ),
                    const SizedBox(height: 18,),
                    SizedBox(
                      width: 250,
                      child: MyTextFormField(
                        inputBorder: const OutlineInputBorder(),
                        keyboardType: TextInputType.text,
                        hintText: "Enter Last Name:",
                        onSaved: (value) => setState(() => lname = value!.trim()),
                        validator: (value){
                          if(value == null || value.isEmpty) {
                            return "Required!";
                          }
                          return validateName(value);
                        },
                      ),
                    ),
                    const SizedBox(height: 18,),
                    SizedBox(
                      width: 250,
                      child: MyTextFormField(
                        inputBorder: const OutlineInputBorder(),
                        keyboardType: TextInputType.emailAddress,
                        hintText: "Enter Email:",
                        onSaved: (value) => setState(() => email = value!.trim()),
                        validator: (value){
                          if(value == null || value.isEmpty) {
                            return "Required!";
                          }
                          return validateEmail(value) ? null : "Invalid Email";
                        },
                      ),
                    ),
                    const SizedBox(height: 18,),
                    SizedBox(
                      width: 250,
                      child: MyTextFormField(
                        inputBorder: const OutlineInputBorder(),
                        keyboardType: TextInputType.text,
                        hintText: "Enter Password:",
                        onSaved: (value) => setState(() => password = value),
                        validator: (value){
                          if(value == null || value.isEmpty) {
                            return "Required!";
                          }
                          return validatePassword(value);
                        },
                      ),
                    ),
                    const SizedBox(height: 18,),
                    SizedBox(
                      width: 250,
                      child: MyTextFormField(
                        inputBorder: const OutlineInputBorder(),
                        keyboardType: TextInputType.text,
                        hintText: "Repeat Password:",
                        onSaved: (value) => setState(() => rpassword = value),
                        validator: (value){
                          if(value == null || value.isEmpty) {
                            return "Required!";
                          }
                          return value == password ? null : "Passwords do not match!";
                        },
                      ),
                    ),
                    const SizedBox(height: 14,),
                    ElevatedButton( // TODO: ~BONUS~ add padding to the button.
                      onPressed: (){
                        final isValid = formKey.currentState!.validate();
                        if(isValid){
                          formKey.currentState!.save();
                          insertUser(update);
                        }
                      },
                      child: const Text("Signup", style: TextStyle(fontSize: 20),),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 200,
                child: Divider(
                  color: Colors.blueGrey,
                  thickness: 2,
                ),
              ),
              const SizedBox(height: 18,),
              const Text("Own an account already?", style: TextStyle(fontSize: 18),),
              const SizedBox(height: 5,),
              TextButton(
                onPressed: (){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Login(),)
                  );
                },
                child: const Text("Login", style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
