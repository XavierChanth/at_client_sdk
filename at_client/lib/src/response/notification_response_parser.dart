import 'package:at_client/src/response/at_notification.dart';
import 'package:at_client/src/response/default_response_parser.dart';
import 'package:at_client/src/response/json_utils.dart';
import 'package:at_client/src/response/response.dart';
import 'package:at_utils/at_logger.dart';

class NotificationResponseParser extends DefaultResponseParser {
  final _logger = AtSignLogger('NotificationResponseParser');
  Future<List<AtNotification>> getAtNotifications(AtResponse response) async {
    final notificationList = <AtNotification>[];
    if (response.isError) {
      return [];
    }
    final notificationJson = response.response;
    var notifications = notificationJson.split('notification: ');
    for (var notification in notifications) {
      if (notification.isEmpty) {
        continue;
      }
      notification = notification.replaceFirst('notification:', '');
      notification = notification.trim();
      final atNotification =
          AtNotification.fromJson(JsonUtils.decodeJson(notification));
      notificationList.add(atNotification);
    }
    return notificationList;
  }
}
