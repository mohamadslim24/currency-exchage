import 'package:flutter/material.dart';
import 'country_to_country_exchange_page.dart';
import 'country_to_all_exchange_page.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  String userName = "";
  bool userNameSetted = false;

  Future<String?> setUsername(Function(bool, String) update, int userId) async{
    try {
      final url = Uri.https("currencies-exchange.000webhostapp.com", "getUsername.php");
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, String>{
          'userId': '$userId'
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonResponse = convert.jsonDecode(response.body);
        String name = jsonResponse['userName'];
        update(true, name);
      }
    } catch (e) {
      update(false, "");
    }
    return null;
  }

  void update(bool success, String name){
    if(success){
      setState(() {
        userName = name;
      });
    }
    else{
      // TODO: Snack.
    }
  }

  void logout() {
    setState(() {
      userName = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final temp = ModalRoute.of(context)!.settings.arguments;
    int userId = 0;
    if(temp != null){
      userId = temp as int;
      if(!userNameSetted) {
        setUsername(update, userId)
            .then((value) => setState(() => userNameSetted = true));
      }
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://5.imimg.com/data5/BW/OV/MY-622376/international-flags-500x500.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 130,),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(75),
                      topLeft: Radius.circular(75),
                      topRight: Radius.circular(60),
                    ),
                    color: Colors.blue.withOpacity(0.8),
                  ),
                  padding: const EdgeInsets.all(36),
                  child: Text(
                    '   ${(userName != "" ? "Welcome, $userName to" : "Welcome to")} \n\nCurrency Exchange!',
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 18,),
                userName != "" ?
                SizedBox(
                  width: 150,
                  child: ElevatedButton.icon(
                    label: const Text("Logout", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),),
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      logout();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                      backgroundColor: Colors.blue.withAlpha(100),
                    ),
                  ),
                )
                    : SizedBox(
                  width: 150,
                  child: ElevatedButton.icon(
                    label: const Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),),
                    icon: const Icon(Icons.login),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                      backgroundColor: Colors.blue.withAlpha(100),
                    ),
                  ),
                ),
                const SizedBox(height: 250,),
                Container(
                  color: Colors.blue.withOpacity(0.6),
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    "Exchange from a currency to:",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20,),
                SizedBox(
                  width: 150,
                  child: ElevatedButton.icon(
                    label: const Text("another", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),),
                    icon: const Icon(Icons.multiple_stop),
                    onPressed: (){
                      Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ExchangePage(),
                            settings: RouteSettings(arguments: userName)
                          )
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                      backgroundColor: Colors.blue.withAlpha(100),
                    ),
                  ),
                ),
                const SizedBox(height: 18,),
                SizedBox(
                  width: 150,
                  child: ElevatedButton.icon(
                    label: const Text("many", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),),
                    icon: const Icon(Icons.account_tree),
                    onPressed: (){
                      Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const CountryToManyExchangePage(),
                              settings: RouteSettings(arguments: userId)
                          )
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                      backgroundColor: Colors.blue.withAlpha(100),
                    ),
                  ),
                ),
                const SizedBox(height: 25,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
