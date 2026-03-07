import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_constants.dart';
import '../../models/business_card_model.dart';
import '../responses/card_response.dart';
import 'card_api.dart';

class CardApiImpl implements CardApi {
  final Dio dio;

  CardApiImpl(this.dio);

  @override
  Future<CardResponse> getCards() async {
    final res = await dio.get(ApiConstants.cards);

    return CardResponse.fromJson(res.data);
  }

  @override
  Future<BusinessCardModel> createCard(Map<String, dynamic> data,
      {XFile? imageFile}) async {
    try {
      dynamic requestData;

      if (imageFile != null) {
        final formData = FormData();
        data.forEach((key, value) {
          if (value != null && key != 'profile_image') {
            if (value is List) {
              for (var i = 0; i < value.length; i++) {
                formData.fields.add(MapEntry('$key[$i]', value[i].toString()));
              }
            } else {
              formData.fields.add(MapEntry(key, value.toString()));
            }
          }
        });
        formData.files.add(MapEntry(
          'profile_image',
          await _multipartFromXFile(imageFile),
        ));
        requestData = formData;
      } else {
        requestData = data;
      }

      final Response res = await dio.post(
        ApiConstants.cards,
        data: requestData,
        options: imageFile != null
            ? Options(contentType: 'multipart/form-data')
            : null,
      );
      final dynamic body = res.data;
      final dynamic dataJson =
          (body is Map<String, dynamic> && body.containsKey('data'))
              ? body['data']
              : body;

      return BusinessCardModel.fromJson(dataJson as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create card',
      );
    }
  }

  @override
  Future<BusinessCardModel> updateCard(int id, Map<String, dynamic> data,
      {XFile? imageFile}) async {
    try {
      Response res;

      if (imageFile != null) {
        // Use POST with _method=PUT for file uploads
        final formData = FormData();
        formData.fields.add(const MapEntry('_method', 'PUT'));

        data.forEach((key, value) {
          if (value != null && key != 'profile_image') {
            if (value is List) {
              for (var i = 0; i < value.length; i++) {
                formData.fields.add(MapEntry('$key[$i]', value[i].toString()));
              }
            } else {
              formData.fields.add(MapEntry(key, value.toString()));
            }
          }
        });
        formData.files.add(MapEntry(
          'profile_image',
          await _multipartFromXFile(imageFile),
        ));

        res = await dio.post(
          '${ApiConstants.cards}/$id',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
      } else {
        // Standard PUT for JSON
        res = await dio.put(
          '${ApiConstants.cards}/$id',
          data: data,
        );
      }

      final dynamic body = res.data;
      final dynamic dataJson =
          (body is Map<String, dynamic> && body.containsKey('data'))
              ? body['data']
              : body;

      return BusinessCardModel.fromJson(dataJson as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to update card',
      );
    }
  }

  @override
  Future<String> deleteCard(int id) async {
    try {
      final res = await dio.delete('${ApiConstants.cards}/$id');
      return res.data['message'] ?? 'Business card deleted successfully';
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to delete card',
      );
    }
  }

  @override
  Future<List<BusinessCardModel>> searchCards(
    String query, {
    int? companyId,
    String cardType = 'user_card',
  }) async {
    try {
      final res =
          await dio.get('${ApiConstants.cards}/search', queryParameters: {
        'query': query,
        if (companyId != null) 'company_id': companyId,
        'card_type': cardType,
      });
      final List list = res.data['data'];
      return list
          .map((e) => BusinessCardModel.fromJson(e))
          .where((card) => card.cardType == cardType)
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to search cards');
    }
  }

  @override
  Future<BusinessCardModel> scanQr(String qrData) async {
    try {
      final res = await dio.post('${ApiConstants.cards}/scan-qr', data: {
        'qr_code_data': qrData,
      });
      return BusinessCardModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Card not found');
    }
  }

  @override
  Future<BusinessCardModel> addFriend(int cardId) async {
    try {
      final res = await dio.post('${ApiConstants.cards}/$cardId/add-friend');
      return BusinessCardModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to add friend',
      );
    }
  }

  @override
  Future<List<BusinessCardModel>> getFriendRequests() async {
    try {
      final res = await dio.get('${ApiConstants.cards}/friend-requests');
      final List list = res.data['data'];
      return list.map((e) => BusinessCardModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch friend requests',
      );
    }
  }

  @override
  Future<BusinessCardModel> acceptFriendRequest(int cardId) async {
    try {
      final res = await dio.post('${ApiConstants.cards}/$cardId/accept-friend');
      return BusinessCardModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to accept friend request',
      );
    }
  }

  @override
  Future<void> rejectFriendRequest(int cardId) async {
    try {
      await dio.post('${ApiConstants.cards}/$cardId/reject-friend');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to reject friend request',
      );
    }
  }

  @override
  Future<void> removeFriend(int cardId) async {
    try {
      await dio.post('${ApiConstants.cards}/$cardId/unfriend');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to remove friend',
      );
    }
  }

  Future<MultipartFile> _multipartFromXFile(XFile imageFile) async {
    return MultipartFile.fromBytes(
      await imageFile.readAsBytes(),
      filename: imageFile.name,
    );
  }
}
