import 'dart:async';
import 'dart:convert';
import 'package:retrofit_graphql/src/functions/graphql_data_objects.dart';
import 'package:retrofit_graphql/src/utils.dart';

enum _AckStatus { none, progress, acknoledged }

class SubscriptionHandler {
  final Map<String, StreamController<Map<String, dynamic>>> _map = {};
  final WebSocketAdapter adapter;
  final connectionInit =
      SubscriptionMessage(type: SubscriptionMessageType.connection_init);

  SubscriptionHandler(this.adapter);

  var ack = StreamController<_StreamSink>();
  var ackStatus = _AckStatus.none;

  Stream<String>? _cahce;

  Stream<String> createBroadcaseStream() {
    var stream = adapter.onMessageStream;
    if (stream.isBroadcast) {
      return stream;
    }
    if (_cahce != null) {
      return _cahce!;
    }
    return _cahce = stream.asBroadcastStream();
  }

  Future<_StreamSink> _initWs() async {
    switch (ackStatus) {
      case _AckStatus.none:
        ackStatus = _AckStatus.progress;
        return adapter.onConnectionReady().asStream().asyncMap((_) {
          var broadcasStream = createBroadcaseStream();
          var r = broadcasStream.map((event) {
            var decoded = jsonDecode(event);
            if (decoded is Map<String, dynamic>) {
              return SubscriptionMessage.fromJson(decoded);
            } else {
              return SubscriptionErrorMessage(payload: decoded);
            }
          }).map((event) {
            switch (event.type) {
              case SubscriptionMessageType.connection_ack:
                return broadcasStream;
              case SubscriptionMessageType.error:
                throw (event as SubscriptionErrorMessage).payload;
              default:
                return broadcasStream;
            }
          }).map((bs) {
            var streamSink =
                _StreamSink(sendMessage: adapter.sendMessage, stream: bs);
            ackStatus = _AckStatus.acknoledged;
            ack.sink.add(streamSink);
            return streamSink;
          }).first;
          adapter.sendMessage(connectionInit.toJsonText());
          return r;
        }).first;

      case _AckStatus.progress:
      case _AckStatus.acknoledged:
        return ack.stream.first;
    }
  }

  Stream<Map<String, dynamic>> handle(GQPayload pl) {
    var controller = StreamController<Map<String, dynamic>>();
    String uuid = generateUuid();
    _map[uuid] = controller;
    _initWs().then((streamSink) {
      streamSink.stream
          .map((event) {
            var map = jsonDecode(event);
            var payload = map["payload"];
            if (payload is Map) {
              return SubscriptionMessage.fromJson(map);
            } else if (payload is List) {
              return SubscriptionErrorMessage.fromJson(map);
            }
          })
          .map((event) => event!)
          .where((event) => event.id == uuid)
          .listen((msg) {
            var msgId = msg.id!;
            switch (msg.type!) {
              case SubscriptionMessageType.next:
                var msg2 = msg as SubscriptionMessage;
                var ctrl = _map[msgId]!;
                ctrl.add(msg2.payload!.data!);
                break;
              case SubscriptionMessageType.complete:
                removeController(msgId);

                break;
              case SubscriptionMessageType.error:
                var errorMsg = msg as SubscriptionErrorMessage;
                var ctrl = _map[msgId]!;
                ctrl.addError(errorMsg.payload);
                removeController(msgId);

                break;
              default:
            }
          });

      streamSink
          .sendMessage(SubscriptionMessage.fromQuery(uuid, pl).toJsonText());
    });

    return controller.stream;
  }

  void removeController(String uuid) {
    var removed = _map.remove(uuid);
    removed?.close();
    if (_map.isEmpty) {
      adapter.close();
      ackStatus = _AckStatus.none;
      ack.close();
      _cahce = null;
      ack = StreamController<_StreamSink>();
    }
  }
}

class _StreamSink {
  final Function(String) sendMessage;
  final Stream<dynamic> stream;

  _StreamSink({required this.sendMessage, required this.stream});
}

abstract class WebSocketAdapter {
  Future<void> onConnectionReady();

  Stream<String> get onMessageStream;

  void sendMessage(String message);

  void close();
}
