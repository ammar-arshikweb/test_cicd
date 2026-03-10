import 'dart:math';
import 'package:flutter/material.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/values/colors.dart';

class MathCaptcha extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback? onEmpty;
  final VoidCallback? onWrong;

  const MathCaptcha({super.key, required this.onSuccess, this.onEmpty, this.onWrong});

  @override
  State<MathCaptcha> createState() => _MathCaptchaState();
}

class _MathCaptchaState extends State<MathCaptcha> {
  final TextEditingController _controller = TextEditingController();
  late int _num1;
  late int _num2;
  late String _operator;
  late int _answer;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    final rand = Random();
    List<String> operators = ['+', '-', '*'];
    _operator = operators[rand.nextInt(operators.length)];

    switch (_operator) {
      case '+':
        _num1 = rand.nextInt(10) + 1;
        _num2 = rand.nextInt(10) + 1;
        _answer = _num1 + _num2;
        break;
      case '-':
        _num1 = rand.nextInt(10) + 1;
        _num2 = rand.nextInt(10) + 1;
        if (_num1 < _num2) {
          final temp = _num1;
          _num1 = _num2;
          _num2 = temp;
        }
        _answer = _num1 - _num2;
        break;
      case '*':
        _num1 = rand.nextInt(10) + 1;
        _num2 = rand.nextInt(9) + 1;
        _answer = _num1 * _num2;
        break;
    }

    _controller.clear();
    _errorText = null;
  }

  void _verifyAnswer() {
    final input = _controller.text.trim();

    if (input.isEmpty) {
      widget.onEmpty?.call();
      setState(() {
        _errorText = '';
      });
      return;
    }

    if (int.tryParse(input) == _answer) {
      widget.onSuccess();
      setState(() {
        _errorText = null;
      });
    } else {
      widget.onWrong?.call();
      setState(() {
        _errorText = 'Incorrect answer';
      });
      _generateCaptcha(); // regenerate on wrong
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: MColors.white, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 10),
              Text('Solve:', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                decoration: BoxDecoration(color: MColors.grey.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text('$_num1 $_operator $_num2 = ?', style: Theme.of(context).textTheme.bodyMedium)),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 90,
                height: 36,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ans.',
                    hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MColors.grey),
                    errorText: _errorText,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    border: const OutlineInputBorder(),
                    filled: true,
                    counterText: '',
                    errorStyle: TextStyle(color: MColors.red, fontSize: 0),
                    fillColor: MColors.primaryGreen.withValues(alpha: 0.1),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          width: 80,
          decoration: BoxDecoration(color: MColors.primaryGreen, borderRadius: BorderRadius.circular(10)),
          child: TextButton(onPressed: () => GlobalTap.safeTap(_verifyAnswer), child: Text('Submit', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MColors.white))),
        ),
      ],
    );
  }
}
