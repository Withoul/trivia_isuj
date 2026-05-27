import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/question_model.dart';
import '../../../data/services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final int bankId;
  final String bankTitle;

  const QuizScreen({
    super.key,
    required this.bankId,
    required this.bankTitle,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  int _accumulatedScore = 0;
  bool _isLoading = true;
  
  // Selection & Feedback state
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  int _streak = 0; // Consecutive correct answer streak

  // Floating score pop indicators
  String _floatingScoreText = '';
  bool _showFloatingScore = false;

  // Timers
  Timer? _timer;
  int _timeLeft = 12; // 12 seconds limit as standard

  // Shake & Pulse animations
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadQuestions();

    // Shake animation for incorrect answer feedback
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    // Pulse animation for the timer circle glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final questions = await _api.getQuestions(widget.bankId);
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
    _startTimer();
  }

  void _startTimer() {
    _timeLeft = 12;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _streak = 0; // Timeout resets streak to 0
          _answerQuestion(null, false); // Auto incorrect on timeout
        }
      });
    });
  }

  void _answerQuestion(int? answerIndex, bool isCorrect) async {
    _timer?.cancel();
    
    int pointsEarned = 0;

    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = answerIndex;

      if (isCorrect) {
        _streak++; // Increment streak
        
        // --- SCORE CALCULATION LOGIC (§3.4 & §4.1) ---
        // Base points for correct answer: 5
        // Speed bonus: Time left / 2 (e.g. +6 points if answered instantly at 12s)
        // Streak bonus: Adds +1 point for each streak count (e.g. +5 points if streak of 5)
        int basePoints = 5;
        double speedBonus = _timeLeft / 2;
        int streakBonus = _streak;
        
        pointsEarned = basePoints + speedBonus.floor() + streakBonus;
        _accumulatedScore += pointsEarned;

        // Floating score popup configuration
        _floatingScoreText = '+$pointsEarned';
        if (_streak > 1) {
          _floatingScoreText += ' (Racha ${_streak}x!)';
        }
        _showFloatingScore = true;
      } else {
        _streak = 0; // Reset streak
        _shakeController.forward(from: 0.0);
      }
    });

    // Short delay to show full feedback (green check / red shake)
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    setState(() {
      _showFloatingScore = false;
    });

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
      _startTimer();
    } else {
      // Completed, submit final score to Postgres & SQLite
      await _api.submitScore(widget.bankId, _accumulatedScore);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cuestionario finalizado. ¡Excelente trabajo! Puntaje: $_accumulatedScore PTS'),
            backgroundColor: AppColors.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _exitWithPartialScore() async {
    _timer?.cancel();
    // Guardar puntaje acumulado actual al salirse (exigido en §4.2)
    await _api.submitScore(widget.bankId, _accumulatedScore);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cuestionario interrumpido. Puntaje guardado: $_accumulatedScore PTS'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryContainer)),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.bankTitle)),
        body: const Center(child: Text('No hay preguntas en este banco.')),
      );
    }

    final question = _questions[_currentIndex];
    final answers = question.respuestas;
    final double progress = (_currentIndex + 1) / _questions.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _exitWithPartialScore();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.bankTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryContainer),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.primaryContainer),
            onPressed: _exitWithPartialScore,
          ),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER INFO ROW (Streak pill & circular timer)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Functional Streak Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _streak > 0 
                          ? AppColors.streakOrange.withOpacity(0.12) 
                          : AppColors.outlineVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: _streak > 0
                          ? Border.all(color: AppColors.streakOrange, width: 1.5)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_fire_department, 
                          color: _streak > 0 ? AppColors.streakOrange : Colors.grey, 
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Racha x$_streak',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _streak > 0 ? AppColors.streakOrange : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Circular Pulsing Timer Glow
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryContainer.withOpacity(_timeLeft <= 4 ? 0.35 : 0.15),
                              blurRadius: _pulseAnimation.value,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                value: _timeLeft / 12,
                                strokeWidth: 4.5,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _timeLeft <= 4 ? AppColors.error : AppColors.secondaryContainer,
                                ),
                              ),
                            ),
                            Text(
                              '$_timeLeft',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _timeLeft <= 4 ? AppColors.error : AppColors.primaryContainer,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Question Index Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Pregunta ${_currentIndex + 1} de ${_questions.length}',
                  style: AppTextStyles.labelMd(color: AppColors.primaryContainer).copyWith(
                    fontSize: 11,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Question Statement Text
              Text(
                question.textoPregunta,
                style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface).copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 21,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),

              // Floating dynamic points popup
              AnimatedOpacity(
                opacity: _showFloatingScore ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    _floatingScoreText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Glassmorphism Option alternatives container with Shake animation
              Expanded(
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: child,
                    );
                  },
                  child: ListView.builder(
                    itemCount: answers.length,
                    itemBuilder: (context, index) {
                      final ans = answers[index];
                      final optionLetter = String.fromCharCode(65 + index); // A, B, C, D
                      final isSelected = _selectedAnswerIndex == index;

                      // Visual theme mapping for each state
                      Color cardBgColor = Colors.white;
                      Color borderColor = AppColors.outlineVariant.withOpacity(0.5);
                      Color letterBgColor = Colors.white;
                      Color letterTextColor = AppColors.onSurface;
                      Widget? feedbackIcon;

                      if (isSelected) {
                        cardBgColor = AppColors.primaryContainer.withOpacity(0.06);
                        borderColor = AppColors.primaryContainer;
                        letterBgColor = AppColors.primaryContainer;
                        letterTextColor = Colors.white;
                      }

                      // Correct/Incorrect Feedback state borders per §8.2
                      if (_isAnswered) {
                        if (ans.esCorrecta) {
                          cardBgColor = const Color(0xFFECFDF5); // light green
                          borderColor = Colors.green.shade500;
                          letterBgColor = Colors.green.shade500;
                          letterTextColor = Colors.white;
                          feedbackIcon = const Icon(Icons.check, color: Colors.green, size: 18);
                        } else if (isSelected) {
                          cardBgColor = const Color(0xFFFEF2F2); // light red
                          borderColor = AppColors.error;
                          letterBgColor = AppColors.error;
                          letterTextColor = Colors.white;
                          feedbackIcon = const Icon(Icons.close, color: AppColors.error, size: 18);
                        }
                      }

                      return GestureDetector(
                        onTap: _isAnswered
                            ? null
                            : () => _answerQuestion(index, ans.esCorrecta),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isSelected ? 0.04 : 0.01),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              // Letra indicativa A, B, C, D
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: letterBgColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.outlineVariant, width: 1.5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  optionLetter,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: letterTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              Expanded(
                                child: Text(
                                  ans.textoRespuesta,
                                  style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              
                              if (feedbackIcon != null) ...[
                                const SizedBox(width: 8),
                                feedbackIcon,
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom Progress Bar with Gold-to-Green gradient
              const SizedBox(height: 10),
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: constraints.maxWidth * progress,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [AppColors.secondaryContainer, AppColors.tertiaryFixedDim],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
