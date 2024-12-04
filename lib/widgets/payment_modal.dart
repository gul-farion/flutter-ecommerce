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

  String _paymentMethod = 'Наличные'; // Способ оплаты по умолчанию
  bool _isOrderComplete = false; // Для отображения сообщения об успехе

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: _isOrderComplete
          ? const Text(
              "Заказ успешно оформлен!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )
          : const Text(
              "Способ оплаты",
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
                  "Спасибо за ваш заказ!\nМы свяжемся с вами в ближайшее время.",
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
                      label: const Text('Картой'),
                      selected: _paymentMethod == 'Картой',
                      onSelected: (selected) {
                        setState(() {
                          _paymentMethod = 'Картой';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Наличные'),
                      selected: _paymentMethod == 'Наличные',
                      onSelected: (selected) {
                        setState(() {
                          _paymentMethod = 'Наличные';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Форма для оплаты картой
                if (_paymentMethod == 'Картой')
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
                            labelText: "Номер карты",
                            hintText: "1234 5678 1234 5678",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Введите номер карты";
                            }
                            if (value.replaceAll(' ', '').length != 16) {
                              return "Номер карты должен содержать 16 цифр";
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
                            labelText: "Владелец карты",
                            hintText: "JOHN DOE",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Введите имя владельца";
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
                            labelText: "Срок действия",
                            hintText: "MM/YY",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Введите срок действия";
                            }
                            if (!RegExp(r'^(0[1-9]|1[0-2])/\d{2}$')
                                .hasMatch(value)) {
                              return "Некорректный формат срока действия";
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
                    backgroundColor: Colors.black,
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
