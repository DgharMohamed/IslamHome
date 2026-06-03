function setCurrentYear() {
  const yearNode = document.getElementById("currentYear");
  if (yearNode) {
    yearNode.textContent = String(new Date().getFullYear());
  }
}

function initMobileMenu() {
  const menuToggle = document.getElementById("menuToggle");
  const mainNav = document.getElementById("mainNav");

  if (menuToggle && mainNav) {
    menuToggle.addEventListener("click", () => {
      mainNav.classList.toggle("show");
      const icon = menuToggle.querySelector("i");
      if (mainNav.classList.contains("show")) {
        icon.classList.replace("fa-bars", "fa-times");
      } else {
        icon.classList.replace("fa-times", "fa-bars");
      }
    });
  }
}

const translations = {
  ar: {
    page_title: "سياسة الخصوصية | بيت الإسلام",
    brand_name: "بيت الإسلام",
    nav_features: "المميزات",
    nav_download: "التحميل",
    nav_about: "عن التطبيق",
    nav_privacy: "سياسة الخصوصية",
    privacy_badge: "الشفافية أولاً",
    privacy_title: "سياسة الخصوصية",
    privacy_intro: "نلتزم بحماية خصوصيتك. توضح هذه الصفحة البيانات التي نتعامل معها، وكيفية استخدامها، وحقوقك كمستخدم.",
    back_home: "العودة للصفحة الرئيسية",
    s1_title: "1. البيانات التي نجمعها",
    s1_text: "لا نقوم بجمع بيانات شخصية حساسة دون إذنك. قد نستخدم بيانات تقنية أساسية لتحسين الأداء وتجربة الاستخدام.",
    s2_title: "2. كيفية استخدام البيانات",
    s2_text: "تستخدم البيانات فقط لتشغيل الميزات، تحسين الاستقرار، وتقديم تجربة أفضل داخل التطبيق.",
    s3_title: "3. مشاركة البيانات",
    s3_text: "لا نبيع بيانات المستخدمين. قد تتم مشاركة بيانات غير شخصية مع مزودي خدمات التحليلات أو البنية التحتية عند الحاجة.",
    s4_title: "4. أمان البيانات",
    s4_text: "نعتمد ممارسات أمنية مناسبة لحماية البيانات من الوصول غير المصرح به أو الاستخدام الخاطئ.",
    s5_title: "5. حقوقك",
    s5_text: "يمكنك طلب تحديث أو حذف البيانات المرتبطة بك وفقاً للقوانين المعمول بها في بلدك.",
    s6_title: "6. تحديثات السياسة",
    s6_text: "قد يتم تحديث سياسة الخصوصية من وقت لآخر. سيتم نشر أي تعديل على هذه الصفحة.",
    last_update: "آخر تحديث: 29 أبريل 2026",
    footer_desc: "مشروع يهدف إلى توفير أدوات إسلامية متكاملة لخدمة المسلمين حول العالم.",
    footer_links: "روابط هامة",
    footer_social: "تواصل معنا",
    footer_privacy: "سياسة الخصوصية",
    footer_copyright: "بيت الإسلام. تمت برمجته وتصميمه لخدمة الإسلام."
  },
  en: {
    page_title: "Privacy Policy | IslamHome",
    brand_name: "IslamHome",
    nav_features: "Features",
    nav_download: "Download",
    nav_about: "About",
    nav_privacy: "Privacy Policy",
    privacy_badge: "Transparency First",
    privacy_title: "Privacy Policy",
    privacy_intro: "We are committed to protecting your privacy. This page explains what data we handle, how we use it, and your rights as a user.",
    back_home: "Back to Home",
    s1_title: "1. Data We Collect",
    s1_text: "We do not collect sensitive personal data without your consent. Basic technical data may be used to improve performance and user experience.",
    s2_title: "2. How We Use Data",
    s2_text: "Data is used only to run features, improve reliability, and provide a better in-app experience.",
    s3_title: "3. Data Sharing",
    s3_text: "We do not sell user data. Non-personal data may be shared with analytics or infrastructure providers when needed.",
    s4_title: "4. Data Security",
    s4_text: "We apply appropriate security practices to protect data against unauthorized access or misuse.",
    s5_title: "5. Your Rights",
    s5_text: "You may request updates or deletion of data associated with you, according to applicable laws.",
    s6_title: "6. Policy Updates",
    s6_text: "This privacy policy may be updated from time to time. Any updates will be posted on this page.",
    last_update: "Last update: April 29, 2026",
    footer_desc: "A project aiming to provide integrated Islamic tools to serve Muslims worldwide.",
    footer_links: "Important Links",
    footer_social: "Contact Us",
    footer_privacy: "Privacy Policy",
    footer_copyright: "IslamHome. Programmed and designed to serve Islam."
  }
};

let currentLang = localStorage.getItem("appLang") || "ar";

function applyLanguage(lang) {
  currentLang = lang;
  localStorage.setItem("appLang", lang);

  document.documentElement.lang = lang;
  document.documentElement.dir = lang === "ar" ? "rtl" : "ltr";

  const langLabel = document.getElementById("langLabel");
  if (langLabel) {
    langLabel.textContent = lang === "ar" ? "EN" : "AR";
  }

  document.querySelectorAll("[data-i18n]").forEach((element) => {
    const key = element.getAttribute("data-i18n");
    if (translations[lang][key]) {
      if (element.tagName === "TITLE") {
        document.title = translations[lang][key];
      } else {
        element.innerHTML = translations[lang][key];
      }
    }
  });
}

function initLanguageSwitch() {
  const langToggleBtn = document.getElementById("langToggle");
  if (langToggleBtn) {
    langToggleBtn.addEventListener("click", () => {
      const newLang = currentLang === "ar" ? "en" : "ar";
      applyLanguage(newLang);
    });
  }
  applyLanguage(currentLang);
}

document.addEventListener("DOMContentLoaded", () => {
  initLanguageSwitch();
  setCurrentYear();
  initMobileMenu();
});
