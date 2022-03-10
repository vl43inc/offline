import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:offline/models/ModelProvider.dart';

// Generated in previous step
import 'amplifyconfiguration.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isLoading = true;
  int _counter = 0; // Number inserted documents

  /// Init State
  @override
  initState() {
    super.initState();
    _configureAmplify();
  }

  /// Configure Amplify
  Future<void> _configureAmplify() async {
    try {
      // amplify plugins
      final AmplifyDataStore _dataStorePlugin = AmplifyDataStore(modelProvider: ModelProvider.instance);

      // add Amplify plugins
      await Amplify.addPlugins([_dataStorePlugin, AmplifyAPI()]);

      // configure Amplify
      await Amplify.configure(amplifyconfig);

      setState(() {
        _isLoading = false;
      });
    } on AmplifyAlreadyConfiguredException {
      // error handling can be improved for sure!
      // but this will be sufficient for the purposes of this tutorial
      print("Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
    }

    // Listen to DataStore changes
    Stream<QuerySnapshot<Install>> stream = Amplify.DataStore.observeQuery(Install.classType);
    stream.listen((QuerySnapshot<Install> snapshot) {
      setState(() {
        _counter = snapshot.items.length;
      });
    });

    // Set current count (at startup)
    int length = (await Amplify.DataStore.query(Install.classType)).length;

    setState(() {
      _counter = length;
    });
  }

  void _incrementCounter() async {
    Install install = Install(name: 'Install $_counter');
    await Amplify.DataStore.save(install);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
