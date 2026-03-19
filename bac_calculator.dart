import 'dart:math' as math;

import '../models/drink.dart';
import '../models/food_event.dart';
import '../models/user_profile.dart';

class BacSimulationResult {
  final double bac;
  final FoodState foodState;
  final double gastricBufferGrams;

  const BacSimulationResult({
    required this.bac,
    required this.foodState,
    required this.gastricBufferGrams,
  });

  double get stomachFullness {
    switch (foodState) {
      case FoodState.none:
        return 0.0;
      case FoodState.light:
        return 0.25;
      case FoodState.medium:
        return 0.5;
      case FoodState.full:
        return 1.0;
    }
  }
}

class BacPeakProjection {
  final DateTime peakTime;
  final double peakBac;

  const BacPeakProjection({required this.peakTime, required this.peakBac});
}

enum BacZone { sober, warmingUp, goldenZone, pastThePeak, danger }

extension BacZoneLabel on BacZone {
  String get label {
    switch (this) {
      case BacZone.sober:
        return 'Sober';
      case BacZone.warmingUp:
        return 'Warming up';
      case BacZone.goldenZone:
        return 'Golden Zone';
      case BacZone.pastThePeak:
        return 'Past the peak';
      case BacZone.danger:
        return 'Danger';
    }
  }
}

class BacZoneThresholds {
  final double soberUpper;
  final double warmingUpUpper;
  final double goldenZoneUpper;
  final double pastThePeakUpper;

  const BacZoneThresholds({
    required this.soberUpper,
    required this.warmingUpUpper,
    required this.goldenZoneUpper,
    required this.pastThePeakUpper,
  });
}

class PopulationPharmacokinetics {
  static const double _kaFastedPerHour = 3.64;
  static const double _kaFedPerHour = 1.45;
  static const double _qLitersPerHour = 47.7;
  static const double _kmGramsPerLiter = 0.0121;
  static const double _vmaxFastedGramsPerHour = 6.31;
  static const double _fedVmaxMultiplier = 1.39;
  static const double _habitualVmaxMultiplier = 1.20;
  static const double _fOral = 0.944;
  static const int _simulationStepMinutes = 1;
  static const Duration _sameMomentWindow = Duration(seconds: 60);
  static const double _peakDeltaThreshold = 0.00005;
  static const double _foodLoadHalfLifeHours = 2.5;
  static const double _lightFoodUnits = 0.25;
  static const double _mediumFoodUnits = 0.5;
  static const double _fullFoodUnits = 1.0;
  static const double _femaleFoodEffectMultiplier = 1.05;
  static const double _seniorFoodEffectMultiplier = 1.03;
  static const double _foodLoadMinForLight = 0.17;
  static const double _foodLoadMinForMedium = 0.42;
  static const double _foodLoadMinForFull = 0.75;
  static const double _soberUpper = 0.020;
  static const double _warmingUpUpper = 0.035;
  static const double _goldenZoneUpperBase = 0.055;
  static const double _pastThePeakUpper = 0.080;

  /// Italy's legal BAC limit for driving (0.05 g/dL = 0.5 g/L).
  static const double legalDrivingLimitItaly = 0.05;

  static BacZoneThresholds getZoneThresholds(UserProfile profile) {
    var sensitivityReduction = 0.0;
    if (profile.isFemale) sensitivityReduction += 0.10;
    if (profile.age >= 60) sensitivityReduction += 0.05;
    final cappedReduction = sensitivityReduction.clamp(0.0, 0.15);

    return BacZoneThresholds(
      soberUpper: _soberUpper,
      warmingUpUpper: _warmingUpUpper,
      goldenZoneUpper: _goldenZoneUpperBase * (1.0 - cappedReduction),
      pastThePeakUpper: _pastThePeakUpper,
    );
  }

  static BacZone getCurrentZone(double currentBac, UserProfile profile) {
    final thresholds = getZoneThresholds(profile);

    if (currentBac <= thresholds.soberUpper) {
      return BacZone.sober;
    }
    if (currentBac < thresholds.warmingUpUpper) {
      return BacZone.warmingUp;
    }
    if (currentBac <= thresholds.goldenZoneUpper) {
      return BacZone.goldenZone;
    }
    if (currentBac <= thresholds.pastThePeakUpper) {
      return BacZone.pastThePeak;
    }
    return BacZone.danger;
  }

  static bool isLikelyAscending({
    required double currentBac,
    double? projectedPeakBac,
  }) {
    if (projectedPeakBac == null) return false;
    return projectedPeakBac > (currentBac + _peakDeltaThreshold);
  }

