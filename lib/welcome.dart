import 'package:flutter/material.dart';
import 'country_to_country_exchange.dart';
import 'country_exchange_page.dart';

class WelcomePage extends StatelessWidget {
  final Runes moneyNum = Runes("\u{1F4B6}");

  WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: const Text(
                    "       Welcome to \n\nCurrency Exchange!",
                    style: TextStyle(fontSize: 30, color: Colors.white),
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
                          MaterialPageRoute(builder: (context) => const ExchangePage(),)
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
                        MaterialPageRoute(builder: (context) => const CountryToManyExchangePage()),
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