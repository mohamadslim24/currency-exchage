import 'package:flutter/material.dart';
import 'country.dart';
import 'mywidgets.dart';
import 'countrie.dart';

final List<String> chooseByOptions = ["name", "code"];
final List<String> countryNames = Country.getNames(countrie);
final List<String> currencyCodes = Country.getCodes(countrie);
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
  bool initialized = false;
  String? ratio;
  String? amount = "";
  double result = 0.0;


  void initialize(){
    optionsInDropDownMenuTo = countryNames.toList();
    optionsInDropDownMenuFrom = countryNames.toList();
    currentTo = optionsInDropDownMenuFrom.removeAt(0);
    currentFrom = optionsInDropDownMenuTo.removeLast();

    updateRatio();

    initialized = true;
  }


  void chooseByChanged(){
    setState(() {
      bool currentFromAssigned = false;
      bool currentToAssigned = false;
      String from = currentFrom.substring(currentFrom.indexOf(' ') + 1); // Remove the flag part.
      String to = currentTo.substring(currentTo.indexOf(' ') + 1); // Remove the flag part.

      for(var country in countrie){
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


  void newNameOrCodeSelected(){
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

    for(var country in countrie)
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

  @override
  Widget build(BuildContext context) {
    if(!initialized) initialize();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Country to Country Exchange",),
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
