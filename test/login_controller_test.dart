import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/src/lifecycle.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:speedlab_pelanggan/app/data/providers/auth_provider.dart';
import 'package:speedlab_pelanggan/app/data/services/auth_service.dart';
import 'package:speedlab_pelanggan/app/data/services/fcm_service.dart';
import 'package:speedlab_pelanggan/app/modules/login/controllers/login_controller.dart';
import 'package:speedlab_pelanggan/app/utils/widget/custom_snackbar.dart';

@GenerateNiceMocks([
  MockSpec<AuthProvider>(),
  MockSpec<AuthService>(),
  MockSpec<FCMService>(),
])
import 'login_controller_test.mocks.dart';

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockAuthService mockAuthService;
  late MockFCMService mockFCMService;
  late LoginController loginController;

  setUp(() {
    Get.testMode = true;
    CustomSnackbar.isTesting = true;

    mockAuthProvider = MockAuthProvider();
    mockAuthService = MockAuthService();
    mockFCMService = MockFCMService();

    final dummyCallback = InternalFinalCallback<void>(callback: () {});

    when(mockAuthService.onStart).thenReturn(dummyCallback);
    when(mockAuthService.onDelete).thenReturn(dummyCallback);

    when(mockFCMService.onStart).thenReturn(dummyCallback);
    when(mockFCMService.onDelete).thenReturn(dummyCallback);

    Get.put<AuthService>(mockAuthService);
    Get.put<FCMService>(mockFCMService);

    loginController = LoginController(provider: mockAuthProvider);
  });

  tearDown(() {
    Get.reset();
  });

  group('LoginController Unit Test (Cyclomatic Complexity V(G)=7)', () {
    // ======================================================
    // PATH 1
    // ======================================================
    test('Path 1: Gagal jika email/password kosong', () async {
      print('=== PATH 1 ===');

      loginController.emailController.text = '';
      loginController.passwordController.text = '';

      await loginController.login();

      verifyNever(mockAuthProvider.login(any, any));

      expect(loginController.isLoading.value, false);
    });

    // ======================================================
    // PATH 2
    // ======================================================
    test('Path 2: Login berhasil', () async {
      print('=== PATH 2 ===');

      loginController.emailController.text = 'test@gmail.com';
      loginController.passwordController.text = '123456';

      final mockResponse = Response(
        statusCode: 200,
        body: {
          'data': {
            'token': 'token_123',
            'user': {'id': '1', 'name': 'Tester'},
          },
        },
      );

      when(
        mockAuthProvider.login(any, any),
      ).thenAnswer((_) async => mockResponse);

      await loginController.login();

      verify(mockAuthProvider.login('test@gmail.com', '123456')).called(1);

      expect(loginController.isLoading.value, false);
    });

    // ======================================================
    // PATH 3
    // ======================================================
    test('Path 3: Login gagal token null', () async {
      print('=== PATH 3 ===');

      loginController.emailController.text = 'test@gmail.com';
      loginController.passwordController.text = '123456';

      final mockResponse = Response(
        statusCode: 200,
        body: {
          'data': {
            'token': null,
            'user': {'id': '1', 'name': 'Tester'},
          },
        },
      );

      when(
        mockAuthProvider.login(any, any),
      ).thenAnswer((_) async => mockResponse);

      await loginController.login();

      verify(mockAuthProvider.login(any, any)).called(1);

      expect(loginController.isLoading.value, false);
    });

    // ======================================================
    // PATH 4
    // ======================================================
    test('Path 4: Response API gagal', () async {
      print('=== PATH 4 ===');

      loginController.emailController.text = 'test@gmail.com';
      loginController.passwordController.text = 'password_salah';

      final mockResponse = Response(
        statusCode: 401,
        body: {'message': 'Email atau password salah'},
      );

      when(
        mockAuthProvider.login(any, any),
      ).thenAnswer((_) async => mockResponse);

      await loginController.login();

      verify(
        mockAuthProvider.login('test@gmail.com', 'password_salah'),
      ).called(1);

      expect(loginController.isLoading.value, false);
    });

    // ======================================================
    // PATH 5
    // ======================================================
    test('Path 5: Exception provider.login', () async {
      print('=== PATH 5 ===');

      loginController.emailController.text = 'test@gmail.com';
      loginController.passwordController.text = '123456';

      when(
        mockAuthProvider.login(any, any),
      ).thenThrow(Exception('Server Timeout'));

      await loginController.login();

      verify(mockAuthProvider.login(any, any)).called(1);

      expect(loginController.isLoading.value, false);
    });

    // ======================================================
    // PATH 6
    // ======================================================
    test('Path 6: Login sukses tetapi FCM gagal', () async {
      print('=== PATH 6 ===');

      loginController.emailController.text = 'test@gmail.com';
      loginController.passwordController.text = '123456';

      final mockResponse = Response(
        statusCode: 200,
        body: {
          'data': {
            'token': 'token_123',
            'user': {'id': '1', 'name': 'Tester'},
          },
        },
      );

      when(
        mockAuthProvider.login(any, any),
      ).thenAnswer((_) async => mockResponse);

      when(
        mockFCMService.sendFcmTokenToBackend(any),
      ).thenThrow(Exception('FCM Error'));

      await loginController.login();

      verify(mockAuthProvider.login(any, any)).called(1);

      expect(loginController.isLoading.value, false);
    });

    // ======================================================
    // PATH 7
    // ======================================================
    test('Path 7: Login sukses tetapi FCM token null', () async {
      print('=== PATH 7 ===');

      loginController.emailController.text = 'test@gmail.com';
      loginController.passwordController.text = '123456';

      final mockResponse = Response(
        statusCode: 200,
        body: {
          'data': {
            'token': 'token_123',
            'user': {'id': '1', 'name': 'Tester'},
          },
        },
      );

      when(
        mockAuthProvider.login(any, any),
      ).thenAnswer((_) async => mockResponse);

      await loginController.login();

      verify(mockAuthProvider.login(any, any)).called(1);

      expect(loginController.isLoading.value, false);
    });
  });
}
