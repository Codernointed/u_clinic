import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';
import 'package:u_clinic/presentation/widgets/category_card.dart';
import 'package:u_clinic/presentation/widgets/search_bar.dart';
import 'package:u_clinic/presentation/widgets/section_header.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Map<String, String>> _categories = [
    {'title': "Men's Health", 'imagePath': 'assets/images/car.jpg'},
    {'title': "Women's Health", 'imagePath': 'assets/images/car.jpg'},
    {'title': 'Mental Health', 'imagePath': 'assets/images/car.jpg'},
    {'title': 'Child Health', 'imagePath': 'assets/images/car.jpg'},
    {'title': 'Elderly Care', 'imagePath': 'assets/images/car.jpg'},
  ];

  // Placeholder data for glossary terms
  final Map<String, List<Map<String, String>>> _glossaryTerms = {
    'A': [
      {
        'term': 'Abdominal Pain',
        'definition': 'Pain felt anywhere between the chest and groin.',
      },
      {
        'term': 'Acne',
        'definition':
            'A skin condition that occurs when hair follicles become clogged with oil and dead skin cells.',
      },
      {
        'term': 'Albinism',
        'definition':
            'A group of inherited disorders characterized by little or no melanin production.',
      },
      {
        'term': 'Alcoholism',
        'definition':
            'A chronic disease characterized by uncontrolled drinking and preoccupation with alcohol.',
      },
      {
        'term': 'Allergies',
        'definition':
            'A condition in which the immune system reacts abnormally to a foreign substance.',
      },
      {
        'term': "Alzheimer's Disease",
        'definition':
            'A progressive disorder that causes brain cells to waste away (degenerate) and die.',
      },
      {
        'term': 'Anaemia',
        'definition':
            'A condition in which you lack enough healthy red blood cells to carry adequate oxygen to your body\'s tissues.',
      },
      {
        'term': 'Anxiety',
        'definition':
            'A feeling of worry, nervousness, or unease, typically about an imminent event or something with an uncertain outcome.',
      },
      {
        'term': 'Appendicitis',
        'definition':
            'An inflammation of the appendix, a finger-shaped pouch that projects from your colon on the lower right side of your abdomen.',
      },
      {
        'term': 'Arthritis',
        'definition':
            'Inflammation of one or more joints, causing pain and stiffness that can worsen with age.',
      },
      {
        'term': 'Asthma',
        'definition':
            'A condition in which your airways narrow and swell and may produce extra mucus.',
      },
      {
        'term': 'Autism',
        'definition':
            'A developmental disorder characterized by difficulties with social interaction and communication, and by restricted and repetitive behavior.',
      },
    ],
    'B': [
      {'term': 'Back Pain', 'definition': 'Discomfort or aching in the back.'},
      {
        'term': 'Baldness',
        'definition': 'The partial or complete lack of hair.',
      },
      {
        'term': 'Bilharzia',
        'definition':
            'A disease caused by parasitic flatworms called schistosomes.',
      },
      {
        'term': 'Birth Defects',
        'definition': 'Physical abnormalities present at birth.',
      },
      {
        'term': 'Blindness',
        'definition': 'The state or condition of being unable to see.',
      },
      {
        'term': 'Blood Cell Disorders',
        'definition':
            'Conditions affecting red blood cells, white blood cells, or platelets.',
      },
      {
        'term': 'Body Piercings and Tattoos',
        'definition': 'Forms of body modification.',
      },
      {
        'term': 'Brain Disorders',
        'definition': 'Conditions affecting the brain.',
      },
      {
        'term': 'Breast Cancer',
        'definition': 'Cancer that forms in the cells of the breasts.',
      },
      {
        'term': 'Bug Bites',
        'definition': 'Skin irritation or injury caused by an insect bite.',
      },
      {
        'term': 'Burns',
        'definition':
            'Tissue damage resulting from heat, overexposure to the sun or other radiation, or chemical or electrical contact.',
      },
    ],
    'C': [
      {
        'term': 'Cancer',
        'definition':
            'A disease in which abnormal cells divide uncontrollably and destroy body tissue.',
      },
      {
        'term': 'Cavities',
        'definition':
            'Permanently damaged areas in the hard surface of your teeth that develop into tiny openings or holes.',
      },
      {
        'term': 'Chest Pain',
        'definition':
            'Discomfort or pain felt anywhere along the front of your body between your neck and upper abdomen.',
      },
      {
        'term': 'Chlamydia',
        'definition':
            'A common sexually transmitted infection (STI) that can infect both men and women.',
      },
      {
        'term': 'Cholera',
        'definition':
            'An acute diarrheal illness caused by infection of the intestine with Vibrio cholerae bacteria.',
      },
      {
        'term': 'Common Cold',
        'definition':
            'A viral infectious disease of the upper respiratory tract that primarily affects the respiratory mucosa of the nose, throat, sinuses, and larynx.',
      },
      {
        'term': 'Constipation',
        'definition':
            'A condition in which you may have fewer than three bowel movements a week; stools are hard, dry, or lumpy; stools are difficult or painful to pass; or you have a feeling that not all stool has passed.',
      },
      {
        'term': 'Coronary Artery Disease',
        'definition': 'Damage or disease in the heart\'s major blood vessels.',
      },
      {
        'term': 'COVID-19',
        'definition':
            'A contagious disease caused by severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2).',
      },
    ],
    'D': [
      {
        'term': 'Dandruff',
        'definition':
            'A common condition that causes the skin on the scalp to flake.',
      },
      {
        'term': 'Deafness',
        'definition': 'The partial or total inability to hear.',
      },
      {
        'term': 'Dengue',
        'definition':
            'A mosquito-borne viral infection causing a severe flu-like illness.',
      },
      {
        'term': 'Depression',
        'definition':
            'A mood disorder causing a persistent feeling of sadness and loss of interest.',
      },
      {
        'term': 'Diabetes (Type 1)',
        'definition':
            'A chronic condition in which the pancreas produces little or no insulin.',
      },
      {
        'term': 'Diabetes (Type 2)',
        'definition':
            'A chronic condition that affects the way the body processes blood sugar (glucose).',
      },
      {
        'term': 'Diarrhoea',
        'definition':
            'Loose, watery stools occurring more frequently than usual.',
      },
      {
        'term': 'Digestion Problems',
        'definition': 'Issues related to the breakdown and absorption of food.',
      },
      {
        'term': 'Dizziness',
        'definition': 'A sensation of spinning or unsteadiness.',
      },
      {
        'term': 'Drug Addiction',
        'definition':
            'A chronic, relapsing disorder characterized by compulsive drug seeking and use despite adverse consequences.',
      },
    ],
    'E': [
      {
        'term': 'Ear Infections',
        'definition':
            'An infection of the middle ear, the air-filled space behind the eardrum.',
      },
      {
        'term': 'Eating Disorders',
        'definition':
            'Illnesses that are characterized by irregular eating habits and severe distress or concern about body weight or shape.',
      },
      {
        'term': 'Ebola',
        'definition':
            'A rare but deadly virus that causes fever, body aches, and diarrhea, and sometimes bleeding inside and outside the body.',
      },
      {
        'term': 'Eczema',
        'definition': 'A condition that makes your skin red and itchy.',
      },
      {
        'term': 'Epilepsy',
        'definition':
            'A neurological disorder marked by sudden recurrent episodes of sensory disturbance, loss of consciousness, or convulsions, associated with abnormal electrical activity in the brain.',
      },
    ],
    'F': [
      {
        'term': 'Fever',
        'definition':
            'A temporary increase in your body temperature, often due to an illness.',
      },
      {
        'term': 'Female Reproductive System',
        'definition':
            'The internal and external sex organs of a female that work together for the purpose of sexual reproduction.',
      },
      {
        'term': 'Female Circumcision',
        'definition':
            'The ritual cutting or removal of some or all of the external female genitalia.',
      },
      {
        'term': 'Fibroids',
        'definition':
            'Noncancerous growths in the uterus that can develop during a woman\'s childbearing years.',
      },
      {
        'term': 'Flu',
        'definition':
            'A common viral infection that can be deadly, especially in high-risk groups.',
      },
      {
        'term': 'Food Addiction',
        'definition':
            'A behavioral addiction that is characterized by the compulsive consumption of palatable foods.',
      },
      {
        'term': 'Food Poisoning',
        'definition': 'Illness caused by eating contaminated food.',
      },
      {
        'term': 'Fungal Skin Infection',
        'definition': 'Skin infections caused by various types of fungi.',
      },
    ],
    'G': [
      {
        'term': 'Gallstones',
        'definition':
            'Hardened deposits of digestive fluid that can form in your gallbladder.',
      },
      {
        'term': 'Genital Herpes',
        'definition':
            'A common sexually transmitted infection marked by genital pain and sores.',
      },
      {
        'term': 'Glaucoma',
        'definition':
            'A group of eye conditions that damage the optic nerve, the health of which is vital for good vision.',
      },
      {
        'term': 'Gonorrhea',
        'definition':
            'A sexually transmitted bacterial infection that, if untreated, may cause infertility.',
      },
      {
        'term': 'Gout',
        'definition':
            'A form of arthritis characterized by severe pain, redness, and tenderness in joints.',
      },
      {
        'term': 'Guinea Worm',
        'definition': 'A parasitic infection caused by the Guinea worm.',
      },
      {
        'term': 'Gum Disease',
        'definition':
            'An inflammation of the gums that can progress to affect the bone that surrounds and supports your teeth.',
      },
    ],
    'H': [
      {'term': 'Hair Loss', 'definition': 'The thinning of hair on the scalp.'},
      {'term': 'Headache', 'definition': 'Pain in any region of the head.'},
      {
        'term': 'Heartburn',
        'definition':
            'A burning pain in your chest, just behind your breastbone.',
      },
      {
        'term': 'Hemorrhoids',
        'definition':
            'Swollen veins in your anus and lower rectum, similar to varicose veins.',
      },
      {'term': 'Hepatitis', 'definition': 'Inflammation of the liver.'},
      {
        'term': 'Hernia',
        'definition':
            'A bulging of an organ or tissue through an abnormal opening.',
      },
      {
        'term': 'HIV',
        'definition':
            'Human immunodeficiency virus, a virus that attacks the body\'s immune system.',
      },
      {
        'term': 'HPV',
        'definition':
            'Human papillomavirus, a common viral infection that can cause skin or mucous membrane growths (warts).',
      },
      {'term': 'Hypertension', 'definition': 'High blood pressure.'},
    ],
    'I': [
      {
        'term': 'Improving Brain Function',
        'definition':
            'Strategies and activities aimed at enhancing cognitive abilities.',
      },
      {
        'term': 'Indigestion',
        'definition': 'Discomfort in your upper abdomen.',
      },
      {
        'term': 'Infertility',
        'definition': 'The inability to conceive children.',
      },
      {
        'term': 'Insomnia',
        'definition': 'Persistent problems falling and staying asleep.',
      },
    ],
    'J': [
      {
        'term': 'Joint Pain',
        'definition':
            'Discomfort, aches, and soreness in any of the body’s joints.',
      },
    ],
    'K': [
      {
        'term': 'Kidney Problems',
        'definition':
            'Conditions that affect the kidneys\' ability to function properly.',
      },
      {
        'term': 'Kidney Stones',
        'definition':
            'Hard deposits made of minerals and salts that form inside your kidneys.',
      },
      {
        'term': 'Kwashiorkor',
        'definition':
            'A form of severe protein malnutrition characterized by edema and an enlarged liver with fatty infiltrates.',
      },
    ],
    'L': [
      {
        'term': 'Leg Pain',
        'definition': 'Pain or discomfort anywhere in the leg.',
      },
      {
        'term': 'Leishmaniasis',
        'definition':
            'A parasitic disease that is found in parts of the tropics, subtropics, and southern Europe.',
      },
      {
        'term': 'Leprosy',
        'definition':
            'A chronic, curable infectious disease mainly causing skin lesions and nerve damage.',
      },
      {
        'term': 'Lice',
        'definition':
            'Tiny, wingless, parasitic insects that feed on human blood.',
      },
      {
        'term': 'Low Testosterone',
        'definition':
            'A condition in which the testes don\'t produce enough testosterone.',
      },
      {'term': 'Lung Cancer', 'definition': 'Cancer that begins in the lungs.'},
    ],
    'M': [
      {
        'term': 'Malaria',
        'definition': 'A mosquito-borne disease caused by a parasite.',
      },
      {
        'term': 'Male Menopause',
        'definition':
            'A term sometimes used to describe age-related changes in male hormone levels.',
      },
      {
        'term': 'Male Reproductive System',
        'definition':
            'The system of sex organs within an organism that work together for the purpose of sexual reproduction in males.',
      },
      {
        'term': 'Malnutrition',
        'definition':
            'Deficiencies, excesses, or imbalances in a person’s intake of energy and/or nutrients.',
      },
      {
        'term': 'Masturbation',
        'definition':
            'Sexual stimulation of one\'s own genitals for sexual arousal or other sexual pleasure, usually to the point of orgasm.',
      },
      {
        'term': 'Menopause',
        'definition': 'The time that marks the end of your menstrual cycles.',
      },
      {
        'term': "Men's Health",
        'definition':
            'A state of complete physical, mental, and social well-being as experienced by men.',
      },
      {
        'term': 'Meningitis',
        'definition':
            'Inflammation of the fluid and membranes (meninges) surrounding your brain and spinal cord.',
      },
      {
        'term': 'Migraine',
        'definition':
            'A headache that can cause severe throbbing pain or a pulsing sensation, usually on one side of the head.',
      },
      {'term': 'Mouth Ulcers', 'definition': 'Definition not available.'},
      {'term': 'Mpox', 'definition': 'Definition not available.'},
      {'term': 'Multiple Sclerosis', 'definition': 'Definition not available.'},
      {'term': 'Mumps', 'definition': 'Definition not available.'},
    ],
    'N': [
      {'term': 'Nausea', 'definition': 'Definition not available.'},
      {'term': 'Night Eating', 'definition': 'Definition not available.'},
      {'term': 'Nosebleed', 'definition': 'Definition not available.'},
      {
        'term': 'Nutrition (Healthy Food)',
        'definition': 'Definition not available.',
      },
    ],
    'O': [
      {'term': 'Obesity', 'definition': 'Definition not available.'},
      {'term': 'Onchocerciasis', 'definition': 'Definition not available.'},
      {
        'term': 'Overweight Children',
        'definition': 'Definition not available.',
      },
    ],
    'P': [
      {
        'term': "Parkinson's Disease",
        'definition': 'Definition not available.',
      },
      {'term': 'Phobia', 'definition': 'Definition not available.'},
      {'term': 'Physical Exercise', 'definition': 'Definition not available.'},
      {'term': 'Pneumonia', 'definition': 'Definition not available.'},
      {
        'term': 'Pornography Addiction',
        'definition': 'Definition not available.',
      },
      {
        'term': 'Premature Ejaculation',
        'definition': 'Definition not available.',
      },
      {'term': 'Prostate Cancer', 'definition': 'Definition not available.'},
    ],
    'Q': [],
    'R': [
      {'term': 'Rabies', 'definition': 'Definition not available.'},
      {'term': 'Rheumatism', 'definition': 'Definition not available.'},
    ],
    'S': [
      {'term': 'Safe Sex', 'definition': 'Definition not available.'},
      {'term': 'Seizure', 'definition': 'Definition not available.'},
      {'term': 'Sex and Pleasure', 'definition': 'Definition not available.'},
      {
        'term': 'Sex Problems in Women',
        'definition': 'Definition not available.',
      },
      {
        'term': 'Sickle Cell Anaemia',
        'definition': 'Definition not available.',
      },
      {'term': 'Skin Disorders', 'definition': 'Definition not available.'},
      {'term': 'Sleep', 'definition': 'Definition not available.'},
      {'term': 'Sleeping Sickness', 'definition': 'Definition not available.'},
      {'term': 'Smoking', 'definition': 'Definition not available.'},
      {'term': 'Snoring', 'definition': 'Definition not available.'},
      {'term': 'Spinal Cord Injury', 'definition': 'Definition not available.'},
      {'term': 'Stomach Ulcer', 'definition': 'Definition not available.'},
      {'term': 'Stress Management', 'definition': 'Definition not available.'},
      {'term': 'Stroke', 'definition': 'Definition not available.'},
      {'term': 'Swollen Testicles', 'definition': 'Definition not available.'},
      {'term': 'Syphilis', 'definition': 'Definition not available.'},
    ],
    'T': [
      {'term': 'Teething', 'definition': 'Definition not available.'},
      {'term': 'Tongue Problems', 'definition': 'Definition not available.'},
      {'term': 'Tonsillitis', 'definition': 'Definition not available.'},
      {'term': 'Trachoma', 'definition': 'Definition not available.'},
      {'term': 'Tuberculosis', 'definition': 'Definition not available.'},
      {'term': 'Typhoid Fever', 'definition': 'Definition not available.'},
    ],
    'U': [
      {'term': 'Ulcers', 'definition': 'Definition not available.'},
      {
        'term': 'Urinary Incontinence in Men',
        'definition': 'Definition not available.',
      },
      {
        'term': 'Urinary Incontinence in Women',
        'definition': 'Definition not available.',
      },
      {
        'term': 'Urinary Tract Infection',
        'definition': 'Definition not available.',
      },
    ],
    'V': [
      {'term': 'Vaginal Infection', 'definition': 'Definition not available.'},
    ],
    'W': [
      {'term': 'Weight Loss', 'definition': 'Definition not available.'},
      {'term': 'Weight Management', 'definition': 'Definition not available.'},
      {'term': "Women's Health", 'definition': 'Definition not available.'},
    ],
    'X': [],
    'Y': [],
    'Z': [],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: AppBar(
          title: Text('Library', style: AppTypography.heading3),
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      body: SingleChildScrollView(
        // physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Hero(
                tag: 'search-bar',
                child: Material(
                  type: MaterialType.transparency,
                  child: AppSearchBar(),
                ),
              ),
              const SizedBox(height: 24),
              _buildCategoriesSection(),
              const SizedBox(height: 24),
              _buildGlossarySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Categories',
          onSeeMoreTap: () {
            // TODO: Navigate to see all categories
          },
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 3.0,
          runSpacing: 4.0,
          children: _categories.map((category) {
            return CategoryCard(
              title: category['title']!,
              imagePath: category['imagePath']!,
              onTap: () {
                // TODO: Handle category tap
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGlossarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Glossary'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0, // Horizontal gap between items
          runSpacing: 12.0, // Vertical gap between lines
          children: List.generate(26, (index) {
            final letter = String.fromCharCode('A'.codeUnitAt(0) + index);
            return GestureDetector(
              onTap: () {
                // TODO: Handle letter tap
              },
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: AppColors.cardGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        ..._glossaryTerms.entries.where((entry) => entry.value.isNotEmpty).map((
          entry,
        ) {
          final letter = entry.key;
          final terms = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      letter,
                      style: AppTypography.heading2.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Divider(
                        color: AppColors.textPrimary,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 16,
                    childAspectRatio:
                        2.5, // Adjust this ratio based on expected content
                  ),
                  itemCount: terms.length,
                  itemBuilder: (context, index) {
                    final glossaryEntry = terms[index];
                    return Text(
                      glossaryEntry['term']!,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.cardDeepGreen,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
