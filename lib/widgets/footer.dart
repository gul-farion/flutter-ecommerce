import 'package:flutter/material.dart';
import 'package:pizzeria_app/pages/privacy_policy_page.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      
      color: const Color(0xFF000000),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Пиццерия Джоннис',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Адрес: Казахстан, Актобе, Абулхаир хана 52',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              // const SizedBox(height: 5),
              Text(
                'БИН: 200840021825 | Банк: Kaspi Bank | БИК: CASPKZKA',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              // const SizedBox(height: 5),
              Text(
                'Номер счета: KZ45722S000014700255',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyPage()),
                      );
                    },
                    child: const Text(
                      'Политика конфиденциальности',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.window_sharp, color: Colors.white, size: 28),
                  SizedBox(width: 15),
                  Icon(Icons.apple, color: Colors.white, size: 28),
                  SizedBox(width: 15),
                  Icon(Icons.computer_sharp, color: Colors.white, size: 28),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Акции, скидки, кэшбек — в нашем приложении!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
