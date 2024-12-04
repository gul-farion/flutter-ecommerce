import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeliveryModal extends StatefulWidget {
  const DeliveryModal({super.key});

  @override
  State<DeliveryModal> createState() => _DeliveryModalState();
}

class _DeliveryModalState extends State<DeliveryModal> {
  String deliveryOption = "Самовывоз";
  String? selectedCity;
  String? deliveryAddress;
  TimeOfDay? selectedTime;
  bool asapDelivery = true;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pickupLocationController =
      TextEditingController();

  final Map<String, List<String>> cityLocations = {
    "Актобе": ["проспект Абилкайыр хана, 52"],
    "Астана": ["ул. Сыганак, 60/5"],
    "Алматы": ["ул. Сатпаева, 90"],
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        "Выберите способ получения",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ChoiceChip(
                    label: const Text("Самовывоз"),
                    selected: deliveryOption == "Самовывоз",
                    onSelected: (isSelected) {
                      setState(() {
                        deliveryOption = "Самовывоз";
                        _clearFields();
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text("Доставка"),
                    selected: deliveryOption == "Доставка",
                    onSelected: (isSelected) {
                      setState(() {
                        deliveryOption = "Доставка";
                        _clearFields();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCity,
                items: cityLocations.keys
                    .map((city) => DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        ))
                    .toList(),
                decoration: _inputDecoration("Выберите город"),
                onChanged: (value) {
                  setState(() {
                    selectedCity = value;
                    if (deliveryOption == "Самовывоз") {
                      _pickupLocationController.text =
                          cityLocations[value]?.first ?? "";
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Пожалуйста, выберите город";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (deliveryOption == "Самовывоз" && selectedCity != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _pickupLocationController,
                      readOnly: true,
                      decoration: _inputDecoration("Точка самовывоза"),
                    ),
                    const SizedBox(height: 16),
                    _buildPhoneNumberField(),
                  ],
                ),

              // Поля для доставки
              if (deliveryOption == "Доставка" && selectedCity != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: _inputDecoration("Адрес доставки"),
                      onChanged: (value) {
                        setState(() {
                          deliveryAddress = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Введите адрес доставки";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Вариант "Как можно скорее" или выбор времени
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text("Как можно скорее"),
                            value: true,
                            groupValue: asapDelivery,
                            onChanged: (value) {
                              setState(() {
                                asapDelivery = value!;
                                selectedTime = null;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text("Выбрать время"),
                            value: false,
                            groupValue: asapDelivery,
                            onChanged: (value) {
                              setState(() {
                                asapDelivery = value!;
                                if (asapDelivery) selectedTime = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    // Поле выбора времени, если выбран "Выбрать время"
                    if (!asapDelivery)
                      GestureDetector(
                        onTap: () => _selectTime(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: TextEditingController(
                              text: selectedTime != null
                                  ? "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}"
                                  : null,
                            ),
                            decoration: _inputDecoration("Выберите время доставки"),
                            validator: (value) {
                              if (!asapDelivery && selectedTime == null) {
                                return "Выберите время доставки";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildPhoneNumberField(),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _showSuccessMessage(context);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            disabledBackgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            "Сохранить",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _PhoneNumberFormatter(),
      ],
      decoration: _inputDecoration("Номер телефона"),
      validator: (value) {
        if (value == null || value.isEmpty || value.length != 12) {
          return "Введите корректный номер телефона (+7XXXXXXXXXX)";
        }
        return null;
      },
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  void _clearFields() {
    selectedCity = null;
    _pickupLocationController.clear();
    deliveryAddress = null;
    selectedTime = null;
    asapDelivery = true;
    _phoneController.clear();
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(4),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 3.0),
      ),
    );
  }

  void _showSuccessMessage(BuildContext context) {
    final snackBar = SnackBar(
      content: Text(
        deliveryOption == "Самовывоз"
            ? "Самовывоз подтверждён. Город: $selectedCity"
            : "Доставка подтверждена. Адрес: $deliveryAddress, Время: ${asapDelivery ? 'Как можно скорее' : '${selectedTime?.hour}:${selectedTime?.minute.toString().padLeft(2, '0')}'}",
      ),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Ensure text starts with "+7"
    if (!text.startsWith("+7")) {
      text = "+7" + text.replaceAll(RegExp(r'^\+?7'), '');
    }

    // Limit length to 12 characters (+7XXXXXXXXXX)
    if (text.length > 12) {
      text = text.substring(0, 12);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
