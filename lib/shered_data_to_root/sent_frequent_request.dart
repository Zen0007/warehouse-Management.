import 'dart:async';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class FrequentRequestHandler {
  FrequentRequestHandler(this.wsHelper);
  final WebsocketHelper wsHelper;
  Timer? timer;

  void frequentRequestCollectionAdmin() {
    wsHelper.getDataAllCollection();
  }
}
