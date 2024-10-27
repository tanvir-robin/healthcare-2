class AvailableDoctor {
  final int id;
  final String name;
  final String sector;
  final int experience;
  final String patients;
  final String image;
  final String degrees;
  final String email;
  final String password;

  AvailableDoctor({
    required this.id,
    required this.name,
    required this.sector,
    required this.experience,
    required this.patients,
    required this.image,
    required this.degrees,
    required this.email,
    required this.password,
  });
}

List<AvailableDoctor> demoAvailableDoctors = [
  AvailableDoctor(
    id: 1,
    name: "Dr. Tanvir Mahmud",
    sector: "Cardiologist",
    experience: 10,
    patients: '3.5K',
    image: "assets/images/doc1.jpg",
    degrees: '''MBBS (DMC), MD (Cardiology) BSMMU, FACC (USA),
    Fellowship in Interventional Cardiology (Singapore), 
    Specialized Training in Cardiac Imaging (UK)''',
    email: "dr.tanvir@gmail.com",
    password: "cardio123",
  ),
  AvailableDoctor(
    id: 2,
    name: "Dr. Nusrat Jahan",
    sector: "Dermatologist",
    experience: 7,
    patients: '2.2K',
    image: "assets/images/doc2.jpeg",
    degrees: '''MBBS (CMC), DDV (India), MD (Dermatology) BSMMU,
    Advanced Training in Cosmetic Dermatology (Thailand), 
    Specialization in Laser Therapy and Skin Rejuvenation (Singapore)''',
    email: "dr.nusrat@gmail.com",
    password: "derma456",
  ),
  AvailableDoctor(
    id: 3,
    name: "Dr. Fahim Rahman",
    sector: "Pediatrician",
    experience: 12,
    patients: '4.8K',
    image: "assets/images/doc3.jpg",
    degrees: '''MBBS (BSMC), DCH (India), MD (Pediatrics) BSMMU,
    Fellow of Pediatric Neurology (Australia), 
    Specialized Training in Neonatal Care (Japan)''',
    email: "dr.fahim@gmail.com",
    password: "peds789",
  ),
  AvailableDoctor(
    id: 4,
    name: "Dr. Nabila Khan",
    sector: "Gynecologist",
    experience: 15,
    patients: '5.1K',
    image: "assets/images/doc4.png",
    degrees: '''MBBS (SSMC), FCPS (Gynecology & Obstetrics),
    MRCOG (UK), Advanced Training in Reproductive Endocrinology (Germany), 
    Specialized in Maternal-Fetal Medicine (USA)''',
    email: "dr.nabila@gmail.com",
    password: "gyne123",
  ),
];
