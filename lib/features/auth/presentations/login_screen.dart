import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sispadu/features/features.dart';
import 'package:sispadu/helpers/dialog.dart';
import 'package:sispadu/helpers/helpers.dart';
import 'package:sispadu/widgets/widgets.dart';
import '../../../services/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeButton = FocusNode(); // FocusNode untuk tombol

  List<String>? emailError;
  List<String>? passwordError;

  String appVersion = '';

  @override
  void initState() {
    super.initState();
    getAppVersion();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
        create: (context) => LoginCubit(context.read<AuthRepository>()),
        child: buildScreen(context));
  }

  void getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // surfaceTintColor: Theme.of(context).colorScheme.error,
        // foregroundColor: Colors.amber,
        forceMaterialTransparency: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.push(Destination.settingNoAuthPath);
              },
            ),
          )
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) async {
          if (state.status == LoginStatus.failure) {
            String errorMessage = '';
            var exception = state.error;
            if (exception?.response != null) {
              if (exception?.response?.statusCode ==
                  HttpStatus.unprocessableEntity) {
                var stateError = state.error;
                if (stateError != null) {
                  List<String>? errorEmail;
                  List<String>? errorPassword;
                  if (stateError.response != null) {
                    final Map<String, dynamic> json =
                        jsonDecode(stateError.response.toString());
                    if (json["errors"] != null) {
                      errorEmail = json["errors"]["email"] == null
                          ? []
                          : List<String>.from(
                              json["errors"]["email"]?.map((x) => x));
                      errorPassword = json["errors"]["password"] == null
                          ? []
                          : List<String>.from(
                              json["errors"]["password"]?.map((x) => x));
                    }
                  }
                  if (errorEmail != null) {
                    setState(() {
                      emailError = errorEmail;
                    });
                  }
                  if (errorEmail != null) {
                    setState(() {
                      passwordError = errorPassword;
                    });
                  }
                } else {
                  showDialogMsg(context, 'Something went wrong!');
                }
              } else {
                errorMessage = extractErrorMessage(exception);
                showDialogMsg(context, errorMessage);
              }
            } else {
              if (DioExceptionType.connectionError == exception?.type) {
                errorMessage = "Connection Error";
              } else {
                errorMessage = "Something went wrong!";
              }
              showDialogMsg(context, errorMessage);
            }
          } else if (state.status == LoginStatus.success) {
            final data = state.data;
            if (Platform.isAndroid) {
              OneSignal.login(_controllerEmail.text);
              OneSignal.User.addTagWithKey("type", "partner");
              OneSignal.User.addTagWithKey("email", _controllerEmail.text);
              OneSignal.User.addTagWithKey("outlet_id", "${data['outlet_id']}");
            }
            context.read<AuthCubit>().setAuthenticated(data['access_token']);
            context
                .read<ProfileCubit>()
                .setProfile(User.fromJson(data['user']));
            // context.read<SettingBloc>().add(GetDataSetting());
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.pop();
            });
          }
        },
        builder: ((context, state) {
          return Form(
            key: _formKey,
            child: Center(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(30.0),
                    children: [
                      const SizedBox(height: 150),
                      Text(
                        "Welcome back",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Login to your account",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 25),
                      MyTextField(
                        controller: _controllerEmail,
                        labelText: 'Email',
                        errorText: extractErrorMessageFromError(emailError),
                        type: TextFieldType.email,
                        focusNode: _focusNodeEmail,
                        autofillHints: const [AutofillHints.email],
                        // prefixIcon: const Icon(Icons.person_outline),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          // Use a regular expression to validate the email format
                          final emailRegExp =
                              RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
                          if (!emailRegExp.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        filled: false,
                        onEditingComplete: () {
                          _focusNodeEmail.unfocus();
                          FocusScope.of(context)
                              .requestFocus(_focusNodePassword);
                        },
                        textColor: Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        controller: _controllerPassword,
                        labelText: 'Password',
                        errorText: extractErrorMessageFromError(passwordError),
                        type: TextFieldType.password,
                        focusNode: _focusNodePassword,
                        autofillHints: const [AutofillHints.password],
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        // prefixIcon: const Icon(Icons.password_outlined),
                        filled: false,
                        onEditingComplete: () {
                          _focusNodePassword.unfocus();
                          FocusScope.of(context).requestFocus(_focusNodeButton);
                        },
                      ),
                      // const SizedBox(height: 10),
                      // const Align(
                      //   alignment: Alignment.centerRight,
                      //   child: Text(
                      //     'Forgot Password?',
                      //   ),
                      // ),
                      const SizedBox(height: 25),
                      MyButton(
                        text: "Login",
                        verticalPadding: 25,
                        focusNode: _focusNodeButton,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<LoginCubit>().login(
                                _controllerEmail.text,
                                _controllerPassword.text);
                          }
                        },
                      ),
                      const SizedBox(height: 25),
                      if (appVersion != '')
                        Text(
                          'Version $appVersion',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                    ],
                  ),
                  if (state.status == LoginStatus.loading)
                    const LoadingProgress(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controllerPassword.dispose();
    _controllerEmail.dispose();
    _focusNodeButton.dispose();
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
  }
}
