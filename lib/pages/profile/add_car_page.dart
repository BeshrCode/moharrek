
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moharrek/components/text_form_field.dart';
import 'package:moharrek/components/dropdown_menu_button.dart';
import 'package:moharrek/components/year_picker.dart';
import 'package:moharrek/pages/home/controller/carController.dart';
import 'package:moharrek/shared_pref.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:uuid/uuid.dart';
import '../home/model/car.dart';

class AddCarPage extends GetWidget<CarController> {

  String model = "";
  int year = 2024;
  TextEditingController mileage = TextEditingController();

  final transmissionTypes = ['Automatic', 'Manual'];

  String transmissionType = 'أوتوماتيك';

  String? selectedModel;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController bisPriceController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey();

  final Type type = Get.arguments;

  AddCarPage({super.key});

  String getCarType(){
    if(type == Type.USED){
      return 'مستخدمة';
    }
    if(type == Type.AUCTION){
      return 'مزايدة';
    }
    if(type == Type.NEW){
      return 'وكالة';
    }

    return '';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          "أضف مركبة (${getCarType()})",
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          children: [
            CustomDropdownMenuButton(
                hint: "اختر الشركة",
                hintSearch: "ابحث عن الشركة...",
                list: controller.manufacturers,
                selectedValue: controller.selectedManufacturer!.value,
                onChanged: (value) {
                  controller.selectedManufacturer!.value = value;
                  selectedModel = null;
                  // setState(() {});
                }),
            const SizedBox(height: 20),
            Obx(() {
              return CustomDropdownMenuButton(
                  hint: "اختر المودل",
                  hintSearch: "ابحث عن المودل...",
                  list: controller.models[controller.selectedManufacturer!.value] ?? ["تويوتا"],
                  selectedValue: selectedModel,
                  onChanged: (value) {
                    selectedModel = value;
                    // setState(() {});
                  });
            }),
            const SizedBox(height: 20),
            // Text("اختر سنة التصنيع"),
            CustomYearPicker(selectedYear: (value) {
              year = value;
            }),
            const SizedBox(height: 30),

            CustomNumberTextFormField(
                hint: "أدخل مقدار الممشى...",
                prefixIcon:
                Container(
                    padding: const EdgeInsets.all(13), child: const Text("km")),
                myController: mileage),
            const SizedBox(height: 20),
            const Text("حدد نظام القير"),
            const SizedBox(height: 5),
            ToggleSwitch(
              initialLabelIndex: 0,
              animate: true,
              animationDuration: 400,
              curve: Easing.legacy,
              minWidth: double.infinity,
              customWidths: const [double.infinity, double.infinity],
              dividerColor: Colors.white,
              inactiveBgColor: Colors.white,
              borderColor: const [Colors.blue],
              borderWidth: 1,
              cornerRadius: 0,
              totalSwitches: 2,
              activeBgColor: const [Colors.blue],
              labels: ['أوتوماتيك', 'عادي'],
              onToggle: (index) {
                transmissionType = transmissionTypes[index!];
              },
            ),
            const SizedBox(height: 25),

            InkWell(
              onTap: () {
                controller.addImage();
              },
              child: DottedBorder(
                color: Colors.blue,
                strokeWidth: 1,
                child: Obx(() {
                  return Container(
                      decoration: BoxDecoration(
                        color: controller.imageList.value.isEmpty
                            ? Colors.grey[200]
                            : Colors.blue[200],
                      ),
                      height: 100,
                      width: double.infinity,
                      child: controller.imageList.value.isEmpty
                          ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 25,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "ارفع صورة أو أكثر للمركبة",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      )
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.imageList.value.length,
                        itemBuilder: (context, index) {
                          return Image.file(
                            controller.imageList.value[index],
                            height: 100,
                            width: 100,
                          );
                        },
                      ));
                }),
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: InkWell(
                onTap: () {
                  controller.addPDFFile();
                },
                child: DottedBorder(
                  color: Colors.blue,
                  strokeWidth: 1,
                  child: Obx(() {
                    return Container(
                        decoration: BoxDecoration(
                          color: controller.periodicInspection.value.path
                              .isEmpty
                              ? Colors.grey[200]
                              : Colors.blue[200],
                        ),
                        height: 80,
                        width: double.infinity,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.file_copy_outlined,
                              size: 25,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "ارفع ملف الفحص الدوري للمركبة",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ));
                  }),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Visibility(
              visible: type == Type.AUCTION?true:false,
              child: Column(
                children: [
                  CustomTextField(
                    isEnable: type==Type.AUCTION?true:false,
                    isValidate: true,
                    inputType: TextInputType.number,
                    maxLines: 1,
                      maxLength: 10,
                      hint: "${type == Type.AUCTION?'الزيادة في السوم':'السعر'} (أجباري)",
                      controller: bisPriceController),

                ],
              ),
            ),
            const SizedBox(height: 5),
            Column(
              children: [
                CustomTextField(
                  isEnable:  true,
                  isValidate: true,
                  inputType: TextInputType.number,
                  maxLines: 1,
                    maxLength: 10,
                    hint: "${type == Type.AUCTION?'بداية السوم':'السعر'} (أجباري)", controller: priceController),

              ],
            ),
            CustomTextField(
              isEnable: true,
              isValidate: false,
              inputType: TextInputType.text,
              maxLength: 100,
                maxLines: 3,
                hint: "الوصف (إختياري)", controller: descriptionController),
            const SizedBox(height: 20),


            CustomDropdownMenuButton(
                hint: 'المدينة',
                list: controller.cites,
                onChanged: (city){
                  controller.selectedCity(city);
                },
                hintSearch: 'ابحث عن مدينتك'),


            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                if (controller.imageList.value.isEmpty) {
                  AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title: 'خطأ',
                      desc: 'يجب رفع صورة واحدة على الأقل',
                      titleTextStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      descTextStyle: const TextStyle(fontSize: 14),
                      btnOkColor: Colors.blue,
                      btnOkText: "إغلاق",
                      btnOkOnPress: () {})
                      .show();
                  return;
                }
                if (controller.periodicInspection == null) {
                  AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title: 'خطأ',
                      desc: 'يجب رفع ملف الفحص الدوري',
                      titleTextStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      descTextStyle: const TextStyle(fontSize: 14),
                      btnOkColor: Colors.blue,
                      btnOkText: "إغلاق",
                      btnOkOnPress: () {})
                      .show();
                  return;
                }
                AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.rightSlide,
                    title: 'تنبيه',
                    desc: 'رجاء تأكد من عدم وجود أي معلومات خاطئة.',
                    titleTextStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    descTextStyle: const TextStyle(fontSize: 14),
                    btnOkColor: Colors.blue,
                    btnOkText: "استمرار",
                    btnCancelText: "إلغاء",
                    btnOkOnPress: () async {
                      Car car = Car(
                        bidPrice: double.parse(bisPriceController.text),
                        carId: const Uuid().v4(),
                        model: selectedModel ?? '',
                        make: controller.selectedManufacturer!.value,
                        year: year,
                        paid: false,
                        available: false,
                        seller: Preference.shared.getUserName()!,
                        sellerId: Preference.shared.getUserId()!,
                        sellerPhone: Preference.shared.getUserPhone()!,
                        type: type,
                        price: double.parse(priceController.text.trim()),
                        location: controller.selectedCity.value,
                        mileage:int.parse(mileage.text),
                        uploadDate: DateTime.now().toString(),
                        expireDate: DateTime.now().add(const Duration(days: 14)).toString(),
                        addDate: DateTime.now().toString(),
                        transmissionType: transmissionType,
                        // Example
                        description: descriptionController.text.trim(),
                        company: controller.selectedManufacturer!.value,
                        images: [],
                        // Example
                        auctions: [], // Example
                      );
                      await controller.addCar(car);
                      Get.snackbar(
                          "تمت إضافة السيارة!",
                          "تمت إضافة سيارتك بنجاح.",
                          snackPosition: SnackPosition.TOP);

                    },
                    btnCancelOnPress: () {})
                    .show();
              },
              child: Obx(() {
                return controller.isLoading.isTrue?const Center(child: CircularProgressIndicator()):Text(
                  controller.isLoading.isTrue
                      ? '${controller.currentOp}'
                      : 'نشر',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
