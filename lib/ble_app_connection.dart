import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BLEAppConnection with ChangeNotifier {
  FlutterReactiveBle? _ble;
  StreamSubscription? _subscription;
  StreamSubscription<ConnectionStateUpdate>? _connection;

  QualifiedCharacteristic? _characteristic;
  final String _deviceName = "NANO RP2040";
  final Uuid _serviceUUID = Uuid.parse("1523");
  final Uuid _characteristicUUID = Uuid.parse("1525");
  bool _connected = false;
  bool get connected => _connected;

  BLEAppConnection(FlutterReactiveBle ble) {
    _ble = ble;
  }

  Future<void> _cancelConnection() async {
    if (_connection != null) {
      try {
        await _connection!.cancel();
        _connected = false;
        _connection = null;
        _characteristic = null;
        notifyListeners();
      } on Exception catch (e, _) {
        Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }



  Future<void> connect() async {
    await _subscription?.cancel();
    _subscription = null;
    _subscription = _ble!.scanForDevices(
        withServices: [_serviceUUID]).listen((device) async {
      if (device.name == _deviceName) {
        await _cancelConnection();
        _connection = _ble!
            .connectToDevice(
          id: device.id,
        )
            .listen((connectionState) async {
          // Handle connection state updates


          Fluttertoast.showToast(
              msg: connectionState.connectionState.toString(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
          );
          if (connectionState.connectionState ==
              DeviceConnectionState.connected) {
            _connected = true;
            notifyListeners();
            print('connected');
            _characteristic = QualifiedCharacteristic(
                serviceId: _serviceUUID,
                characteristicId: _characteristicUUID,
                deviceId: device.id);

          }
        }, onError: (dynamic error) {
          // Handle a possible error

          Fluttertoast.showToast(
            msg: error.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );

        });
      }
    }, onError: (error) {

      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

    });
  }

  Future<void> disconnect() async {
    try {
      await _subscription?.cancel();
      _subscription == null;
      _characteristic == null;
      if (_connection != null) {
        await _connection!.cancel();
        _connection = null;
        _connected = false;
        notifyListeners();
      }
    }
    on Exception catch (e, _) {
      Fluttertoast.showToast(
        msg: "Error disconnecting",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> writeColor(Color color) async {
    int r = color.red;
    int g = color.green;
    int b = color.blue;
    if (_connected) {
      await _ble!
          .writeCharacteristicWithResponse(_characteristic!, value: [r, g, b]);
    }else {
      Fluttertoast.showToast(
        msg: "not connected to device",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
