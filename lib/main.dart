import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';

import 'ble_app_connection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterReactiveBle ble = FlutterReactiveBle();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => BLEAppConnection(ble)),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter RGB Led',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

/*
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
*/
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          await Provider.of<BLEAppConnection>(context, listen: false)
              .disconnect();
          return true;
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Flutter RGB Led'),
            ),
            body: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Card(
                  elevation: 2,
                  child: ColorPicker(
                    onColorChanged: (Color color) {
                      Provider.of<BLEAppConnection>(context, listen: false)
                          .writeColor(color);
                    },
                    width: 44,
                    height: 44,
                    borderRadius: 22,
                    heading: Text(
                      'Select color',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    subheading: Text(
                      'Select color shade',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                ),
              ),
            ), // T
            floatingActionButton:
                Consumer<BLEAppConnection>(builder: (context, ble, child) {
              return ble.connected ==
                      false
                  ? FloatingActionButton(
                      onPressed: () async {
                        await Provider.of<BLEAppConnection>(context,
                                listen: false)
                            .connect();
                      },
                      child: const Icon(Icons.link))
                  : FloatingActionButton(
                      onPressed: () async {
                        await Provider.of<BLEAppConnection>(context,
                                listen: false)
                            .disconnect();
                      },
                      child: const Icon(Icons.link_off));
            })
            // his trailing comma makes auto-formatting nicer for build methods.
            ));
  }
}
