import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/network/dio_client.dart';
import '../../data/models/business_card_model.dart';
import '../../data/network/data_agents/card_api_impl.dart';
import '../../data/vos/request/create_card_request.dart';

class CardProvider extends ChangeNotifier {
  final _api = CardApiImpl(DioClient.create());

  bool isLoading = false;
  bool isCreating = false;
  bool isLoadingRequests = false;
  List<BusinessCardModel> cards = [];
  List<BusinessCardModel> friendRequests = [];

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
    XFile? imageFile,
    String? cardType,
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
        cardType: cardType,
      );

      final created =
          await _api.createCard(request.toJson(), imageFile: imageFile);
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

  Future<bool> updateCard(
    int id, {
    String? name,
    int? companyId,
    String? position,
    List<String>? phones,
    List<String>? emails,
    List<String>? addresses,
    String? bio,
    String? profileImage,
    XFile? imageFile,
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

      final updated =
          await _api.updateCard(id, request.toJson(), imageFile: imageFile);
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

  String? deleteMessage;

  Future<bool> deleteCard(int id) async {
    try {
      deleteMessage = await _api.deleteCard(id);
      cards.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("DELETE CARD ERROR: $e");
      deleteMessage = "Failed to delete card";
      return false;
    }
  }

  Future<List<BusinessCardModel>> searchCards(
    String query, {
    int? companyId,
    String cardType = 'user_card',
  }) async {
    try {
      return await _api.searchCards(
        query,
        companyId: companyId,
        cardType: cardType,
      );
    } catch (e) {
      debugPrint("SEARCH ERROR: $e");
      return [];
    }
  }

  Future<BusinessCardModel?> scanQr(String qrData) async {
    try {
      return await _api.scanQr(qrData);
    } catch (e) {
      debugPrint("SCAN ERROR: $e");
      return null;
    }
  }

  Future<bool> addFriend(int cardId) async {
    try {
      await _api.addFriend(cardId);
      await fetchFriendRequests();
      return true;
    } catch (e) {
      debugPrint("ADD FRIEND ERROR: $e");
      return false;
    }
  }

  Future<void> fetchFriendRequests() async {
    try {
      isLoadingRequests = true;
      notifyListeners();
      friendRequests = await _api.getFriendRequests();
    } catch (e) {
      debugPrint("FRIEND REQUEST FETCH ERROR: $e");
      friendRequests = [];
    } finally {
      isLoadingRequests = false;
      notifyListeners();
    }
  }

  Future<bool> acceptFriendRequest(int cardId) async {
    try {
      await _api.acceptFriendRequest(cardId);
      friendRequests.removeWhere((card) => card.id == cardId);
      await fetchCards();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("ACCEPT FRIEND ERROR: $e");
      return false;
    }
  }

  Future<bool> rejectFriendRequest(int cardId) async {
    try {
      await _api.rejectFriendRequest(cardId);
      friendRequests.removeWhere((card) => card.id == cardId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("REJECT FRIEND ERROR: $e");
      return false;
    }
  }

  Future<bool> removeFriend(int cardId) async {
    try {
      await _api.removeFriend(cardId);
      await fetchCards();
      await fetchFriendRequests();
      return true;
    } catch (e) {
      debugPrint("REMOVE FRIEND ERROR: $e");
      return false;
    }
  }
}
