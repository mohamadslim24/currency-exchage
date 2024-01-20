import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'my_widgets.dart';
import 'signup_page.dart';
import 'welcome.dart';
import 'admin_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  String? email, password;

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

  void loginUser(Function(bool success, int id) update) async {
    try {
      final url = Uri.https("currencies-exchange.000webhostapp.com", "login.php");
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, String>{
          'email': '$email',
          'password': '$password',
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonResponse = convert.jsonDecode(response.body);
        bool result = jsonResponse['success'];
        int userId = int.parse(jsonResponse['id']);
        update(result, userId);
      }
    } catch (e) {
      update(false, 0);
    }
  }

  void update(bool success, int userId){
    if(success){
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const WelcomePage(),
          settings: RouteSettings(arguments: userId)
        ),
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email or password wrong!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 250,
                  child: MyTextFormField(
                    inputBorder: const OutlineInputBorder(),
                    hintText: "Enter Email:",
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) => setState(() => email = value),
                    validator: (value){
                      if(value == null || value.isEmpty) return "Required!";
                      return validateEmail(value) ? null : "Invalid Email Format!";
                    },
                  ),
                ),
                const SizedBox(height: 18,),
                SizedBox(
                  width: 250,
                  child: MyTextFormField(
                      inputBorder: const OutlineInputBorder(),
                      hintText: "Enter Password:",
                      keyboardType: TextInputType.visiblePassword,
                      onSaved: (value) => setState(() => password = value),
                      validator: (value){
                        if(value == null || value.isEmpty) return "Required!";
                        return validatePassword(value);
                      }
                  ),
                ),
                const SizedBox(height: 14,),
                ElevatedButton.icon(
                  onPressed: (){
                    final isValid = formKey.currentState!.validate();
                    if(isValid){
                      formKey.currentState!.save();
                      if(email == "clinic.manage.admin@gmail.com" && password == "aA1!1111"){
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const Admin()),
                        );
                      }
                      else {
                        loginUser(update);
                      }
                    }
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("Login", style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(
                  width: 200,
                  child: Divider(
                    color: Colors.blueGrey,
                    thickness: 2,
                  ),
                ),
                const SizedBox(height: 18,),
                const Text("Don't have an account?", style: TextStyle(fontSize: 18),),
                const SizedBox(height: 5,),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Signup()),
                    );
                  },
                  child: const Text("Signup", style: TextStyle(fontSize: 16, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
