import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentModal extends StatefulWidget {
  final VoidCallback onOrderSuccess;

  const PaymentModal({super.key, required this.onOrderSuccess});

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  final _formKey = GlobalKey<FormState>();

  // Контроллеры
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  String _paymentMethod = 'Карта'; // Способ оплаты по умолчанию
  bool _isOrderComplete = false; // Для отображения сообщения об успехе

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: _isOrderComplete
          ? const Text(
              "Тапсырыс сәтті аяқталды!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )
          : const Text(
              "Төлем әдісі",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
      content: _isOrderComplete
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
                SizedBox(height: 16),
                Text(
                  "Тапсырысыңызға рахмет!\nБіз сізге жақын арада хабарласамыз.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Выбор способа оплаты
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Карта'),
                      selected: _paymentMethod == 'Карта',
                      onSelected: (selected) {
                        setState(() {
                          _paymentMethod = 'Карта';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Қолма-қол'),
                      selected: _paymentMethod == 'Қолма-қол',
                      onSelected: (selected) {
                        setState(() {
                          _paymentMethod = 'Қолма-қол';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Форма для оплаты картой
                if (_paymentMethod == 'Карта')
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _cardNumberController,
                          keyboardType: TextInputType.number,
                          maxLength: 19, // 16 цифр + пробелы
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _CardNumberInputFormatter(),
                          ],
                          decoration: const InputDecoration(
                            labelText: "Карта нөмірі",
                            hintText: "1234 5678 1234 5678",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Карта нөмірлерін енгізіңіз";
                            }
                            if (value.replaceAll(' ', '').length != 16) {
                              return "Карта нөмірлері кем дегенде 16 символ болуы керек";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cardHolderController,
                          keyboardType: TextInputType.name,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Za-z\s]')),
                          ],
                          decoration: const InputDecoration(
                            labelText: "Карта иесі (ағылшынша)",
                            hintText: "JOHN DOE",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Иесінің аты";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _expiryDateController,
                          keyboardType: TextInputType.number,
                          maxLength: 5, // 4 цифры + '/'
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ExpiryDateInputFormatter(),
                          ],
                          decoration: const InputDecoration(
                            labelText: "Жарамдылық мерзімі",
                            hintText: "MM/YY",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Жарамдылық мерзімін енгізіңіз";
                            }
                            if (!RegExp(r'^(0[1-9]|1[0-2])/\d{2}$')
                                .hasMatch(value)) {
                              return "Жарамдылық мерзім форматы дұрыс емес";
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CVVInputFormatter(),
                          ],
                          decoration: const InputDecoration(
                            labelText: "CVC код",
                            hintText: "XXX",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "CVC код енгізіңіз";
                            }
                            if (value.length != 3 ||
                                !RegExp(r'^\d{3}$').hasMatch(value)) {
                              return "CVC код форматы дұрыс емес";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Кнопка "Заказать"
                ElevatedButton(
                  onPressed: () {
                    if (_paymentMethod == 'Картой' &&
                        !_formKey.currentState!.validate()) {
                      return;
                    }

                    // Показать сообщение об успехе
                    setState(() {
                      _isOrderComplete = true;
                    });

                    widget.onOrderSuccess();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0A78D6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    "Заказать",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }
}

// Форматирование для номера карты
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i % 4 == 0 && i != 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Форматирование для срока действия карты
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length > 4) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class CVVInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', ''); // Removes any spaces
    if (text.length > 3) return oldValue; // Limits the input to 3 digits
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
