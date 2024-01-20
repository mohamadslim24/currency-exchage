import 'country.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

List<Country> countries = [];

Future<String?> populateCountries(Function(bool success) update) async {
  try {
    final url = Uri.https("currencies-exchange.000webhostapp.com", 'getCountries.php');
    final response = await http.get(url)
        .timeout(const Duration(seconds: 5));
    countries.clear();
    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      for (var row in jsonResponse) {
        Country country = Country(
            row['countryName'],
            row['currencyCode'],
            double.parse(row['ratioFromUSD']),
            double.parse(row['ratioToUSD']),
            row['flagUnicode']);
        countries.add(country);
      }
      update(true);
    }
  }
  catch(e) {
    update(false);
  }
}


/*List<Country> countries = [
  Country('United States','USD',1.0,1.0,"\u{1F1FA}\u{1F1F8}"),
  Country('United kingdom','GBP',0.799,1.0, "\u{1F1EC}\u{1F1E7}"),
  Country('Indian','INR',83.351,0.012005,"\u{1F1EE}\u{1F1F3}"),
  Country('Australia','AUD',1.524,0.654382, "\u{1F1E6}\u{1F1FA}"),
  Country('Canada','CAD',1.371,0.729911,  "\u{1F1E8}\u{1F1E6}"),
  Country('Singapore','SGD',1.342237,0.745025,  "\u{1F1F8}\u{1F1EC}"),
  Country('Switzerland','CHF',0.884350,1.130774,  "\u{1F1E6}\u{1F1FA}"),
  Country('Japanese','JPY',149.630631,0.006683, "\u{1F1EF}\u{1F1F5}"),
  Country('China','CNY',7.155711,0.139749, "\u{1F1E8}\u{1F1F3}"),
  Country('Argentina','ARS',356.514491,0.002805,  "\u{1F1E6}\u{1F1F7}"),
  Country('Brazil','BRL',4.900858,0.204046, "\u{1F1E7}\u{1F1F7}"),
  Country('Bahrain','BHD',0.376000,2.659574,  "\u{1F1E7}\u{1F1ED}"),
  Country('Colombia','COP',4074.052886,0.00245, "\u{1F1E8}\u{1F1F4}"),
  Country('New Zealand','NZD',1.657348,0.602344,  "\u{1F1F3}\u{1F1FF}"),
  Country('Kuwait','KWD',0.308131,3.244243, "\u{1F1F0}\u{1F1F7}"),
  Country('Indonesia','IDR',15407.728510,0.000064, "\u{1F1EE}\u{1F1E9}"),
  Country('Lebanon','LBP',89000,1, "\u{1F1F1}\u{1F1E7}"),
  Country('Emirates','AED',3.672500,0.272294,  "\u{1F1E6}\u{1F1EA}"),
  Country('Hong kong','HKD',7.793635,0.128246, "\u{1F1ED}\u{1F1F0}"),
  Country('Turkish','TRY',28.753954,0.034669, "\u{1F1F9}\u{1F1F7}"),
  Country('Sri lanka','LKR',327.507110,0.003046, "\u{1F1F1}\u{1F1F0}"),
  Country('Saudi Arabia','SAR',3.750000,0.266667,  "\u{1F1F8}\u{1F1E6}"),
  Country('Qatar','QAR',3.640000,0.274725,  "\u{1F1F6}\u{1F1E6}"),
  Country('Oman','OMR',0.384963,2.597723,  "\u{1F1F4}\u{1F1F2}"),
  Country('South Africa','ZAR',18.348762,0.052960,  "\u{1F1FF}\u{1F1E6}"),
];*/