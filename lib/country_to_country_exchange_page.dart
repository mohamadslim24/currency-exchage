import 'package:flutter/material.dart';
import 'country.dart';
import 'my_widgets.dart';
import 'countries.dart';
import 'login_page.dart';

late List<String> countryNames;
late List<String> currencyCodes;
final List<String> chooseByOptions = ["name", "code"];
late List<String> optionsInDropDownMenuFrom;
late List<String> optionsInDropDownMenuTo;

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  String chooseBy = chooseByOptions[0];
  String currentFrom = "";
  String currentTo = "";
  bool initialized = false, init = false;
  String? ratio;
  String? amount = "";
  double result = 0.0;

  @override
  void initState(){
    populateCountries(update).then((value) => {});
    super.initState();
  }

  /// Contains whatever needs to be done only once for the page.
  ///
  void initialize(){
    countryNames = Country.getNames(countries);
    currencyCodes = Country.getCodes(countries);
    optionsInDropDownMenuTo = countryNames.toList();
    optionsInDropDownMenuFrom = countryNames.toList();
    currentTo = optionsInDropDownMenuFrom.removeAt(0);
    currentFrom = optionsInDropDownMenuTo.removeLast();

    updateRatio();

    initialized = true;
  }

  void update(bool success){
    if(success){
      setState(() => init = true);
    }
    else {
      // TODO: Display a button to retry.
      init = false;
    }
  }

  /// Rebuilds the interface taking into consideration the following:
  /// - Changes the variables holding the current selections in both menus
  ///   to/from countryNames/currencyCodes to update the current selections
  ///   when switching between "Choose by" values.
  void chooseByChanged(){
    setState(() {
      bool currentFromAssigned = false;
      bool currentToAssigned = false;
      String from = currentFrom.substring(currentFrom.indexOf(' ') + 1); // Remove the flag part.
      String to = currentTo.substring(currentTo.indexOf(' ') + 1); // Remove the flag part.

      for(var country in countries){
        if(!currentFromAssigned) {
          if (from == country.name) {
            currentFrom = "${country.flag} ${country.currencyCode}";
            currentFromAssigned = true;
          }
          else if (from == country.currencyCode) {
            currentFrom = "${country.flag} ${country.name}";
            currentFromAssigned = true;
          }
        }
        if(!currentToAssigned) {
          if (to == country.name) {
            currentTo = "${country.flag} ${country.currencyCode}";
            currentToAssigned = true;
          }
          else if (to == country.currencyCode) {
            currentTo = "${country.flag} ${country.name}";
            currentToAssigned = true;
          }
        }
        if(currentFromAssigned && currentToAssigned) { break; }
      }
    });
  }

  /// Updates the options for the dropDownMenus contents such that the
  /// currently selected item in a list won't exist in the other.
  void newNameOrCodeSelected() async{
    setState(() {
      switch(chooseBy)
      {
        case "name":
          optionsInDropDownMenuFrom = countryNames.toList();
          optionsInDropDownMenuTo = countryNames.toList();
          break;
        case "code":
          optionsInDropDownMenuFrom = currencyCodes.toList();
          optionsInDropDownMenuTo = currencyCodes.toList();
        default:
          throw Exception("Type '$chooseBy' was not found.");
      }
      optionsInDropDownMenuFrom.remove(currentTo);
      optionsInDropDownMenuTo.remove(currentFrom);

      updateRatio();
    });
  }

  /// Swaps values of the variables for the currently selected values in the
  /// menus. Then reconstruct the menus.
  void switchPressed(){
    String swap = currentFrom;
    currentFrom = currentTo;
    currentTo = swap;
    newNameOrCodeSelected();
  }

  /// Takes the ratio given by the user and store it as the new used ratio.
  ///
  void ratioChanged(String? ratio){
    setState(() {
      this.ratio = ratio;
    });
  }

  /// Finds the ratio of the current exchange needed to be done.
  ///
  /// Returns the calculated ratio.
  void updateRatio(){
    double ratioFromUSD = 1.0, ratioToUSD = 1.0;
    String currentCountryFrom = currentFrom.substring(currentFrom.indexOf(' ') + 1);
    String currentCountryTo = currentTo.substring(currentTo.indexOf(' ') + 1);
    bool ratioFromUSDFound = false;
    bool ratioToUSDFound = false;

    for(var country in countries)
    {
      if(!ratioToUSDFound && (country.name == currentCountryFrom || country.currencyCode == currentCountryFrom)) {
        ratioToUSD = country.ratioToUSD;
        ratioToUSDFound = true;
      }
      else if(!ratioFromUSDFound && (country.name == currentCountryTo || country.currencyCode == currentCountryTo)) {
        ratioFromUSD = country.ratioFromUSD;
        ratioFromUSDFound = true;
      }
      if(ratioToUSDFound && ratioFromUSDFound) { break; }
    }
    ratio = (ratioToUSD * ratioFromUSD).toString();
  }

  /// Calculates the result if possible and updates the interface.
  ///
  void updateResult(){
    setState(() {
      //Input validation:
      amount ??= "0";

      double? newAmount = double.tryParse(amount!);
      if (newAmount == null) return;

      // Calculate result:
      if(ratio != null) {
        double? ratioNum = double.tryParse(ratio!);
        if (ratioNum != null) {
          result = newAmount * ratioNum;
        }
      }
    });
  }
  bool isLoggedIn = false;
  String userName = "";
  bool settingsTransferred = false;

  void logout() {
    setState(() {
      isLoggedIn = false;
      userName = "";
    });
  }

  void login() {
    setState(() {
      isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(!settingsTransferred) {
      userName = ModalRoute.of(context)!.settings.arguments as String;
      settingsTransferred = true;
    }
    if(userName.isNotEmpty){
      isLoggedIn = true;
    }
    else {
      isLoggedIn = false;
    }
    if (!initialized && init) initialize();
    return !init ? const CircularProgressIndicator() : Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          if (isLoggedIn)
            IconButton(
              onPressed: () {
                logout();
              },
              icon: const Icon(Icons.logout),
            )
          else
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
              icon: const Icon(Icons.login),
            ),
        ],
        title: const Text("Country to Country Exchange"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 220),
          reverse: true,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20,),
              MyDropDownMenu(
                  list: optionsInDropDownMenuFrom,
                  initialSelection: currentFrom,
                  action: (val){
                    currentFrom = val!;
                    newNameOrCodeSelected();
                    updateResult();
                  }
              ),
              const SizedBox(height: 18,),
              ElevatedButton(
                child: const Icon(Icons.swap_vert, size: 50),
                onPressed: (){
                  switchPressed();
                  updateResult();
                },
              ),
              const SizedBox(height: 18,),
              MyDropDownMenu(
                  list: optionsInDropDownMenuTo,
                  initialSelection: currentTo,
                  action: (val){
                    currentTo = val!;
                    newNameOrCodeSelected();
                    updateResult();
                  }
              ),
              const SizedBox(height: 18,),
              const Text("Choose by:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MyRadio(value: "name", groupValue: chooseBy, onChanged: (val){
                    chooseBy = chooseByOptions[0];
                    chooseByChanged();
                    newNameOrCodeSelected();
                  }),
                  const Text("Country name", style: TextStyle(fontSize: 20),),
                  MyRadio(value: "code", groupValue: chooseBy, onChanged: (val){
                    chooseBy = chooseByOptions[1];
                    chooseByChanged();
                    newNameOrCodeSelected();
                  }),
                  const Text("Currency code", style: TextStyle(fontSize: 20),),
                ],
              ),
              const SizedBox(height: 18,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Exchange ratio: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  SizedBox(
                    width: 200,
                    child: MyTextField(
                      hintText: "Radio",
                      inputBorder: const OutlineInputBorder(),
                      textInputType: TextInputType.number,
                      fontSize: 22,
                      // defaultText: ratio.toString(),
                      userInput: ratio.toString(),
                      onChanged: (val){
                        ratioChanged(val);
                        updateResult();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18,),
              SizedBox(
                  width: 300,
                  child: MyTextField(
                    inputBorder: const UnderlineInputBorder(),
                    hintText: "Amount...",
                    textInputType: TextInputType.number,
                    defaultText: amount.toString(),
                    onChanged: (val){
                      amount = val;
                      updateResult();
                    },
                  )
              ),
              const SizedBox(height: 18,),
              SizedBox(
                  width: 300,
                  child: MyTextField(
                    inputBorder: const OutlineInputBorder(),
                    hintText: "Result...",
                    textInputType: TextInputType.none,
                    defaultText: "Result: $result",
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}