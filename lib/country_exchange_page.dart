import 'package:flutter/material.dart';
import 'mywidgets.dart';
import 'country.dart';
import 'countrie.dart';

final List<String> countryNames = Country.getNamesWithCodes(countrie);
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


  void convert(){
    setState(() {
      outputResults = getResults();

      currentAmount = double.tryParse(amount!);
      if(amount == null || currentAmount == null) { outputHeight = 0; currentAmount = 0.0; }
      else { outputHeight = (countrie.length - 1) * (40 + 5 + 36);}
    });
  }


  List<List> getResults(){
    List<List> result = [];

    // Get the radioToUSD of the current selected country:
    double ratioToUSD = 0.0;
    for(var country in countrie){
      if("${country.flag} ${country.name} - (${country.currencyCode})" == selectedCountry){
        ratioToUSD = country.ratioToUSD;
        break;
      }
    }

    // Get the needed information about all countries:
    for(var country in countrie){
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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