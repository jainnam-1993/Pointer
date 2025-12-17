import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../data/pointings.dart';

/// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

/// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

/// Onboarding state
final onboardingCompletedProvider = StateProvider<bool>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.hasCompletedOnboarding;
});

/// Current pointing state
final currentPointingProvider = StateNotifierProvider<CurrentPointingNotifier, Pointing>((ref) {
  return CurrentPointingNotifier();
});

class CurrentPointingNotifier extends StateNotifier<Pointing> {
  CurrentPointingNotifier() : super(getRandomPointing());

  void nextPointing({Tradition? tradition, PointingContext? context}) {
    state = getRandomPointing(tradition: tradition, context: context);
  }

  void setPointing(Pointing pointing) {
    state = pointing;
  }
}

/// Subscription state
enum SubscriptionTier { free, premium }

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SubscriptionNotifier(storage);
});

class SubscriptionState {
  final SubscriptionTier tier;
  final bool isLoading;

  const SubscriptionState({
    this.tier = SubscriptionTier.free,
    this.isLoading = false,
  });

  bool get isPremium => tier == SubscriptionTier.premium;

  SubscriptionState copyWith({SubscriptionTier? tier, bool? isLoading}) {
    return SubscriptionState(
      tier: tier ?? this.tier,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final StorageService _storage;

  SubscriptionNotifier(this._storage) : super(const SubscriptionState()) {
    _loadSubscription();
  }

  void _loadSubscription() {
    final tier = _storage.subscriptionTier == 'premium'
        ? SubscriptionTier.premium
        : SubscriptionTier.free;
    state = state.copyWith(tier: tier);
  }

  Future<bool> purchasePremium() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Integrate with RevenueCat
      await _storage.setSubscriptionTier('premium');
      state = state.copyWith(tier: SubscriptionTier.premium, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Integrate with RevenueCat
      final tier = _storage.subscriptionTier;
      if (tier == 'premium') {
        state = state.copyWith(tier: SubscriptionTier.premium, isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }
}

/// Favorites provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return FavoritesNotifier(storage);
});

class FavoritesNotifier extends StateNotifier<List<String>> {
  final StorageService _storage;

  FavoritesNotifier(this._storage) : super(_storage.favorites);

  Future<void> toggle(String pointingId) async {
    if (state.contains(pointingId)) {
      await _storage.removeFavorite(pointingId);
      state = [...state]..remove(pointingId);
    } else {
      await _storage.addFavorite(pointingId);
      state = [...state, pointingId];
    }
  }

  bool isFavorite(String pointingId) => state.contains(pointingId);
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsNotifier(storage);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final StorageService _storage;

  SettingsNotifier(this._storage) : super(_storage.settings);

  Future<void> update(AppSettings newSettings) async {
    await _storage.updateSettings(newSettings);
    state = newSettings;
  }
}
