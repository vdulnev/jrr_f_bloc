import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_view.dart';
import '../bloc/server_setup_cubit.dart';
import '../bloc/server_setup_state.dart';
import '../data/repositories/connection_repository.dart';
import '../session_service.dart';

enum _ConnectMode { accessKey, manual }

@RoutePage()
class ServerSetupScreen extends StatelessWidget {
  const ServerSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServerSetupCubit(
        repository: getIt<ConnectionRepository>(),
        session: getIt<SessionService>(),
      ),
      child: const _ServerSetupView(),
    );
  }
}

class _ServerSetupView extends StatefulWidget {
  const _ServerSetupView();

  @override
  State<_ServerSetupView> createState() => _ServerSetupViewState();
}

class _ServerSetupViewState extends State<_ServerSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _accessKeyController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '52199');
  final _sslPortController = TextEditingController(text: '52200');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  _ConnectMode _mode = _ConnectMode.accessKey;
  bool _useSsl = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefill());
  }

  @override
  void dispose() {
    _accessKeyController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _sslPortController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _prefill() async {
    if (!mounted || _prefilled) return;
    final repo = getIt<ConnectionRepository>();
    final servers = await repo.getSavedServers();
    if (!mounted || servers.isEmpty) return;
    final last = servers.first;
    final password = await repo.getPassword(last.passwordKey);
    if (!mounted) return;
    _prefilled = true;
    _hostController.text = last.host;
    _portController.text = last.port.toString();
    _sslPortController.text = last.sslPort.toString();
    _usernameController.text = last.username;
    if (password != null) _passwordController.text = password;
    setState(() {
      _useSsl = last.useSsl;
      if (last.host.isNotEmpty) _mode = _ConnectMode.manual;
    });
  }

  Future<void> _connect() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<ServerSetupCubit>();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    switch (_mode) {
      case _ConnectMode.accessKey:
        await cubit.connectWithAccessKey(
          accessKey: _accessKeyController.text.trim(),
          username: username,
          password: password,
          useSsl: _useSsl,
        );
      case _ConnectMode.manual:
        await cubit.connectWithHost(
          host: _hostController.text.trim(),
          port: int.parse(_portController.text.trim()),
          username: username,
          password: password,
          useSsl: _useSsl,
          sslPort: int.tryParse(_sslPortController.text.trim()) ?? 52200,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServerSetupCubit, ServerSetupState>(
      builder: (context, state) {
        final isLoading = state is ServerSetupConnecting;
        final error = state is ServerSetupFailed ? state.error : null;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 40,
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.album_outlined,
                        size: 64,
                        color: AppColors.accent,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'JRiver Remote',
                        style: AppTextStyles.screenTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Connect to your media server',
                        style: AppTextStyles.itemSubtitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SegmentedButton<_ConnectMode>(
                        segments: const [
                          ButtonSegment(
                            value: _ConnectMode.accessKey,
                            label: Text('Access Key'),
                          ),
                          ButtonSegment(
                            value: _ConnectMode.manual,
                            label: Text('Host & Port'),
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: isLoading
                            ? null
                            : (sel) => setState(() => _mode = sel.first),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_mode == _ConnectMode.accessKey)
                              TextFormField(
                                controller: _accessKeyController,
                                enabled: !isLoading,
                                decoration: const InputDecoration(
                                  labelText: 'Access Key',
                                  hintText: 'e.g. abc123',
                                ),
                                textCapitalization: TextCapitalization.none,
                                autocorrect: false,
                                textInputAction: TextInputAction.next,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Required'
                                    : null,
                              )
                            else ...[
                              TextFormField(
                                controller: _hostController,
                                enabled: !isLoading,
                                decoration: const InputDecoration(
                                  labelText: 'Host',
                                  hintText: '192.168.1.100',
                                ),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.next,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Required'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _portController,
                                enabled: !isLoading,
                                decoration: const InputDecoration(
                                  labelText: 'Port',
                                ),
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                validator: (v) {
                                  final n = int.tryParse(v ?? '');
                                  if (n == null || n < 1 || n > 65535) {
                                    return 'Port must be 1–65535';
                                  }
                                  return null;
                                },
                              ),
                              if (_useSsl) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _sslPortController,
                                  enabled: !isLoading,
                                  decoration: const InputDecoration(
                                    labelText: 'SSL Port',
                                    helperText: 'JRiver MC default: 52200',
                                  ),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) {
                                    if (!_useSsl) return null;
                                    final n = int.tryParse(v ?? '');
                                    if (n == null || n < 1 || n > 65535) {
                                      return 'Port must be 1–65535';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ],
                            const SizedBox(height: 8),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              value: _useSsl,
                              onChanged: isLoading
                                  ? null
                                  : (v) => setState(() => _useSsl = v),
                              title: const Text(
                                'Use SSL (HTTPS)',
                                style: AppTextStyles.itemTitle,
                              ),
                              subtitle: const Text(
                                'Trust self-signed JRiver certificates',
                                style: AppTextStyles.itemSubtitle,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _usernameController,
                              enabled: !isLoading,
                              decoration: const InputDecoration(
                                labelText: 'Username (Optional)',
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              enabled: !isLoading,
                              decoration: const InputDecoration(
                                labelText: 'Password (Optional)',
                              ),
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _connect(),
                            ),
                            const SizedBox(height: 32),
                            if (error != null) ...[
                              ErrorView(error: error),
                              const SizedBox(height: 16),
                            ],
                            FilledButton(
                              onPressed: isLoading ? null : _connect,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Connect'),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context
                                        .read<ServerSetupCubit>()
                                        .continueOffline(),
                              child: const Text('Continue Offline'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
