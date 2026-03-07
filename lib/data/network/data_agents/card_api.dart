import 'package:image_picker/image_picker.dart';
import '../../models/business_card_model.dart';
import '../responses/card_response.dart';

abstract class CardApi {
  Future<CardResponse> getCards();
  Future<BusinessCardModel> createCard(Map<String, dynamic> data,
      {XFile? imageFile});
  Future<BusinessCardModel> updateCard(int id, Map<String, dynamic> data,
      {XFile? imageFile});
  Future<String> deleteCard(int id);
  Future<List<BusinessCardModel>> searchCards(
    String query, {
    int? companyId,
    String cardType = 'user_card',
  });
  Future<BusinessCardModel> scanQr(String qrData);
  Future<BusinessCardModel> addFriend(int cardId);
  Future<List<BusinessCardModel>> getFriendRequests();
  Future<BusinessCardModel> acceptFriendRequest(int cardId);
  Future<void> rejectFriendRequest(int cardId);
  Future<void> removeFriend(int cardId);
}
