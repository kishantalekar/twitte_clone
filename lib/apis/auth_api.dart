import 'package:fpdart/fpdart.dart';
import 'package:twitte_clone/core/core.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/core/providers.dart';

final authProvider = Provider((ref) {
  final account = ref.watch(appwriteAccountProvider);
  return AuthApi(account: account);
});

abstract class IAuthApi {
  FutureEither<model.User> signUp({
    required String email,
    required String password,
  });

  FutureEither<model.Session> login({
    required String email,
    required String password,
  });
  Future<model.User?> currentUserAccount();

  FutureEitherVoid logout();
}

class AuthApi implements IAuthApi {
  final Account _account;
  AuthApi({required Account account}) : _account = account;

  @override
  Future<model.User?> currentUserAccount() async {
    try {
      return await _account.get();
      // ignore: unused_catch_clause
    } on AppwriteException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  FutureEither<model.Session> login({
    required String email,
    required String password,
  }) async {
    try {
      final res =
          await _account.createEmailSession(email: email, password: password);
      return right(res);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(
          e.message ?? " something went wrong while login the user",
          stackTrace.toString(),
        ),
      );
    } catch (e, stackTrace) {
      return left(
        Failure(
          e.toString(),
          stackTrace.toString(),
        ),
      );
    }
  }

  @override
  FutureEither<model.User> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final account = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );
      return right(account);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(
          e.message ??
              "Something went wrong with appwrite while creating account",
          stackTrace.toString(),
        ),
      );
    } catch (e, stackTrace) {
      return left(
        Failure(
          e.toString(),
          stackTrace.toString(),
        ),
      );
    }
  }

  @override
  FutureEitherVoid logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'logout went wrong', st.toString()));
    } catch (e, st) {
      return left(Failure(e.toString(), st.toString()));
    }
  }
}
