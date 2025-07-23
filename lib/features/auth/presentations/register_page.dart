import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sispadu/features/features.dart';
// import 'package:sispadu/features/auth/data/auth_repository.dart';
// import 'package:sispadu/features/auth/presentations/cubit/register_cubit.dart';
import 'package:sispadu/helpers/dialog.dart';
import 'package:sispadu/widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerPasswordConfirm =
      TextEditingController();

  List<String>? nameError;
  List<String>? emailError;
  List<String>? passwordError;
  List<String>? passwordConfirmError;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterCubit>(
      create: (context) => RegisterCubit(context.read<AuthRepository>()),
      child: buildScreen(context),
    );
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocConsumer<RegisterCubit, LoginState>(
        listener: (context, state) async {
          if (state.status == LoginStatus.failure) {
            String errorMessage = '';
            var exception = state.error;
            if (exception?.response != null) {
              if (exception?.response?.statusCode ==
                  HttpStatus.unprocessableEntity) {
                var stateError = state.error;
                if (stateError != null) {
                  List<String>? errorName;
                  List<String>? errorEmail;
                  List<String>? errorPassword;
                  List<String>? errorPasswordConfirm;
                  if (stateError.response != null) {
                    final Map<String, dynamic> json =
                        jsonDecode(stateError.response.toString());
                    if (json["errors"] != null) {
                      errorName = json["errors"]["name"] == null
                          ? []
                          : List<String>.from(
                              json["errors"]["name"]?.map((x) => x));
                      errorEmail = json["errors"]["email"] == null
                          ? []
                          : List<String>.from(
                              json["errors"]["email"]?.map((x) => x));
                      errorPassword = json["errors"]["password"] == null
                          ? []
                          : List<String>.from(
                              json["errors"]["password"]?.map((x) => x));
                      errorPasswordConfirm =
                          json["errors"]["password_confirmation"] == null
                              ? []
                              : List<String>.from(json["errors"]
                                      ["password_confirmation"]
                                  ?.map((x) => x));
                    }
                  }
                  setState(() {
                    nameError = errorName;
                    emailError = errorEmail;
                    passwordError = errorPassword;
                    passwordConfirmError = errorPasswordConfirm;
                  });
                } else {
                  showDialogMsg(context, 'Something went wrong!');
                }
              } else {
                errorMessage = exception?.message ?? "Something went wrong!";
                showDialogMsg(context, errorMessage);
              }
            } else {
              errorMessage = "Something went wrong!";
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
              context.pop(true);
            });
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Center(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(30.0),
                    children: [
                      const SizedBox(height: 80),
                      Text(
                        "Create Account",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Register to continue",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 25),
                      MyTextField(
                        controller: _controllerName,
                        labelText: 'Name',
                        errorText: nameError != null && nameError!.isNotEmpty
                            ? nameError!.join('\n')
                            : null,
                        type: TextFieldType.normal,
                        autofillHints: const [AutofillHints.name],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        filled: false,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        controller: _controllerEmail,
                        labelText: 'Email',
                        errorText: emailError != null && emailError!.isNotEmpty
                            ? emailError!.join('\n')
                            : null,
                        type: TextFieldType.email,
                        autofillHints: const [AutofillHints.email],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          final emailRegExp =
                              RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
                          if (!emailRegExp.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        filled: false,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        controller: _controllerPassword,
                        labelText: 'Password',
                        errorText:
                            passwordError != null && passwordError!.isNotEmpty
                                ? passwordError!.join('\n')
                                : null,
                        type: TextFieldType.password,
                        obscureText: true,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        filled: false,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        controller: _controllerPasswordConfirm,
                        labelText: 'Confirm Password',
                        errorText: passwordConfirmError != null &&
                                passwordConfirmError!.isNotEmpty
                            ? passwordConfirmError!.join('\n')
                            : null,
                        type: TextFieldType.password,
                        obscureText: true,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _controllerPassword.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        filled: false,
                      ),
                      const SizedBox(height: 25),
                      MyButton(
                        text: "Register",
                        verticalPadding: 25,
                        onPressed: () {
                          setState(() {
                            nameError = null;
                            emailError = null;
                            passwordError = null;
                            passwordConfirmError = null;
                          });
                          if (_formKey.currentState!.validate()) {
                            context.read<RegisterCubit>().register(
                                  name: _controllerName.text,
                                  email: _controllerEmail.text,
                                  password: _controllerPassword.text,
                                  passwordConfirmation:
                                      _controllerPasswordConfirm.text,
                                );
                          }
                        },
                      ),
                    ],
                  ),
                  if (state.status == LoginStatus.loading)
                    const LoadingProgress(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _controllerPasswordConfirm.dispose();
    super.dispose();
  }
}
