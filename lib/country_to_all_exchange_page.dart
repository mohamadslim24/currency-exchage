import 'package:flutter/material.dart';
import 'dart:convert' as conv;
import 'my_widgets.dart';
import 'country.dart';
import 'countries.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;

final List<String> countryNames = Country.getNamesWithCodes(countries);
List<List> outputResults = [];
String selectedCountry = countryNames.first;
double? currentAmount = 0.0;

class CountryToManyExchangePage extends StatefulWidget {
  const CountryToManyExchangePage({super.key});

  @override
  State<CountryToManyExchangePage> createState() => _CountryToManyExchangePageState();
}

class _CountryToManyExchangePageState extends State<CountryToManyExchangePage> {
  String? amount = "";
  double? outputHeight = 0;
  int userId = 0;
  bool init = false;
  bool topCountrySetted = false;
  bool isLoggedIn = false;
  bool settingsTransferred = false;

  /// Sets the following:
  /// - The "results" list according to the current selected country.
  /// - The "current amount" that the user has entered, but converted to double.
  /// - The "output height" to either show or hide the results.
  void convert(){
    setState(() {
      outputResults = getResults();

      currentAmount = double.tryParse(amount!);
      if(amount == null || currentAmount == null) { outputHeight = 0; currentAmount = 0.0; }
      else { outputHeight = (countries.length - 1) * (40 + 5 + 36);}
    });
  }

  /// Collects all required information about the results that will be
  /// displayed later.
  ///
  /// Returns a List of Lists of objects which represents information about
  /// every country.
  /// These information are:
  ///  - flags, countries' names, direct ratio, and currency code.
  List<List> getResults(){
    List<List> result = [];

    // Get the radioToUSD of the current selected country:
    double ratioToUSD = 0.0;
    for(var country in countries){
      if("${country.flag} ${country.name} - (${country.currencyCode})" == selectedCountry){
        ratioToUSD = country.ratioToUSD;
        break;
      }
    }

    // Get the needed information about all countries:
    for(var country in countries){
      if("${country.flag} ${country.name} - (${country.currencyCode})" != selectedCountry){
        String flag = country.flag;
        String name = country.name;
        double ratio = ratioToUSD * country.ratioFromUSD;
        String code = country.currencyCode;
        result.add([flag, name, ratio, code]);
      }
    }
    return result;
  }

  @override
  void initState(){
    populateCountries(updateInit);
    super.initState();
  }

  void updateInit(bool success){
    if(success){
      setState(() => init = true);
    }
    else {
      // TODO: Display a button to retry.
      init = false;
    }
  }

  void updateCounter(Function(bool success) update, String currencyCode) async {
    try{
      final url = Uri.https("currencies-exchange.000webhostapp.com", "updateCounter.php");
      final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: conv.jsonEncode(<String, String>{
            'userId': '$userId', 'currencyCode': currencyCode, 'menuNumber': '3'
          })).timeout(const Duration(seconds: 5));

      if(response.statusCode == 200){
        update(true);
      }
    }catch(e){
      update(false);
    }
  }

  void updateUpdateCounter(bool success){
    // For now, we don't need this.
  }

  Future<String?> setTopCountry(Function(bool, String) update) async {
    try{
      final url = Uri.https("currencies-exchange.000webhostapp.com", "getTopCountry.php");
      final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: conv.jsonEncode(<String, String>{
            'userId': '$userId', 'menuNumber': '3'
          })).timeout(const Duration(seconds: 5));

      if(response.statusCode == 200){
        final jsonData = conv.jsonDecode(response.body);
        final currencyCode = jsonData['currencyCode'];
        update(true, currencyCode);
      }
    }catch(e){
      update(false, "");
    }
    return null;
  }

  void updateSetTopCountry(bool success, String currencyCode){
    if(success){
      setState(() {
        for(String country in countryNames){
          String currentCode = country.substring(country.indexOf("(") + 1, country.indexOf(")"));
          if(currencyCode == currentCode){
            selectedCountry = country;
            break;
          }
        }
      });
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to retrieve history')));
    }
  }

  void login() {
    setState(() {
      isLoggedIn = true;
    });
  }

  void logout() {
    setState(() {
      isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final temp = ModalRoute.of(context)!.settings.arguments;
    if(temp != null && int.parse(temp.toString()) > 0) {
      userId = temp as int;
      if(!settingsTransferred){
        isLoggedIn = true;
      }
      settingsTransferred = true;
      if(init && !topCountrySetted) {
        setTopCountry(updateSetTopCountry).then((value) => setState(() => topCountrySetted = true));
      }
    }
    return !init? const CircularProgressIndicator() : Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          if(isLoggedIn)
            IconButton(
              onPressed: (){
                logout();
              },
              icon: const Icon(Icons.logout),
            )
          else
            IconButton(
              onPressed: (){
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Login(),)
                );
              },
              icon: const Icon(Icons.login),
            ),
        ],
        title: const Text('Country to All Exchange'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 30,),
              MyDropDownMenu(
                list: countryNames,
                initialSelection: selectedCountry,
                fontSize: 19.5,
                action: (val){
                  selectedCountry = val!;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: MyTextField(
                  textInputType: TextInputType.number,
                  onChanged: (value){
                    amount = value;
                  },
                  hintText: "Amount...",
                  inputBorder: const UnderlineInputBorder(),
                  userInput: amount.toString(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 150,
                child: ElevatedButton.icon(
                  label: const Text("Convert", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),),
                  icon: const Icon(Icons.output),
                  onPressed: () {
                    convert();
                    if(userId > 0) {
                            updateCounter(
                                updateUpdateCounter,
                                selectedCountry.substring(
                                    selectedCountry.indexOf("(") + 1,
                                    selectedCountry.indexOf(")")));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    backgroundColor: Colors.blue.withAlpha(150),
                  ),
                ),
              ),
              const SizedBox(height: 30,),
              SizedBox(
                height: outputHeight,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      const Text("Results:", style: TextStyle(fontSize: 24),),
                      const SizedBox(
                        width: 200,
                        child: Divider(
                          color: Colors.blueGrey,
                          thickness: 3,
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          const SizedBox(height: 20,),
                          for (int i = 0; i < outputResults.length; i++)
                            Column(
                              children: <Widget>[
                                Text(
                                  "${outputResults[i][0]} ${outputResults[i][1]}:",
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 15,),
                                Text(
                                    "${outputResults[i][2] * currentAmount} (${outputResults[i][3]})",
                                    style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 300,
                                  child: Divider(
                                    color: Colors.blueGrey,
                                    thickness: 2,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}