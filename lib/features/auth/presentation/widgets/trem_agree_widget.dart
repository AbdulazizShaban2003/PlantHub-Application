import 'package:flutter/material.dart';

class TermsAgreementWidget extends StatefulWidget {
  final ValueChanged<bool>? onChanged;

  const TermsAgreementWidget({super.key, this.onChanged});

  @override
  _TermsAgreementWidgetState createState() => _TermsAgreementWidgetState();
}

class _TermsAgreementWidgetState extends State<TermsAgreementWidget> {
  bool _isAgreed = false;
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _isAgreed,
              onChanged: (bool? value) {
                setState(() {
                  _isAgreed = value ?? false;
                  _showError = false;
                });
                widget.onChanged?.call(_isAgreed);
              },
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    WidgetSpan(
                      child: Text(
                          'Terms',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    const TextSpan(text: ' and '),
                    WidgetSpan(
                      child:  Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_showError)
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              'You must agree to the terms to continue',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  bool validate() {
    setState(() {
      _showError = !_isAgreed;
    });
    return _isAgreed;
  }
}
