// lib/main.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:money_transfer_app/network/dio_interceptor.dart';
import 'package:money_transfer_app/providers/agent_provider.dart';
import 'package:money_transfer_app/providers/international_provider.dart';
import 'package:money_transfer_app/providers/kyc_provider.dart';
import 'package:money_transfer_app/providers/notification_provider.dart';
import 'package:money_transfer_app/providers/payment_channel_provider.dart';
import 'package:money_transfer_app/providers/reception_provider.dart';
import 'package:money_transfer_app/providers/transaction_provider.dart';
import 'package:money_transfer_app/providers/withdrawal_provider.dart';
import 'package:money_transfer_app/screens/agent/find_agent_screen.dart';
import 'package:money_transfer_app/screens/auth/login_screen.dart';
import 'package:money_transfer_app/screens/auth/register_screen.dart';
import 'package:money_transfer_app/screens/history/history_screen.dart';
import 'package:money_transfer_app/screens/home/home_screen.dart';
import 'package:money_transfer_app/screens/kyc/kyc_upload_screen.dart';
import 'package:money_transfer_app/screens/notifications/notification_screen.dart';
import 'package:money_transfer_app/screens/profile/change_password_screen.dart';
import 'package:money_transfer_app/screens/profile/edit_profile_screen.dart';
import 'package:money_transfer_app/screens/profile/profile_screen.dart';
import 'package:money_transfer_app/screens/reception/receptions_screen.dart';
import 'package:money_transfer_app/screens/transfert/international_transfer_screen.dart';
import 'package:money_transfer_app/screens/transfert/send_money_screen.dart';
import 'package:money_transfer_app/services/agent_service.dart';
import 'package:money_transfer_app/services/international_service.dart';
import 'package:money_transfer_app/services/kyc_service.dart';
import 'package:money_transfer_app/services/notification_service.dart';
import 'package:money_transfer_app/services/payment_channel_service.dart';
import 'package:money_transfer_app/services/reception_service.dart';
import 'package:money_transfer_app/services/transaction_service.dart';
import 'package:money_transfer_app/services/withdrawal_service.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'network/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final dio = Dio();
  dio.interceptors.add(DioInterceptor());

  final apiClient = ApiClient(dio);
  final authService = AuthService(apiClient);
  final transactionService = TransactionService(apiClient);
  final channelService = PaymentChannelService(apiClient);
  final internationalService = InternationalService(apiClient);
  final agentService = AgentService(apiClient);
  final receptionService = ReceptionService(apiClient);
  final withdrawalService = WithdrawalService(apiClient);
  // On crée les nouveaux services
  final kycService = KycService(apiClient);
  final notificationService = NotificationService(apiClient);

  runApp(MyApp(
    authService: authService,
    transactionService: transactionService,
    channelService: channelService,
    internationalService: internationalService,
    agentService: agentService,
    receptionService: receptionService,
    withdrawalService: withdrawalService,
    // On passe les nouveaux services au widget principal
    kycService: kycService,
    notificationService: notificationService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final TransactionService transactionService;
  final PaymentChannelService channelService;
  final InternationalService internationalService;
  final AgentService agentService;
  final ReceptionService receptionService;
  final WithdrawalService withdrawalService;
  // On déclare les nouveaux services ici
  final KycService kycService;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.authService,
    required this.transactionService,
    required this.channelService,
    required this.internationalService,
    required this.agentService,
    required this.receptionService,
    required this.withdrawalService,
    // On les ajoute au constructeur
    required this.kycService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => TransactionProvider(transactionService)),
        ChangeNotifierProvider(create: (_) => PaymentChannelProvider(channelService)),
        ChangeNotifierProvider(create: (_) => InternationalProvider(internationalService)),
        ChangeNotifierProvider(create: (_) => AgentProvider(agentService)),
        ChangeNotifierProvider(create: (_) => ReceptionProvider(receptionService)),
        ChangeNotifierProvider(create: (_) => WithdrawalProvider(withdrawalService)),
        // On déclare les nouveaux providers ici
        ChangeNotifierProvider(create: (_) => KycProvider(kycService)),
        ChangeNotifierProvider(create: (_) => NotificationProvider(notificationService)),
      ],
      child: MaterialApp(
        title: 'Money Transfer App',
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => MoneyTransferHomePage(),
          '/send-money': (context) => const SendMoneyScreen(),
          '/international-transfer': (context) => const InternationalTransferScreen(),
          '/history': (context) => const HistoryScreen(),
          '/find-agent': (context) => const FindAgentScreen(),
          '/receptions': (context) => const ReceptionsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),
          '/change-password': (context) => const ChangePasswordScreen(),
          '/kyc-upload': (context) => const KycUploadScreen(),
          '/notifications': (context) => const NotificationScreen(),
        },
      ),
    );
  }
}