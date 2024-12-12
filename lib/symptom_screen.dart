import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SymptomScreen extends StatefulWidget {
  @override
  _SymptomScreenState createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final TextEditingController _symptomController = TextEditingController();

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e')),
      );
    }
  }

  // Semptomları analiz etme ve sonuçları gösterme
  Future<void> _analyzeSymptoms() async {
    final String symptomsText = _symptomController.text.trim().toLowerCase();
    if (symptomsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen belirtileri girin!')),
      );
      return;
    }

    List<String> symptomsList = symptomsText.split(',').map((e) => e.trim()).toList();

    // Her bir semptom için analiz yap
    List<String> resultText = [];
    for (var symptom in symptomsList) {
      String disease = "Belirlenemedi";
      String suggestions = "Daha fazla bilgi gerekebilir. Lütfen bir doktora danışın.";

      symptomsDatabase.forEach((key, value) {
        if (symptom.contains(key)) {
          disease = value["disease"]!;
          suggestions = value["suggestions"]!;
        }
      });

      resultText.add('Semptom: $symptom\nTahmin edilen hastalık: $disease\nÖneriler:\n$suggestions\n');
    }

    // Firebase'e semptom verisini gönder
    await _sendSymptoms(symptomsList);

    // Sonuçları göster
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tahmin Sonucu'),
        content: Text(resultText.join('\n\n')),
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
                Text(
                  'Health Management System',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  controller: _symptomController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Belirtileri buraya yazın... (Virgülle ayırın)',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 12.0,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _analyzeSymptoms,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  icon: Icon(Icons.send, color: Colors.white),
                  label: Text(
                    'Gönder',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

