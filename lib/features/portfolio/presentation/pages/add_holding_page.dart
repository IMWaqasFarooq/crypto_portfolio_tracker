import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/coin_avatar.dart';
import '../../../market/domain/entities/coin_detail.dart';
import '../../../market/domain/usecases/get_coin_detail_usecase.dart';
import '../../../market/presentation/bloc/coin_search_cubit.dart';
import '../../../market/presentation/widgets/coin_search_delegate.dart';
import '../cubit/portfolio_cubit.dart';

class AddHoldingPage extends StatefulWidget {
  const AddHoldingPage({super.key});

  @override
  State<AddHoldingPage> createState() => _AddHoldingPageState();
}

class _AddHoldingPageState extends State<AddHoldingPage> {
  CoinDetail? _selectedCoin;
  String? _loadError;
  bool _isLoadingCoin = false;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickCoin() async {
    final coinId = await showSearch<String?>(
      context: context,
      delegate: CoinSearchDelegate(sl<CoinSearchCubit>()),
    );
    if (coinId == null || !mounted) return;

    setState(() {
      _isLoadingCoin = true;
      _loadError = null;
    });

    final result = await sl<GetCoinDetailUseCase>()(coinId);
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isLoadingCoin = false;
        _loadError = 'Could not load coin details, try again';
      }),
      (coin) => setState(() {
        _isLoadingCoin = false;
        _selectedCoin = coin;
        _priceController.text = coin.currentPrice.toString();
      }),
    );
  }

  Future<void> _save() async {
    final coin = _selectedCoin;
    if (coin == null || !_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final result = await context.read<PortfolioCubit>().addHolding(
          coinId: coin.id,
          symbol: coin.symbol,
          name: coin.name,
          imageUrl: coin.imageUrl,
          quantity: double.parse(_quantityController.text),
          averageBuyPrice: double.parse(_priceController.text),
        );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add holding')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingCoin) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedCoin == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loadError != null) ...[
              Text(_loadError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: AppSpacing.md),
            ],
            FilledButton.icon(
              onPressed: _pickCoin,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Select a coin'),
            ),
          ],
        ),
      );
    }

    final coin = _selectedCoin!;

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CoinAvatar(imageUrl: coin.imageUrl, symbol: coin.symbol),
            title: Text(coin.name),
            subtitle: Text('${coin.symbol.toUpperCase()} · \$${coin.currentPrice}'),
            trailing: TextButton(onPressed: _pickCoin, child: const Text('Change')),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Quantity'),
            validator: _validatePositiveNumber,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Average buy price (USD)'),
            validator: _validatePositiveNumber,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text('Add to portfolio'),
          ),
        ],
      ),
    );
  }

  String? _validatePositiveNumber(String? value) {
    final parsed = double.tryParse(value ?? '');
    if (parsed == null || parsed <= 0) return 'Enter a positive number';
    return null;
  }
}
