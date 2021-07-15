import 'dart:io';

import 'package:at_client/at_client.dart';
import 'package:at_client/src/service/encryption_service.dart';
import 'package:at_client/src/stream/at_stream_ack.dart';
import 'package:at_client/src/stream/at_stream_notification.dart';
import 'package:at_client/src/stream/stream_notification_handler.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:at_utils/at_logger.dart';

class StreamReceiver {
  String streamId;

  late RemoteSecondary remoteSecondary;

  EncryptionService? encryptionService;

  late AtClientPreference preference;

  final String _currentAtSign;

  StreamReceiver(this._currentAtSign, this.streamId);

  final _logger = AtSignLogger('StreamReceiver');

  Future<void> ack(AtStreamAck atStreamAck, Function streamCompletionCallBack,
      Function streamProgressCallBack) async {
    var handler = StreamNotificationHandler();
    handler.remoteSecondary = remoteSecondary;
    handler.preference = preference;
    handler.encryptionService = encryptionService;
    var notification = AtStreamNotification()
      ..streamId = streamId
      ..fileName = atStreamAck.fileName!
      ..currentAtSign = _currentAtSign
      ..senderAtSign = atStreamAck.senderAtSign!
      ..fileLength = atStreamAck.fileLength!;
    _logger.finer('Sending ack for stream notification:$notification');
    await handler.streamAck(
        notification, streamCompletionCallBack, streamProgressCallBack);
  }

  Future<void> resume(
      String streamId,
      int startByte,
      String senderAtSign,
      Function streamCompletionCallBack,
      Function streamProgressCallBack) async {
    var secondaryUrl = await AtLookupImpl.findSecondary(
        senderAtSign, preference.rootDomain, preference.rootPort);
    var secondaryInfo = AtClientUtil.getSecondaryInfo(secondaryUrl);
    var host = secondaryInfo[0];
    var port = secondaryInfo[1];
    var socket = await SecureSocket.connect(host, int.parse(port));
    _logger.info('sending stream receive for : $streamId');
    var command =
        'stream:resume$_currentAtSign namespace:${preference.namespace} startByte:$startByte $streamId\n';
    socket.write(command);
  }

  Future<void> cancel() async {
    //#TODO implement
  }
}