  /// Calculates the current Blood Alcohol Concentration (BAC)
  static double calculateCurrentBAC({
    required UserProfile profile,
    required List<Drink> drinks,
    List<FoodEvent> foodEvents = const [],
    DateTime? currentTime,
  }) {
    final status = calculateCurrentStatus(
      profile: profile,
      drinks: drinks,
      foodEvents: foodEvents,
      currentTime: currentTime,
    );
    return status.bac;
  }

  static BacSimulationResult calculateCurrentStatus({
    required UserProfile profile,
    required List<Drink> drinks,
    List<FoodEvent> foodEvents = const [],
    DateTime? currentTime,
  }) {
    currentTime ??= DateTime.now();
    final simulation = _simulateToTime(
      profile: profile,
      drinks: drinks,
      foodEvents: foodEvents,
      targetTime: currentTime,
    );
    final effectiveFoodLoad = _effectiveFoodLoad(profile, simulation.foodLoad);

    return BacSimulationResult(
      bac: simulation.getBac(profile),
      foodState: _foodStateForLoad(effectiveFoodLoad),
      gastricBufferGrams: simulation.dGut,
    );
  }

  /// Predicts the exact DateTime when the BAC will drop to the target BAC.
  /// Used to know when to take the next drink.
  static DateTime? predictTimeForTargetBac({
    required UserProfile profile,
    required List<Drink> drinks,
    List<FoodEvent> foodEvents = const [],
    required double targetBac,
    DateTime? currentTime,
  }) {
    if (drinks.isEmpty) return null;

    currentTime ??= DateTime.now();
    var simulation = _simulateToTime(
      profile: profile,
      drinks: drinks,
      foodEvents: foodEvents,
      targetTime: currentTime,
    );

    var hasBeenAboveTarget = simulation.getBac(profile) > targetBac;

    const int maxPredictionMinutes = 24 * 60;
    for (var i = 0; i < maxPredictionMinutes; i++) {
      final previousSimulation = simulation;
      simulation = _advanceWithoutEvents(simulation, profile);
      if (!hasBeenAboveTarget && simulation.getBac(profile) > targetBac) {
        hasBeenAboveTarget = true;
      }

      if (hasBeenAboveTarget && simulation.getBac(profile) <= targetBac) {
        final previousBac = previousSimulation.getBac(profile);
        final currentBac = simulation.getBac(profile);
        if (previousBac > targetBac && currentBac < previousBac) {
          final ratio = ((previousBac - targetBac) / (previousBac - currentBac))
              .clamp(0.0, 1.0);
          final stepMs = simulation.currentTime
              .difference(previousSimulation.currentTime)
              .inMilliseconds;
          final crossingMs = (stepMs * ratio).round();
          return previousSimulation.currentTime.add(
            Duration(milliseconds: crossingMs),
          );
        }

        return simulation.currentTime;
      }
    }

    if (!hasBeenAboveTarget) {
      return currentTime;
    }

    return currentTime.add(const Duration(hours: 24));
  }

  /// Returns the exact DateTime when BAC will drop to Italy's legal
  /// driving limit (0.05%). Returns null if drinks list is empty.
  /// Returns [currentTime] (or null) if already below the limit.
  static DateTime? predictDriveReadyTime({
    required UserProfile profile,
    required List<Drink> drinks,
    List<FoodEvent> foodEvents = const [],
    DateTime? currentTime,
  }) {
    if (drinks.isEmpty) return null;
    return predictTimeForTargetBac(
      profile: profile,
      drinks: drinks,
      foodEvents: foodEvents,
      targetBac: legalDrivingLimitItaly,
      currentTime: currentTime,
    );
  }

  /// Predicts the next local BAC peak from [currentTime], assuming no future
  /// drinks/food events beyond those already logged.
  ///
  /// Returns null when BAC is already at/after the peak (flat or descending).
  static BacPeakProjection? predictUpcomingPeak({
    required UserProfile profile,
    required List<Drink> drinks,
    List<FoodEvent> foodEvents = const [],
    DateTime? currentTime,
  }) {
    if (drinks.isEmpty) return null;

    currentTime ??= DateTime.now();
    var state = _simulateToTime(
      profile: profile,
      drinks: drinks,
      foodEvents: foodEvents,
      targetTime: currentTime,
    );

    final currentBac = state.getBac(profile);
    var peakBac = currentBac;
    var peakTime = state.currentTime;
    var previousBac = currentBac;

    const int maxPredictionMinutes = 12 * 60;
    for (var i = 0; i < maxPredictionMinutes; i++) {
      final nextState = _advanceWithoutEvents(state, profile);
      final nextBac = nextState.getBac(profile);

      if (nextBac > peakBac) {
        peakBac = nextBac;
        peakTime = nextState.currentTime;
      }

      final isDescending = nextBac < (previousBac - _peakDeltaThreshold);
      if (isDescending) {
        break;
      }

      state = nextState;
      previousBac = nextBac;
    }

    final hasFuturePeak =
        peakTime.isAfter(currentTime) &&
        peakBac > (currentBac + _peakDeltaThreshold);

    if (!hasFuturePeak) return null;

    return BacPeakProjection(peakTime: peakTime, peakBac: peakBac);
  }

