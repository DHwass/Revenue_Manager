import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';
import 'objectives.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TextEditingController dollarsPerHour = TextEditingController();

  // Variables
  int seconds = 0, minutes = 0, hours = 0;
  String textSeconds = "00", textMinutes = "00", textHours = "00";
  Timer? timer;
  bool started = false;
  double _localTotal = 0;
  double _userTotal = 0;
  //Textfield validation
  bool _validate = false;
  bool _editable = true;

  // Stopping function
  void stop() {
    timer!.cancel();
    setState(() {
      started = false;
      _editable = true;
    });
  }

  //Starting function
  void start() {
    started = true;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      int localSeconds = seconds + 1;
      int localMinutes = minutes;
      int localHours = hours;

      // Clock logic
      if (localSeconds > 59) {
        textSeconds = "00";
        if (localMinutes > 59) {
          localHours++;
          localMinutes = 0;
          textMinutes = "00";
        } else {
          localMinutes++;
          localSeconds = 0;
        }
      }

      setState(() {
        _editable = false;
        seconds = localSeconds;
        minutes = localMinutes;
        hours = localHours;
        // computing gains
        _localTotal = _localTotal + (double.parse(dollarsPerHour.text) / 3600);
        _userTotal = _userTotal + (double.parse(dollarsPerHour.text) / 3600);
        textSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
        textMinutes = (minutes >= 10) ? "$minutes" : "0$minutes";
        textHours = (hours >= 10) ? "$hours" : "0$hours";
      });

      //testing
      debugPrint('$_localTotal');
    });
  }

// Reseting function
  void reset() {
    timer!.cancel();
    started = false;

    seconds = 0;
    minutes = 0;
    hours = 0;

    setState(() {
      textSeconds = "00";
      textMinutes = "00";
      textHours = "00";
      _editable = true;
    });

    _localTotal = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Money earned"),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Text(
          // Dyanmic Time display
          "$textHours:$textMinutes:$textSeconds",
          style: const TextStyle(fontSize: 40),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 100.0),
          child: TextField(
            decoration: InputDecoration(
              enabled: _editable,
              hintText: 'Your actual revenue (\$/Hour)',
              errorText: _validate ? 'Value can\'t be empty' : null,
            ),
            controller: dollarsPerHour,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            // Text control
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                dollarsPerHour.text.isEmpty
                    ? _validate = true
                    : _validate = false;

                const Text('Pause');

                setState(() {
                  if (_validate == false) {
                    (!started) ? start() : stop();
                  }
                });
              },
              child: Text((!started) ? "START" : "PAUSE"),
            ),
            ElevatedButton(
                onPressed: () {
                  reset();
                },
                child: const Text('STOP'))
          ],
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              height: 50,
              child: Text(
                "Daily gain: ${_localTotal.toStringAsFixed(2)} \$",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              height: 25,
              child: Text(
                "Savings : ${_userTotal.toStringAsFixed(2)} \$ ",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        )
      ]),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Counter'),
          NavigationDestination(
              icon: Icon(Icons.analytics_outlined), label: 'Objectives'),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentPage = index;
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Objectives(
                    userTotal: _userTotal,
                  ),
                ),
              );
            }
          });
        },
      ),
    );
  }
}
