import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SettingViewModel with ChangeNotifier {
  int questionNum = 3;
  bool isCanTap = true;
  bool canCommunicate = false;
  List openValues = [];
  List openIds = [];
  List visibleList = [];
  List isBackList = [];
  List valueList = [];
  IO.Socket socket = IO.io(
    'http://10.7.11.21:3000',
    IO.OptionBuilder()
        .setTransports(['websocket']) // for Flutter or Dart VM
        .disableAutoConnect() // disable auto-connection
        .setExtraHeaders({'foo': 'bar'}) // optional
        .build(),
  );

  void connect() {
    print('object');
    socket.onDisconnect((_) => print('disconnect'));
    socket.connect();
    socket.on(
      'back2client',
      (data) => {
        isBackList[data['id']] = false,
        openValues.clear(),
        openValues.addAll(data['openValues']),
        openIds.clear(),
        openIds.addAll(data['openIds']),
        isCanTap = data['isCanTap'],
        notify(),
      },
    );
    socket.on(
      'next2client',
      (data) => {
        visibleList.clear(),
        visibleList.addAll(data['visibleList']),
        isBackList.clear(),
        isBackList.addAll(data['isBackList']),
        openValues = [],
        openIds = [],
        isCanTap = true,
        notify(),
      },
    );
    socket.on(
      'initClient',
      (data) => {
        isCanTap = data['isCanTap'],
        openValues.clear(),
        openValues.addAll(data['openValues']),
        openIds.clear(),
        openIds.addAll(data['openIds']),
        visibleList.clear(),
        visibleList.addAll(data['visibleList']),
        isBackList.clear(),
        isBackList.addAll(data['isBackList']),
        valueList.clear(),
        valueList.addAll(data['valueList']),
        canCommunicate = true,
        notify(),
      },
    );
    socket.emit('initServer');
    notify();
  }

  void notify() => notifyListeners();
}