  static String getCurrentState(double currentBac, UserProfile profile) {
    return getCurrentZone(currentBac, profile).label;
  }

  static _SimulationState _simulateToTime({
    required UserProfile profile,
    required List<Drink> drinks,
    required List<FoodEvent> foodEvents,
    required DateTime targetTime,
  }) {
    final events = <_TimelineEvent>[];

    for (final food in foodEvents) {
      if (!food.consumedAt.isAfter(targetTime)) {
        events.add(_TimelineEvent.food(food));
      }
    }

    for (final drink in drinks) {
      if (!drink.consumedAt.isAfter(targetTime)) {
        events.add(_TimelineEvent.drink(drink));
      }
    }

    if (events.isEmpty) {
      return _SimulationState.initial(targetTime);
    }

    events.sort((a, b) => a.time.compareTo(b.time));

    final scheduledEvents = <_TimelineEvent>[];
    var index = 0;
    while (index < events.length) {
      final bucketStartTime = events[index].time;
      final bucket = <_TimelineEvent>[events[index]];

      var scan = index + 1;
      while (scan < events.length) {
        final withinSameMoment =
            events[scan].time.difference(bucketStartTime) <= _sameMomentWindow;
        if (!withinSameMoment) break;
        bucket.add(events[scan]);
        scan++;
      }

      bucket.sort((a, b) {
        final priorityCompare = a.priority.compareTo(b.priority);
        if (priorityCompare != 0) return priorityCompare;
        return a.time.compareTo(b.time);
      });

      for (final event in bucket) {
        scheduledEvents.add(event.withSimulationTime(bucketStartTime));
      }

      index = scan;
    }

    var state = _SimulationState.initial(scheduledEvents.first.time);
    for (final event in scheduledEvents) {
      state = _advanceState(state, profile, event.time);
      state = _applyEvent(state, profile, event);
    }

    return _advanceState(state, profile, targetTime);
  }

  static _SimulationState _advanceWithoutEvents(
    _SimulationState state,
    UserProfile profile,
  ) {
    return _advanceState(
      state,
      profile,
      state.currentTime.add(const Duration(minutes: _simulationStepMinutes)),
    );
  }

  static _SimulationState _advanceState(
    _SimulationState state,
    UserProfile profile,
    DateTime targetTime,
  ) {
    if (!targetTime.isAfter(state.currentTime)) {
      return state.copyWith(currentTime: targetTime);
    }

    var current = state;
    while (targetTime.isAfter(current.currentTime)) {
      final nextTime = current.currentTime.add(
        const Duration(minutes: _simulationStepMinutes),
      );
      final effectiveNext = nextTime.isAfter(targetTime)
          ? targetTime
          : nextTime;
      final hours =
          effectiveNext.difference(current.currentTime).inSeconds / 3600.0;

      final tbw = profile.totalBodyWaterLiters;
      final vCen = 0.57 * tbw;
      final vPer = 0.43 * tbw;

      final cBlood = current.acen / vCen;
      final cPer = current.aper / vPer;
      final decayedFoodLoad = _decayFoodLoad(current.foodLoad, hours);
      final effectiveFoodLoad = _effectiveFoodLoad(profile, decayedFoodLoad);
      final ka = _kaForLoad(effectiveFoodLoad);
      final vmax = _vmaxForLoad(profile, effectiveFoodLoad);

      final dDgut = -ka * current.dGut;
      final dAcen =
          (ka * current.dGut) -
          (_qLitersPerHour * (cBlood - cPer)) -
          ((vmax * cBlood) / (_kmGramsPerLiter + cBlood));
      final dAper = _qLitersPerHour * (cBlood - cPer);

      final nextDGut = (current.dGut + (dDgut * hours)).clamp(
        0.0,
        double.infinity,
      );
      final nextAcen = (current.acen + (dAcen * hours)).clamp(
        0.0,
        double.infinity,
      );
      final nextAper = (current.aper + (dAper * hours)).clamp(
        0.0,
        double.infinity,
      );

      current = _SimulationState(
        currentTime: effectiveNext,
        dGut: nextDGut,
        acen: nextAcen,
        aper: nextAper,
        foodLoad: decayedFoodLoad,
      );
    }

    return current;
  }

