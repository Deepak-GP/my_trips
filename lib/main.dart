import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trips/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:trips/blocs/authentication_bloc/authentication_event.dart';
import 'package:trips/blocs/authentication_bloc/authentication_state.dart';
import 'package:trips/blocs/authentication_bloc/simple_bloc_delegate.dart';
import 'package:trips/models/user_repository.dart';
import 'package:trips/screens/add_trips.dart';
import 'package:trips/screens/home_screen.dart';
import 'package:trips/screens/login_screen.dart';
import 'package:trips/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc(userRepository: userRepository)
        ..add(AppStarted()),
      child: App(userRepository: userRepository),
    ),
  );
}

class App extends StatelessWidget {
  final UserRepository _userRepository;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if(state is Uninitialized)
          {
            return SplashScreen();
          }
          if (state is Unauthenticated) {
            return LoginScreen(userRepository: _userRepository);
          }
          if(state is Authenticated)
          {
            return MyApp();
          }
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xFF3EBACE),
        accentColor: Color(0xFFD8ECF1),
        scaffoldBackgroundColor: Color(0xFFF3F3F5F7),
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      routes: {
        AddTrip.route : (context) => AddTrip(),
      },
    );
  }
}

