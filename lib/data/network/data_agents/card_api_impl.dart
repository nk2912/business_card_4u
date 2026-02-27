import 'dart:io';
import 'package:dio/dio.dart';
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
      {File? imageFile}) async {
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
          await MultipartFile.fromFile(imageFile.path),
        ));
        requestData = formData;
      } else {
        requestData = data;
      }

      final Response res = await dio.post(
        ApiConstants.cards,
        data: requestData,
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
      {File? imageFile}) async {
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
          await MultipartFile.fromFile(imageFile.path),
        ));

        res = await dio.post(
          '${ApiConstants.cards}/$id',
          data: formData,
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
  Future<void> deleteCard(int id) async {
    try {
      await dio.delete('${ApiConstants.cards}/$id');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to delete card',
      );
    }
  }

  @override
  Future<void> addFriend(int cardId) async {
    try {
      await dio.post('${ApiConstants.cards}/$cardId/add-friend');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to add friend',
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
}
