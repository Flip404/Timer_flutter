import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:timer/ticker.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  static int _duration = 0;

  StreamSubscription<int>? _tickerSubscription;

  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(TimerInitial(_duration)) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<TimerTicked>(_onTicked);
    on<TimerIncreasedHours>(_onIncreasedHours);
    on<TimerDecreasedHours>(_onDecreasedHours);
    on<TimerIncreasedMinutes>(_onIncreasedMinutes);
    on<TimerDecreasedMinutes>(_onDecreasedMinutes);
    on<TimerIncreasedSecond>(_onIncreasedSecond);
    on<TimerDecreasedSecond>(_onDecreasedSecond);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    // print("Started B : ${state.duration}");
    emit(TimerRunInProgress(state.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: state.duration)
        .listen((duration) => add(TimerTicked(duration: duration)));
    // print("Started : ${event.duration}");
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
    }
  }

  void _onResumed(TimerResumed resume, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(TimerInitial(state.duration));
    // print("Reset : ${state.duration}");
  }

  void _onTicked(TimerTicked event, Emitter<TimerState> emit) {
    emit(
      event.duration > 0
          ? TimerRunInProgress(event.duration)
          : const TimerRunComplete(),
    );
  }

  void _onIncreasedHours(TimerIncreasedHours increased, Emitter<TimerState> emit) {
    // print("IncreasedHours B ${state.duration}");
    emit(TimerIncreasedComplete(state.duration + 3600));
    // print("IncreasedHours ${state.duration}");
  }

  void _onDecreasedHours(TimerDecreasedHours decreased, Emitter<TimerState> emit) {
    // print("DecreasedHours B ${state.duration}");
    emit(TimerIncreasedComplete(state.duration - 3600));
    // print("DecreasedHours ${state.duration}");
  }

  void _onIncreasedMinutes(TimerIncreasedMinutes increased, Emitter<TimerState> emit) {
    // print("IncreasedMinutes B ${state.duration}");
    emit(TimerIncreasedComplete(state.duration + 60));
    // print("IncreasedMinutes ${state.duration}");
  }

  void _onDecreasedMinutes(TimerDecreasedMinutes decreased, Emitter<TimerState> emit) {
    // print("DecreasedMinutes B ${state.duration}");
    emit(TimerIncreasedComplete(state.duration - 60));
    // print("DecreasedMinutes ${state.duration}");
  }

  void _onIncreasedSecond(TimerIncreasedSecond increased, Emitter<TimerState> emit) {
    // print("IncreasedSecond B ${state.duration}");
    emit(TimerIncreasedComplete(state.duration + 1));
    // print("IncreasedSecond ${state.duration}");
  }

  void _onDecreasedSecond(TimerDecreasedSecond decreased, Emitter<TimerState> emit) {
    // print("DecreasedSecond B ${state.duration}");
    emit(TimerIncreasedComplete(state.duration - 1));
    // print("DecreasedSecond ${state.duration}");
  }
}