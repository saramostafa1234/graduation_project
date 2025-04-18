import 'dart:io'; // لاستخدام File
import 'package:flutter/material.dart';
// --- لا نحتاج Bloc/Cubit هنا لأننا نستخدم setState مباشرة ---
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart'; // لاختيار الصور
// --- لا نحتاج intl هنا لأن البيانات القادمة من API محدودة ---
// import 'package:intl/intl.dart';

// --- استيراد AuthService ---
// تأكدي 100% أن هذا المسار صحيح في مشروعك
import 'package:myfinalpro/auth_services.dart'; // أو المسار الصحيح لملف AuthService.dart

// --- استيراد الويدجت المخصص ---
// تأكدي 100% أن هذا المسار صحيح
import 'custom_profile_text_field.dart'; // أو المسار الصحيح

// --- استيراد شاشة تغيير كلمة المرور (إذا لزم الأمر) ---
import 'changePassword.dart';

//------------------------------------------------------
// شاشة تعديل الملف الشخصي (StatefulWidget)
// تستخدم AuthService مباشرة لإدارة البيانات والحالة
//------------------------------------------------------
class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  // --- Controllers ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _doctorIdController = TextEditingController();
  final TextEditingController _childDobController =
      TextEditingController(text: '...');
  final TextEditingController _usernameController =
      TextEditingController(text: '...');
  final TextEditingController _phoneEmailController =
      TextEditingController(text: '...');
  final TextEditingController _passwordController =
      TextEditingController(text: "************");

  // --- متغيرات الحالة المحلية ---
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String _profileImageUrl = 'assets/images/placeholder.png'; // تأكدي من وجوده
  File? _selectedImageFile;
  String? _newlyUploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfileData();
  }

  @override
  void dispose() {
    /* ... dispose controllers ... */ super.dispose();
  }

  // --- دالة جلب بيانات المستخدم ---
  Future<void> _loadUserProfileData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedImageFile = null;
      _newlyUploadedImageUrl = null;
    });
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');
      final result = await AuthService.getUserProfile(token);
      if (!mounted) return;
      if (result['success'] == true && result['data'] is Map<String, dynamic>) {
        final profileData = result['data'] as Map<String, dynamic>;
        setState(() {
          // --- تعبئة Controllers (استخدمي المفاتيح الصحيحة من get-profile API) ---
          _nameController.text =
              profileData['name_'] ?? profileData['name'] ?? '';
          _surnameController.text = profileData['surname'] ?? '';
          _doctorIdController.text = profileData['doctor_ID']?.toString() ?? '';
          _profileImageUrl =
              profileData['image_'] ?? 'assets/images/placeholder.png';
          _usernameController.text = profileData['email'] ?? 'غير متوفر';
          _phoneEmailController.text = profileData['phone'] ?? 'غير متوفر';
          _childDobController.text = profileData['birthDate'] ?? 'غير متوفر';
          // -------------------------------------------------------------
          _isLoading = false;
        });
      } else {
        throw Exception(result['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _errorMessage =
              "فشل تحميل البيانات: ${e.toString().characters.take(100)}...";
          _isLoading = false;
        });
    }
  }

  // --- دالة اختيار و رفع الصورة ---
  Future<void> _pickAndUploadImage() async {
    if (_isSaving) return;
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image == null) {
        print("[EditAccountScreen] Image picking cancelled.");
        return;
      }
      final fileToUpload = File(image.path);
      if (!mounted) return;
      setState(() {
        _selectedImageFile = fileToUpload;
        _isSaving = true;
        _errorMessage = null;
      });

      // --- استدعاء دالة الرفع إلى ImgBB من AuthService ---
      final newUrl = await AuthService.uploadImageToImgBB(fileToUpload);
      // -----------------------------------------------
      if (!mounted) return;
      if (newUrl != null) {
        setState(() {
          _newlyUploadedImageUrl = newUrl;
          _profileImageUrl = newUrl;
          _selectedImageFile = null;
          _isSaving = false;
        });
        _showSnackBar("تم رفع الصورة بنجاح، اضغط حفظ للتأكيد.", isError: false);
      } else {
        throw Exception('Failed to get image URL from ImgBB.');
      }
    } catch (e) {
      print("[EditAccountScreen] Error picking/uploading image: $e");
      if (mounted) {
        setState(() {
          _errorMessage =
              "فشل رفع الصورة: ${e.toString().replaceFirst('Exception: ', '')}";
          _isSaving = false;
          _selectedImageFile = null;
        });
      }
    }
  }

  // --- دالة حفظ التغييرات ---
  Future<void> _saveProfileChanges() async {
    if (_isSaving || _isLoading) return;
    if (!mounted) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');
      final String name = _nameController.text.trim();
      final String surname = _surnameController.text.trim();
      final int? doctorId = int.tryParse(_doctorIdController.text.trim());
      if (name.isEmpty || surname.isEmpty)
        throw Exception("الاسم واللقب مطلوبان");

      // --- استدعاء AuthService.updateUserProfile بالمعاملات المسماة ---
      final result = await AuthService.updateUserProfile(
        token,
        name: name, // <-- اسم متغير Dart
        surname: surname,
        doctorId: doctorId,
        imageUrl: _newlyUploadedImageUrl, // <-- رابط الصورة الجديد
      );
      // ---------------------------------------------------------
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          _isSaving = false;
          _newlyUploadedImageUrl = null;
        }); // مسح الرابط المؤقت
        _showSnackBar("تم حفظ التغييرات بنجاح", isError: false);
        await _loadUserProfileData();
      } else {
        throw Exception(result['message'] ?? 'Failed to save profile');
      }
    } catch (e) {
      print("[EditAccountScreen] Error saving profile: $e");
      if (mounted)
        setState(() {
          _errorMessage =
              "فشل حفظ التغييرات: ${e.toString().replaceFirst('Exception: ', '')}";
          _isSaving = false;
        });
    }
  }

  // --- دالة مساعدة لعرض SnackBar ---
  void _showSnackBar(String message, {bool isError = true}) {/* ... */}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          // <-- بداية PreferredSize
          // --- 1. إضافة preferredSize ---
          preferredSize:
              const Size.fromHeight(70.0), // تحديد الارتفاع المطلوب (70)
          // -----------------------------
          // --- 2. إضافة child ---
          child: Padding(
            // <-- الـ Widget الفعلي هو Padding
            padding: const EdgeInsets.only(top: 25, right: 10, left: 10),
            child: AppBar(
              leading: IconButton(
                // <-- هذا IconButton
                icon: const Icon(Icons.arrow_forward_ios,
                    size: 24, color: Color(0xFF2C73D9)), // <-- معامل icon
                onPressed: _isLoading || _isSaving
                    ? null
                    : () => Navigator.maybePop(context), // <-- معامل onPressed
              ),
              leadingWidth: 40,
              title: const Text(
                "تعديل الملف الشخصي", /* ... */
                style: TextStyle(
                    color: Color(0xFF2C73D9), // <--- تطبيق اللون الأزرق
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
             
              elevation: 0,
            ),
          ),
          // -----------------
        ),
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.01),
                      _buildProfilePictureWidget(context), // بناء الصورة
                      SizedBox(height: screenHeight * 0.04),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text(_errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),

                      // حقول الإدخال (تأكدي من ربط الـ Controllers الصحيحة)
                      CustomProfileTextField(
                        label: "اسم الطفل",
                        hint: "أدخل اسم طفلك",
                        controller: _nameController,
                        readOnly: _isSaving,
                      ),
                      CustomProfileTextField(
                        label: "اللقب",
                        hint: "أدخل اللقب",
                        controller: _surnameController,
                        readOnly: _isSaving,
                      ),
                      CustomProfileTextField(
                        label: "رقم تعريف الأخصائي (اختياري)",
                        hint: "ادخل رقم تعريف الأخصائي",
                        controller: _doctorIdController,
                        keyboardType: TextInputType.number,
                        readOnly: _isSaving,
                      ),
                      CustomProfileTextField(
                        label: "تاريخ ميلاد الطفل",
                        hint: "",
                        controller: _childDobController,
                        readOnly: true,
                        suffixIcon: const Icon(Icons.calendar_today,
                            color: Colors.grey),
                      ),
                      CustomProfileTextField(
                        label: "اسم المستخدم (الإيميل)",
                        hint: "",
                        controller: _usernameController,
                        readOnly: true,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        suffixIcon: const Icon(Icons.person_outline,
                            color: Colors.grey),
                      ),
                      CustomProfileTextField(
                        label: "رقم الهاتف",
                        hint: "",
                        controller: _phoneEmailController,
                        readOnly: true,
                        suffixIcon: const Icon(Icons.phone_outlined,
                            color: Colors.grey),
                      ),
                      CustomProfileTextField(
                        label: "كلمة السر",
                        hint: "************",
                        controller: _passwordController,
                        obscureText: true,
                        readOnly: true,
                        suffixIcon:
                            const Icon(Icons.lock_outline, color: Colors.grey),
                      ),
                      Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 5.0, bottom: 8.0),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: InkWell(
                          onTap: _isLoading || _isSaving ? null : () {
                            // --- الانتقال لشاشة تغيير كلمة المرور ---
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ChangePassword()), // <-- الانتقال هنا
                            );
                            // -----------------------------------
                          },
                          child: const Text( "تغيير كلمة المرور؟", style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold,), ),
                        ),
                      ),
                    ),
                    // -------------------------------

                    

                      SizedBox(height: screenHeight * 0.04),
                      _buildSaveButtonWidget(context), // بناء زر الحفظ
                      SizedBox(height: screenHeight * 0.04),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // --- دالة بناء واجهة الصورة الشخصية ---
  Widget _buildProfilePictureWidget(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    ImageProvider displayImage;
    if (_selectedImageFile != null && !_isSaving) {
      displayImage = FileImage(_selectedImageFile!);
    } else if (_profileImageUrl.startsWith('http')) {
      displayImage = NetworkImage(_profileImageUrl);
    } else {
      displayImage = const AssetImage('assets/images/placeholder.png');
    }
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          CircleAvatar(
            radius: screenWidth * 0.18,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: displayImage,
            onBackgroundImageError: (e, s) {
              print("Err:$e");
            },
            child: _isSaving
                ? Container(
                    decoration: const BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                        child: CircularProgressIndicator(color: Colors.white)),
                  )
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: const Color(0xFF2C73D9),
              shape: const CircleBorder(
                  side: BorderSide(color: Colors.white, width: 2)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                splashColor: Colors.white.withOpacity(0.3),
                onTap: _isSaving ? null : _pickAndUploadImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.camera_alt,
                    size: screenWidth * 0.055,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- دالة بناء زر الحفظ ---
  Widget _buildSaveButtonWidget(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double buttonWidthFactor = 0.85;
    const double buttonHeight = 60;
    return Center(
      child: SizedBox(
        width: screenWidth * buttonWidthFactor,
        child: ElevatedButton(
          onPressed: _isLoading || _isSaving ? null : _saveProfileChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C73D9),
            minimumSize: Size(screenWidth * buttonWidthFactor, buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 2,
            disabledBackgroundColor: Colors.grey.shade400,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3),
                )
              : const Text(
                  "حفظ التغييرات",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
