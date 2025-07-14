import 'package:flutter/material.dart';
import 'package:appgestion/menu.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'providers/productos_provider.dart';
import 'providers/language_provider.dart';
void main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ProductosProvider()),
      ChangeNotifierProvider(create: (_) => LanguageProvider()),
      // Aquí puedes añadir más providers si los necesitas
    ],
    child: LoginApp(),
  )
);

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RIM LOGISTIC - Gestión de Embarques',
          locale: languageProvider.currentLocale,
          supportedLocales: [
            const Locale('en', ''),
            const Locale('es', ''),
                  ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            scaffoldBackgroundColor: Color(0xFFE3F2FD),
            textTheme: TextTheme(
              titleLarge: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
              bodyLarge: TextStyle(color: Colors.black87),
              ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
                ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
              ),
              ),
                ),
              ),
          home: LoginPage(),
          routes: <String, WidgetBuilder>{
            '/HomeScreen': (BuildContext context) => HomeScreen(),
          },
    );
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController controlleruser = TextEditingController();
  TextEditingController controllerpass = TextEditingController();

  String mensaje = '';
  bool isLoading = false;

  // Credenciales fijas
  final String fixedUsername = "admin";
  final String fixedPassword = "1234";

  void login() {
    setState(() {
      isLoading = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });

      if (controlleruser.text == fixedUsername && controllerpass.text == fixedPassword) {
        // Precarga de datos al iniciar sesión
        Provider.of<ProductosProvider>(context, listen: false).cargarProductos().then((_) {
          Navigator.pushReplacementNamed(context, '/HomeScreen');
        });
      } else {
        setState(() {
          mensaje = AppLocalizations.of(context).translate("login_error");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF81D4FA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(height: 60),
              Container(
                padding: EdgeInsets.only(top: 17.0),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image(
                      width: 120,
                      height: 120,
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.indigo.shade200, blurRadius: 20, offset: Offset(0, 8)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'RIM LOGISTIC',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(color: Colors.indigo, blurRadius: 8, offset: Offset(2, 2)),
                  ],
                ),
              ),
              Text(
                localizations.translate("app_title").split(' - ')[1],
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 40),
              Container(
                height: MediaQuery.of(context).size.height / 2.2,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: TextFormField(
                        controller: controlleruser,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person, color: Colors.indigo),
                          hintText: localizations.translate("username"),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: TextFormField(
                        controller: controllerpass,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: Colors.indigo),
                          hintText: localizations.translate("password"),
                        ),
                      ),
                    ),
                    isLoading
                        ? CircularProgressIndicator(color: Colors.indigo)
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14.0),
                                child: Text(localizations.translate("login"), style: TextStyle(fontSize: 18)),
                              ),
                              onPressed: login,
                            ),
                          ),
                    SizedBox(height: 10),
                    Text(
                      mensaje,
                      style: TextStyle(fontSize: 18.0, color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    // Selector de idioma
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          localizations.translate("language") + ": ",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10),
                        DropdownButton<String>(
                          dropdownColor: Colors.indigo,
                          value: Provider.of<LanguageProvider>(context).currentLocale.languageCode,
                          items: [
                            DropdownMenuItem(
                              value: 'es',
                              child: Text(
                                localizations.translate("spanish"),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(
                                localizations.translate("english"),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              Provider.of<LanguageProvider>(context, listen: false).changeLanguage(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}