import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_test/view/socketView.dart';

class SocketService {
  late IO.Socket socket;
  late StreamSocket streamSocket = StreamSocket();

  void connect() {
    socket = IO.io('http://34.64.187.98', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.on('connect', (_) {
      print('Connected to socket server');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from socket server');
    });
  }

  void sendMessage(String message) {
    socket.emit('message', message);
  }

  void disconnect() {
    socket.disconnect();
  }
}
