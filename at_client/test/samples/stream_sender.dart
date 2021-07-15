import 'dart:convert';

import 'package:at_client/at_client.dart';
import 'package:at_client/src/client/at_client_impl.dart';
import 'package:at_client/src/stream/at_stream_request.dart';
import 'package:at_client/src/stream/at_stream_response.dart';
import 'package:at_client/src/stream/at_stream.dart';

import 'test_util.dart';
AtClient? atClient;
void main() async {
  try {
    await AtClientImpl.createClient(
        '@alice🛠', 'me', TestUtil.getAlicePreference());
    atClient = await (AtClientImpl.getClient('@alice🛠'));
    if (atClient == null) {
      print('unable to create at client instance');
      return;
    }
    Function dummyFunction = () {};
    var monitorPreference = MonitorPreference();
    await atClient!.startMonitor(_notificationCallback, dummyFunction, monitorPreference);
    var stream = atClient!.createStream(StreamType.SEND, );
    print('sender : ${stream.sender} receiver : ${stream.receiver}');
    var atStreamRequest =
        AtStreamRequest('@bob🛠', 'cat.jpeg');
    atStreamRequest.namespace = 'atmosphere';
    await stream.sender!.send(atStreamRequest, _onDone, _onError);
    while(true) {
      print('Waiting for notification');
      await Future.delayed(Duration(seconds: 5));
    }
  } on Exception catch (e, trace) {
    print(e.toString());
    print(trace);
  }
}

void _onDone(AtStreamResponse response) {
  print('stream done callback');
  print(response);
}

void _onError(AtStreamResponse response) {
  print('stream error callback');
  print(response);
}

Future<void> _notificationCallback(var response) async {
  print('notification received $response');
}
