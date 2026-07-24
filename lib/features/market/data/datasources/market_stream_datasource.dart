import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/price_tick_model.dart';

abstract class MarketStreamDataSource {
  Stream<PriceTickModel> get priceTicks;
  void subscribe(String subscriberId, List<String> symbols);
  void unsubscribe(String subscriberId);
  void dispose();
}

/// Streams live prices from Binance's public ticker WebSocket over one shared connection carrying the union of every subscriber's symbols.
class BinanceMarketStreamDataSource implements MarketStreamDataSource {
  final _controller = StreamController<PriceTickModel>.broadcast();
  final Map<String, List<String>> _subscriptions = {};
  final List<String> _connectedSymbols = [];

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSubscription;
  Timer? _reconnectTimer;

  @override
  Stream<PriceTickModel> get priceTicks => _controller.stream;

  @override
  void subscribe(String subscriberId, List<String> symbols) {
    _subscriptions[subscriberId] = symbols.map((s) => s.toLowerCase()).toList();
    _reconcileConnection();
  }

  @override
  void unsubscribe(String subscriberId) {
    _subscriptions.remove(subscriberId);
    _reconcileConnection();
  }

  void _reconcileConnection() {
    final union = _subscriptions.values.expand((s) => s).toSet().toList()..sort();
    if (_listEquals(union, _connectedSymbols)) return;

    _connectedSymbols
      ..clear()
      ..addAll(union);
    _connect();
  }

  void _connect() {
    _channelSubscription?.cancel();
    _channel?.sink.close();
    _reconnectTimer?.cancel();

    if (_connectedSymbols.isEmpty) {
      _channel = null;
      return;
    }

    final streams = _connectedSymbols.map((s) => '${s}usdt@ticker').join('/');
    final channel = WebSocketChannel.connect(
      Uri.parse('wss://stream.binance.com:9443/stream?streams=$streams'),
    );
    _channel = channel;
    _channelSubscription = channel.stream.listen(
      _handleMessage,
      onError: (_) => _scheduleReconnect(),
      onDone: _scheduleReconnect,
      cancelOnError: true,
    );
  }

  void _handleMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message as String) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>?;
      if (data == null) return;
      _controller.add(PriceTickModel.fromBinanceTicker(data));
    } catch (_) {
      // Malformed frame, drop it.
    }
  }

  void _scheduleReconnect() {
    if (_connectedSymbols.isEmpty) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), _connect);
  }

  @override
  void dispose() {
    _subscriptions.clear();
    _connectedSymbols.clear();
    _channelSubscription?.cancel();
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    _controller.close();
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
