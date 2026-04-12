مرحبًا،

تم تجهيز جهة Flutter مبدئيًا لاستقبال الربط مع الـ backend، وتم تجهيز ملف contract كامل هنا:

`D:\rom_tracker_app\docs\backend_api_contract_en.md`

حاليًا نريد أن نبدأ فقط بالمسار الأساسي المهم MVP.

## أول دفعة APIs مطلوبة الآن - P0

1. `POST /auth/login`
2. `GET /users/me`
3. `GET /doctors`
4. `GET /doctors/{id}`
5. `GET /doctors/{id}/slots`
6. `POST /bookings`
7. `GET /sessions/patient`
8. `GET /sessions/doctor`
9. `PATCH /sessions/{id}/status`
10. `POST /sessions/{id}/ai-result`
11. اختياري: `POST /sessions/{id}/start`

## المطلوب من جهتك

1. Base URL
2. Swagger أو Postman collection
3. طريقة الـ authentication
4. أمثلة request/response
5. القيم النهائية للحالات مثل status
6. أسماء الحقول النهائية للـ P0 endpoints

## ملاحظة مهمة عن الكاميرا والـ AI

جزء الكاميرا والـ computer vision متوقع أنه يعمل داخل Unity ويتم استضافته داخل Flutter.
يعني الـ backend لا يحتاج إلى استقبال فيديو مباشر أو تشغيل الـ AI بنفسه.

المطلوب من الـ backend في جزء الـ AI هو:

- وجود `sessionId` صالح قبل فتح الـ AI flow
- endpoint لحفظ نتيجة الجلسة بعد انتهاء Unity
- واختياريًا endpoint لتسجيل أن الجلسة بدأت

Unity متوقع أن ترجع JSON بالشكل التالي:

```json
{
  "exercise": "Squat",
  "reps": 12
}
```

Flutter سيضيف:

- `patientId`
- `sessionId`
- `timestamp`

ثم يرسل الـ payload النهائي إلى الـ backend.

جهة Flutter جاهزة تنظيميًا للربط، وبمجرد إرسال أول دفعة P0 سنبدأ توصيل الـ APIs مباشرة.
