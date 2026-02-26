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
    String? name,
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
        name: name,
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

  Future<bool> updateCard(int id, {
    String? name,
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
        name: name,
        companyId: companyId,
        position: position,
        phones: phones,
        emails: emails,
        addresses: addresses,
        bio: bio,
        profileImage: profileImage,
      );

      final updated = await _api.updateCard(id, request.toJson());
      final index = cards.indexWhere((c) => c.id == id);
      if (index != -1) {
        cards[index] = updated;
      }
      return true;
    } catch (e) {
      debugPrint("UPDATE CARD ERROR: $e");
      return false;
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCard(int id) async {
    try {
      await _api.deleteCard(id);
      cards.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("DELETE CARD ERROR: $e");
      return false;
    }
  }

  Future<bool> addFriend(int cardId) async {
    try {
      await _api.addFriend(cardId);
      // Refresh list to update UI
      await fetchCards();
      return true;
    } catch (e) {
      debugPrint("ADD FRIEND ERROR: $e");
      return false;
    }
  }

  Future<bool> removeFriend(int cardId) async {
    try {
      await _api.removeFriend(cardId);
      // Refresh list to update UI
      await fetchCards();
      return true;
    } catch (e) {
      debugPrint("REMOVE FRIEND ERROR: $e");
      return false;
    }
  }
}
