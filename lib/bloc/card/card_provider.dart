import 'package:flutter/material.dart';
import '../../core/network/dio_client.dart';
import '../../data/models/business_card_model.dart';
import '../../data/network/data_agents/card_api_impl.dart';
import '../../data/vos/request/create_card_request.dart';

class CardProvider extends ChangeNotifier {
  final _api = CardApiImpl(DioClient.create());

  bool isLoading = false;
  bool isCreating = false;
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

  Future<bool> createCard({
    int? companyId,
    String? position,
    List<String>? phones,
    List<String>? emails,
    List<String>? addresses,
    String? bio,
    String? profileImage,
  }) async {
    try {
      isCreating = true;
      notifyListeners();

      final request = CreateCardRequest(
        companyId: companyId,
        position: position,
        phones: phones,
        emails: emails,
        addresses: addresses,
        bio: bio,
        profileImage: profileImage,
      );

      final created = await _api.createCard(request.toJson());
      cards = [created, ...cards];
      return true;
    } catch (e) {
      debugPrint("CREATE CARD ERROR: $e");
      return false;
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }
}
