import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'academic_home_screen.dart';
import 'student_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = false;
  bool _consentAccepted = false;
  bool _isStudent = true;
  final TextEditingController _studentNoController = TextEditingController();
  // akademisyen için email controller kullanılıyor (_emailController)
  late final PageController _pageController;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _studentNoController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _isStudent ? 0 : 1);
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      String email;
      if (_isStudent) {
        final studentNo = _studentNoController.text.trim();
        email = '$studentNo@ogrenci.amasya.edu.tr';
      } else {
        email = _emailController.text.trim();
      }
      // keep remember state variable for future persistence
      // If academic, navigate to academic home; if student, show demo snackbar.
      if (!_isStudent) {
        Navigator.of(context)
            .push<bool>(
          MaterialPageRoute(builder: (_) => const AcademicHomeScreen()),
        )
            .then((loggedOut) {
          if (loggedOut == true) {
            setState(() {
              _rememberMe = false;
            });
          }
        });
      } else {
        // Navigate to student home screen which has a 'Derse Katıl' button
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => StudentHomeScreen(studentEmail: email),
        ));
      }
      // TODO: gerçek kimlik doğrulama entegrasyonu burada yapılır.
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-posta girin';
    final email = value.trim();
    final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (!emailRegex.hasMatch(email)) return 'Geçerli bir e-posta girin';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Şifre girin';
    if (value.length < 6) return 'Şifre en az 6 karakter olmalı';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo + intro animation
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Hero(
                        tag: 'amasya_logo',
                        child: SizedBox(
                          width: 110,
                          height: 110,
                          child: FutureBuilder<ByteData>(
                            future: rootBundle.load('assets/images/amasya_logo.png'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                return Image.memory(snapshot.data!.buffer.asUint8List(), fit: BoxFit.contain);
                              }
                              return const FlutterLogo();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Role selector with swipeable pages
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      children: [
                        Center(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Make toggle responsive: use up to 320px or 90% of available width
                              final containerWidth = (constraints.maxWidth * 0.9).clamp(0.0, 320.0);
                              return Container(
                                width: containerWidth,
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                                              setState(() => _isStudent = true);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const [
                                                  Text('👨‍🎓 Öğrenci'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                                              setState(() => _isStudent = false);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const [
                                                  Text('👨‍🏫 Akademisyen'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Animated underline
                                    Positioned(
                                      bottom: 0,
                                      left: 10,
                                      right: 175,
                                      child: AnimatedBuilder(
                                        animation: _pageController,
                                        builder: (context, child) {
                                          double page = 0;
                                          try {
                                            page = _pageController.page ?? (_isStudent ? 0 : 1);
                                          } catch (_) {
                                            page = _isStudent ? 0 : 1;
                                          }
                                          final tabWidth = (containerWidth - 12) / 2; // two tabs
                                          final left = (page.clamp(0, 1)) * tabWidth;
                                          return Transform.translate(
                                            offset: Offset(left, 0),
                                            child: Container(
                                              width: tabWidth,
                                              height: 2,
                                              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(3)),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 72,
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (i) => setState(() => _isStudent = i == 0),
                            children: [
                              // Student page: shows student no field
                              Center(
                                child: SizedBox(
                                  width: 420,
                                  child: TextFormField(
                                    controller: _studentNoController,
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                      labelText: 'öğenci No',
                                      prefixIcon: Icon(Icons.badge),
                                      hintText: 'örn. 123456',
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Öğrenci no girin';
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              // Academic page: shows email field
                              Center(
                                child: SizedBox(
                                  width: 420,
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'E-posta',
                                      prefixIcon: Icon(Icons.email),
                                    ),
                                    validator: _validateEmail,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // NOTE: The input field is shown inside the PageView above
                  // to avoid duplicate fields. The PageView contains the
                  // student no or email TextFormField depending on selection.
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                    title: const Text('Beni Hatırla / Remember me'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 6),
                  FormField<bool>(
                    initialValue: _consentAccepted,
                    validator: (v) {
                      if (v != true) return 'Bu alanı kabul etmelisiniz';
                      return null;
                    },
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            value: state.value,
                            onChanged: (v) {
                              state.didChange(v);
                              setState(() => _consentAccepted = v ?? false);
                            },
                            title: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  TextSpan(
                                    text:
                                        ' Kişisel verilerimin işlenmesini, kullanımını ve paylaşımını kabul ediyorum!',
                                  ),
                                ],
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                state.errorText ?? '',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text('Giriş Yap'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Basit demo: boşla
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Şifre sıfırlama demo')),
                      );
                    },
                    child: const Text('Şifremi Unuttum'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
