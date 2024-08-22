import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// STEP1: Stream setup
class StreamSocket {
  final _socketResponse = StreamController<String>();
  void Function(String) get addResponse => _socketResponse.sink.add;
  Stream<String> get getResponse => _socketResponse.stream;
  void dispose() {
    _socketResponse.close();
  }
}

StreamSocket streamSocket = StreamSocket();

// STEP2: Add this function in main function in main.dart file and add incoming data to the stream
void connectAndListen() {
  IO.Socket socket = IO.io(
    'https://wheelyx.com/dev',
    IO.OptionBuilder().setTransports(['websocket']).build(),
  );

  socket.onConnect((_) {
    print('Connected to socket');
  });

  // Handle 'message' event from server
  socket.on('message', (data) {
    print('New user joined: $data');
    streamSocket.addResponse('New user joined: $data');
  });

  // Handle 'update' event from server
  socket.on('update', (data) {
    print('Update received: $data');
    streamSocket.addResponse('Update received: $data');
  });

  // Example: Send a message on 'message' event
  socket.emit('message', 'Hello world!');

  // Example: Send an update on 'update' event
  socket.emit('update', 'This is a broadcast message');

  socket.onDisconnect((_) => print('Disconnected from socket'));
}

// STEP3: Build widgets with StreamBuilder
class BuildWithSocketStream extends StatelessWidget {
  const BuildWithSocketStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Socket.IO Example'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: StreamBuilder<String>(
          stream: streamSocket.getResponse,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data received'));
            } else {
              return Center(
                child: Text(
                  snapshot.data ?? "-",
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BuildWithSocketStream(),
  ));
  connectAndListen();
}
