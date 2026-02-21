import 'package:flutter/material.dart';
import '../../core/network/dio_client.dart';
import '../../data/models/business_card_model.dart';
import '../../data/network/data_agents/card_api_impl.dart';

class CardProvider extends ChangeNotifier {
  final _api = CardApiImpl(DioClient.create());

  bool isLoading = false;
  List<BusinessCardModel> cards = [];

  Future<void> fetchCards() async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await _api.getCards();
      cards = res.cards;
    } catch (e) {
      debugPrint("CARD ERROR: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
