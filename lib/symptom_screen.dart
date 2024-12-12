import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SymptomScreen extends StatefulWidget {
  @override
  _SymptomScreenState createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _tensionController = TextEditingController();
  final TextEditingController _capillaryRefillController = TextEditingController();

  // Sabit belirtiler ve hastalık veritabanı
  Map<String, Map<String, String>> symptomsDatabase = {
    "ates": {
      "disease": "Grip",
      "suggestions": "Bol sıvı tüketin, dinlenin ve gerekirse bir doktora başvurun."
    },
    "bas agrisi": {
      "disease": "Migren",
      "suggestions": "Sessiz ve karanlık bir ortamda dinlenin, ağrı kesici kullanabilirsiniz."
    },
    "mide bulantisi": {
      "disease": "Gida Zehirlenmesi",
      "suggestions": "Bol su için, hafif yiyecekler tüketin ve durum devam ederse bir doktora danışın."
    },
    "oksuruk": {
      "disease": "Soguk Algınlığı",
      "suggestions": "Ilımlı sıcaklıkta sıvı alımı yapın, gerekirse öksürük şurubu kullanın."
    },
    "bogaz agrisi": {
      "disease": "Bogaz Enfeksiyonu",
      "suggestions": "Sıcak tuzlu su ile gargara yapın, bol sıvı içmeye özen gösterin."
    },
    "yorgunluk": {
      "disease": "Hastalık veya Asiri Calisma",
      "suggestions": "Yeterli dinlenme ve uyku düzeni sağlamak önemli. Uzun süreli yorgunluk için doktora başvurun."
    },
    "sislik": {
      "disease": "Sindirim Sorunlari",
      "suggestions": "Yavaş yemek yiyin, az ama sık öğünler tüketin. Mideyi rahatlatan içecekler tüketebilirsiniz."
    },
    "ishal": {
      "disease": "Gida Zehirlenmesi veya Virus Enfeksiyonu",
      "suggestions": "Bol su içerek vücudun sıvı kaybını dengeleyin. Şiddetli ise doktora başvurun."
    },
    "burun tikanikligi": {
      "disease": "Soguk Algınlığı veya Alerji",
      "suggestions": "Burun açıcı spreyler ve tuzlu su ile burun temizliği yapabilirsiniz. Alerji varsa antihistaminik kullanabilirsiniz."
    },
    "kas agrisi": {
      "disease": "Kas Gerilmesi veya Egzersiz Sonrasi",
      "suggestions": "Ilımlı sıcaklıkta duş alın, rahatlatıcı masaj yapın, ve dinlenin."
    },
    "gozlerde agri": {
      "disease": "Goz Iltihabi veya Alerji",
      "suggestions": "Buz kompresi uygulayın, gözlerinizi ovuşturmayın ve alerji ilacı kullanın."
    },
    "bas donmesi": {
      "disease": "Dusuk Tansiyon veya Ic Kulak Sorunlari",
      "suggestions": "Yavaşça oturun ve bol sıvı tüketin. Baş dönmesi devam ederse bir doktora başvurun."
    },
    "deri dokuntusu": {
      "disease": "Alerjik Reaksiyon veya Deri Enfeksiyonu",
      "suggestions": "Alerji ilacı kullanın ve etkilenen bölgeyi temiz tutun. Durum ciddiyse bir dermatologa başvurun."
    },
    "nefes darligi": {
      "disease": "Astim veya Solunum Yolu Enfeksiyonu",
      "suggestions": "Derin nefes almaya çalışın ve inhaler kullanın. Durum kötüleşirse acilen doktora başvurun."
    },
    "kas gucsuzlugu": {
      "disease": "Neurolojik Sorunlar veya Asiri Yorgunluk",
      "suggestions": "Yeterli dinlenmeye özen gösterin. Güçsüzlük uzun süre devam ederse doktora başvurun."
    },
  };

  // Semptomları Firebase'e bir arada gönderme
  Future<void> _sendSymptoms(List<String> symptoms) async {
    try {
      await FirebaseFirestore.instance.collection('symptoms').add({
        'symptoms': symptoms,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Belirtiler başarıyla gönderildi!')),
      );
      _symptomController.clear();
      _tensionController.clear();
      _capillaryRefillController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e')),
      );
    }
  }

  // Semptomları analiz etme ve sonuçları gösterme
  Future<void> _analyzeSymptoms() async {
    final String symptomsText = _symptomController.text.trim().toLowerCase();
    final String tension = _tensionController.text.trim();
    final String capillaryRefill = _capillaryRefillController.text.trim();

    if (symptomsText.isEmpty || tension.isEmpty || capillaryRefill.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm bilgileri doldurun!')),
      );
      return;
    }

    List<String> symptomsList = symptomsText.split(',').map((e) => e.trim()).toList();

    // En yaygın hastalığı bulma
    Map<String, int> diseaseCount = {};
    for (var symptom in symptomsList) {
      symptomsDatabase.forEach((key, value) {
        if (symptom.contains(key)) {
          diseaseCount[value["disease"]!] = (diseaseCount[value["disease"]!] ?? 0) + 1;
        }
      });
    }

    String disease = diseaseCount.isEmpty
        ? "Belirlenemedi"
        : diseaseCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    String suggestions = "Daha fazla bilgi gerekebilir. Lütfen bir doktora danışın.";
    symptomsDatabase.forEach((key, value) {
      if (value["disease"] == disease) {
        suggestions = value["suggestions"]!;
      }
    });

    // Tansiyon değeri işlemi (örneğin: 120/80)
    final parts = tension.split('/');
    int systolic = 0;
    int diastolic = 0;

    if (parts.length == 2) {
      try {
        systolic = int.parse(parts[0].trim());
        diastolic = int.parse(parts[1].trim());
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tansiyon değeri geçersiz! Lütfen doğru formatta girin.')),
        );
        return;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tansiyonu doğru formatta girin (örneğin: 120/80).')),
      );
      return;
    }

    // Kırmızı, sarı, yeşil kodlama (tansiyon ve kapiler geri dolum süresine göre)
    String healthStatus = "Yeşil"; // Normal
    if (systolic < 90 || int.parse(capillaryRefill) > 3) {
      healthStatus = "Kırmızı"; // Acil durum
    } else if (systolic < 110) {
      healthStatus = "Sarı"; // Dikkatli olun
    }

    // Firebase'e semptom verisini gönder
    await _sendSymptoms(symptomsList);

    // Sonuçları göster
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tahmin Sonucu'),
        content: Text(
            'Tahmin edilen hastalık: $disease\n\nÖneriler:\n$suggestions\n\nSağlık Durumu: $healthStatus'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: _symptomController,
                  decoration: InputDecoration(
                    labelText: 'Belirtiler (Virgülle ayırın)',
                    hintText: 'Örneğin: ateş, baş ağrısı, yorgunluk',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _tensionController,
                  decoration: InputDecoration(
                    labelText: 'Tansiyon (Örneğin: 120/80)',
                    hintText: 'Tansiyonunuzu girin',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _capillaryRefillController,
                  decoration: InputDecoration(
                    labelText: 'Kapiller Geri Dolum Süresi (saniye)',
                    hintText: 'Kapiller geri dolum sürenizi girin',
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _analyzeSymptoms,
                  child: Text('Belirtileri Analiz Et'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
