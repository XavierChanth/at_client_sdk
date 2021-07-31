import 'package:at_client/at_client.dart';
import 'package:at_client/src/client/at_client_spec.dart';
import 'package:at_client/src/service/change.dart';
import 'package:at_client/src/service/change_impl.dart';
import 'package:at_client/src/service/change_service.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_commons/src/keystore/at_key.dart';
import 'package:pedantic/pedantic.dart';

class ChangeServiceImpl implements ChangeService {
  final AtClient _atClient;

  ChangeServiceImpl(this._atClient);

  @override
  Future<Change> delete(key) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  AtClient getClient() {
    return _atClient;
  }

  @override
  Future<bool> isInSync() async {
    return await _atClient.getSyncService()!.isInSync();
  }

  @override
  Future<Change> put(AtKey key, value) async {
    var changeImpl = ChangeImpl(_atClient);
    // Setting the syncStrategy to 'ONDEMAND' to write only to local secondary.
    _atClient.setPreferences(
        AtClientPreference()..syncStrategy = SyncStrategy.ONDEMAND);
    // The changeStatus defaults to failure.
    changeImpl.responseStatusEnum = ResponseStatusEnum.failure;
    var isSuccess;
    try {
      isSuccess = await _atClient.put(key, value);
    } on AtClientException {
      rethrow;
    }
    // If put the result is successful, build the change object.
    if (isSuccess) {
      changeImpl.responseStatusEnum = ResponseStatusEnum.success;
      changeImpl.atKey = key;
      changeImpl.operationEnum = OperationEnum.update;
      changeImpl.atValue = AtValue();
      changeImpl.atValue?.value = value;
      changeImpl.atValue?.metadata = key.metadata;
    }
    return changeImpl;
  }

  @override
  Future<Change> putMeta(AtKey key) {
    // TODO: implement putMeta
    throw UnimplementedError();
  }

  @override
  Future<void> sync(
      {Function? onDone, Function? onError, String? regex}) async {
    // Murali - is _atClient
    //          .getSyncService() required or should we call ChangeService.sync() ?
    if (onDone != null && onError != null) {
      unawaited(_atClient
          .getSyncService()!
          .sync(onDone: onDone, onError: onError, regex: regex));
    } else {
      await _atClient
          .getSyncService()!.sync(regex: regex);
    }
  }
}
