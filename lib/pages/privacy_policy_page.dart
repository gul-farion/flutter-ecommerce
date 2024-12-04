import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        title: const Text(
          'Политика конфиденциальности',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Политика конфиденциальности',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Эта политика конфиденциальности объясняет, как мы собираем, используем, и защищаем вашу личную информацию.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 20),

            // Section 2: Data Collection
            Text(
              '1. Сбор данных',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Мы собираем следующую информацию о вас:\n\n'
              '• Личные данные, такие как имя, адрес, номер телефона.\n'
              '• Информация о заказах: выбранные товары, предпочтения.\n'
              '• Данные для платежей: кредитная карта или другая платежная информация.\n',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 20),

            // Section 3: Data Usage
            Text(
              '2. Использование данных',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Мы используем собранные данные для следующих целей:\n\n'
              '• Для обработки ваших заказов и доставки продуктов.\n'
              '• Для улучшения качества нашего обслуживания.\n'
              '• Для предоставления персонализированных предложений.\n',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 20),

            // Section 4: Data Sharing
            Text(
              '3. Передача данных третьим лицам',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Мы не передаем ваши личные данные третьим лицам, кроме случаев, предусмотренных законодательством, или если это необходимо для выполнения заказа (например, при передаче данных службе доставки).',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 20),

            // Section 5: Security
            Text(
              '4. Защита данных',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Мы принимаем все необходимые меры для защиты ваших данных от несанкционированного доступа, изменения или удаления. Однако мы не можем гарантировать абсолютную безопасность информации при передаче через интернет.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 20),

            // Section 6: User Rights
            Text(
              '5. Ваши права',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Вы имеете право:\n\n'
              '• Запрашивать доступ к вашим данным.\n'
              '• Исправлять или удалять ваши данные.\n'
              '• Отказаться от использования ваших данных для маркетинговых целей.\n',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 20),

            // Section 7: Contact Information
            Text(
              '6. Контактная информация',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Если у вас есть вопросы о нашей политике конфиденциальности, вы можете связаться с нами по адресу: privacy@johnnys-pizza.kz.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