  static _SimulationState _applyEvent(
    _SimulationState state,
    UserProfile _profile,
    _TimelineEvent event,
  ) {
    if (event.foodEvent != null) {
      final portion = _foodUnitsForEvent(event.foodEvent!.state);
      if (portion <= 0) {
        return state.copyWith(foodLoad: 0.0);
      }
      return state.copyWith(
        foodLoad: (state.foodLoad + portion).clamp(0.0, 1.0),
      );
    }

    if (event.drink != null) {
      final drink = event.drink!;
      return state.copyWith(dGut: state.dGut + (drink.ethanolMassGrams * _fOral));
    }

    return state;
  }

  static double _vmaxForLoad(UserProfile profile, double effectiveFoodLoad) {
    var vmax = _vmaxFastedGramsPerHour;
    final fedBoost = (_fedVmaxMultiplier - 1.0) * effectiveFoodLoad;
    vmax *= (1.0 + fedBoost);
    if (profile.habitualDrinker) {
      vmax *= _habitualVmaxMultiplier;
    }
    return vmax;
  }

  static double _kaForLoad(double effectiveFoodLoad) {
    return _kaFastedPerHour +
        ((_kaFedPerHour - _kaFastedPerHour) * effectiveFoodLoad);
  }

  static double _foodUnitsForEvent(FoodState state) {
    switch (state) {
      case FoodState.none:
        return 0.0;
      case FoodState.light:
        return _lightFoodUnits;
      case FoodState.medium:
        return _mediumFoodUnits;
      case FoodState.full:
        return _fullFoodUnits;
    }
  }

  static double _decayFoodLoad(double currentLoad, double hours) {
    if (currentLoad <= 0 || hours <= 0) return currentLoad;
    final decayFactor = math.exp(-math.ln2 * (hours / _foodLoadHalfLifeHours));
    return (currentLoad * decayFactor).clamp(0.0, 1.0);
  }

  static double _effectiveFoodLoad(UserProfile profile, double rawFoodLoad) {
    var multiplier = 1.0;
    if (profile.isFemale) {
      multiplier *= _femaleFoodEffectMultiplier;
    }
    if (profile.age >= 60) {
      multiplier *= _seniorFoodEffectMultiplier;
    }
    return (rawFoodLoad * multiplier).clamp(0.0, 1.0);
  }

  static FoodState _foodStateForLoad(double foodLoad) {
    if (foodLoad < _foodLoadMinForLight) {
      return FoodState.none;
    }
    if (foodLoad < _foodLoadMinForMedium) {
      return FoodState.light;
    }
    if (foodLoad < _foodLoadMinForFull) {
      return FoodState.medium;
    }
    return FoodState.full;
  }
}

class _TimelineEvent {
  final DateTime time;
  final Drink? drink;
  final FoodEvent? foodEvent;

  const _TimelineEvent._({required this.time, this.drink, this.foodEvent});

  factory _TimelineEvent.drink(Drink drink) =>
      _TimelineEvent._(time: drink.consumedAt, drink: drink);

  factory _TimelineEvent.food(FoodEvent food) =>
      _TimelineEvent._(time: food.consumedAt, foodEvent: food);

  _TimelineEvent withSimulationTime(DateTime simulationTime) {
    return _TimelineEvent._(
      time: simulationTime,
      drink: drink,
      foodEvent: foodEvent,
    );
  }

  int get priority => foodEvent != null ? 0 : 1;
}

class _SimulationState {
  final DateTime currentTime;
  final double dGut;
  final double acen;
  final double aper;
  final double foodLoad;

  const _SimulationState({
    required this.currentTime,
    required this.dGut,
    required this.acen,
    required this.aper,
    required this.foodLoad,
  });

  factory _SimulationState.initial(DateTime time) {
    return _SimulationState(
      currentTime: time,
      dGut: 0.0,
      acen: 0.0,
      aper: 0.0,
      foodLoad: 0.0,
    );
  }

  double getBac(UserProfile profile) {
    final vCen = 0.57 * profile.totalBodyWaterLiters;
    final cblood = acen / vCen;
    return (cblood / 10).clamp(0.0, double.infinity);
  }

  _SimulationState copyWith({
    DateTime? currentTime,
    double? dGut,
    double? acen,
    double? aper,
    double? foodLoad,
  }) {
    return _SimulationState(
      currentTime: currentTime ?? this.currentTime,
      dGut: dGut ?? this.dGut,
      acen: acen ?? this.acen,
      aper: aper ?? this.aper,
      foodLoad: foodLoad ?? this.foodLoad,
    );
  }
}
