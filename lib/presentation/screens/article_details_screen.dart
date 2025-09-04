import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';
import 'package:u_clinic/presentation/widgets/appbar/custom_app_bar.dart';
import 'package:u_clinic/presentation/widgets/section_header.dart';

class ArticleDetailsScreen extends StatelessWidget {
  const ArticleDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CAppBar(
        title: 'Article',
        onBack: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bookmark_border_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildArticleHeader(),
            const SizedBox(height: AppDimensions.spacingM),
            _buildArticleBody(),
            const SizedBox(height: AppDimensions.spacingL),
            _buildRelatedPosts(),
            const SizedBox(height: AppDimensions.spacingL),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          child: Image.asset(
            'assets/images/inspiration1.png', // Placeholder image
            height: 198,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: AppDimensions.spacingM),
          child: Text('Acne', style: AppTypography.heading3),
        ),
      ],
    );
  }

  Widget _buildArticleBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("""What is acne? """, style: AppTypography.bodyLarge),
        SizedBox(height: AppDimensions.spacingS),
        Text(
          """Your skin has tiny holes called pores (hair follicles) that can become blocked by oil, bacteria, dead skin cells, and dirt. \n\nWhen this occurs, you may develop a pimple or “zit.” If your skin is repeatedly affected by this condition, you may have acne. Acne (pimples or spots) is a common chronic skin disorder involving the hair follicle and sebaceous gland which presents mainly in adolescents. Acne typically appears on face, forehead, chest, upper back and shoulders because these areas have abundant hair follicles.\nSevere acne may require evaluation to exclude an underlying hormonal disorder. This condition may induce some psychological disturbances especially in adolescents when it affects your self-esteem and, over time, may cause permanent physical scarring.\nWhat are some misconceptions about acne? Myths about what contributes to acne are quite common. Many people believe that only teenagers get acne and foods such as “kelewele”, chocolate and oily foods will contribute to acne. Some people also think that popping acne or getting a tan will clear up acne. \n\nWhile there’s no scientific support for these claims, there are certain risk factors for developing acne and there are many effective treatments for acne that reduce both the number of pimples you get and your chances of developing scars from them.\nWhat causes acne? Acne occurs when the pores of your skin become blocked with oil, dead skin, or bacteria. Each pore of your skin is the opening to a follicle. The follicle is made up of a hair and a sebaceous (oil) gland. The oil gland releases sebum (oil), which travels up the hair, out of the pore, and onto your skin. The sebum keeps your skin lubricated and soft.\n\nOne or more problems in this lubrication process can cause acne. It can occur when: Too much oil is produced by your follicles Dead skin cells accumulate in your pores Bacteria build up in your pores\n These lubrication challenges are likely to occur as result of the following: High hormonal production during adolescence, pregnancy. Hormonal acne related to puberty or pregnancy usually subsides, or at least improves when you reach adulthood or after you deliver your baby Hormonal diseases when some organs in your body produce too much hormones Abnormal keratin production in your hair follicles which is inherited from your father or mother Increased sensitivity of your sebaceous glands to male hormones Use of contraceptives that contain hormones Prolonged use of steroids such as anabolic steroids for body building Use of pomades, especially products that contain lanolin, petrolatum, vegetable oils, butyl stearate, lauryl alcohol and oleic acid.\nWhat is the social impact of acne? Acne may make a person feel unattractive and lower your self-esteem because it can be cosmetically disfiguring. Such a person may feel too shy to make friends with the opposite sex. So, look for counselling support if you feel you need one.\nHow can you manage acne? If you have symptoms of acne, your doctor can make a diagnosis by examining your skin. Your doctor will identify the types of lesions and their severity to determine the best treatment. You may be advised to use home care remedies or your doctor may give you medication to use.\nHome Care Home remedies for acne include: Cleaning your skin daily with a mild soap to remove excess oil and dirt Not using your bathing sponge on your face Dry your towels out in the sun Change your pillowcases and bedsheets regularly Not squeezing or picking pimples, which spreads bacteria and excess oil Not wearing hats or tight headbands Not touching your face\nMedication A few medications can be used if self-care does not improve symptoms A Benzoyl peroxide is present in many acne creams and gels. It is used for drying out existing pimples and preventing new ones. Sulfur is a natural ingredient found in some lotions, cleansers, and masks. Resorcinol is a less common ingredient used to remove dead skin cells. Salicylic acid is often used in soaps and acne washes. It helps prevent pores from getting plugged.\nSometimes, you may continue to experience symptoms. Your doctor can prescribe medications that may help reduce your symptoms and prevent scars. These include: Oral or topical antibiotics reduce inflammation and kill the bacteria that cause pimples. Typically, antibiotics are not for long term use Prescription topical creams such as retinoic acid or prescription-strength benzoyl peroxide is also used. They work to reduce oil production.""",
          style: AppTypography.bodyMedium,
        ),
        SizedBox(height: AppDimensions.spacingL),
      ],
    );
  }

  Widget _buildRelatedPosts() {
    return Column(
      children: [
        const SectionHeader(title: 'Related Posts'),
        const SizedBox(height: AppDimensions.spacingM),
        SizedBox(
          height: 200, // Placeholder height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3, // Placeholder count
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: AppDimensions.spacingM),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: AssetImage(
                      'assets/images/inspiration2.png',
                    ), // Placeholder image
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
