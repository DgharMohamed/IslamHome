const appConfig = {
  links: {
    apkpure: "https://apkpure.com/p/com.islamHome.app",
    universal: "https://github.com/DgharMohamed/IslamHome/releases/latest/download/IslamHome.apk",
    arm64: "https://github.com/DgharMohamed/IslamHome/releases/latest/download/IslamHome-arm64-v8a.apk",
    arm32: "https://github.com/DgharMohamed/IslamHome/releases/latest/download/IslamHome-armeabi-v7a.apk",
    x86_64: "https://github.com/DgharMohamed/IslamHome/releases/latest/download/IslamHome-x86_64.apk",
    ios: "", // ضع رابط App Store هنا عند توفره
  },
};

function configureStoreLinks() {
  const buttons = document.querySelectorAll("[data-store]");
  buttons.forEach((button) => {
    const store = button.getAttribute("data-store");
    const url = appConfig.links[store];

    if (url && url.trim().length > 0) {
      button.href = url;
      button.target = "_blank";
      button.rel = "noopener noreferrer";
      return;
    }

    button.classList.add("disabled");
    button.setAttribute("aria-disabled", "true");
    button.title = "الرابط غير متوفر حالياً";
    
    button.addEventListener("click", (e) => {
      e.preventDefault();
    });
  });
}

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

    // Close menu when clicking a link
    mainNav.querySelectorAll('.nav-link').forEach(link => {
      link.addEventListener('click', () => {
        mainNav.classList.remove("show");
        const icon = menuToggle.querySelector("i");
        icon.classList.replace("fa-times", "fa-bars");
      });
    });
  }
}

function initScrollReveal() {
  const revealElements = document.querySelectorAll('.reveal, .reveal-lazy');
  
  const revealCallback = function(entries, observer) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('active');
        // Unobserve to only animate once
        observer.unobserve(entry.target);
      }
    });
  };

  const revealObserver = new IntersectionObserver(revealCallback, {
    threshold: 0.15,
    rootMargin: "0px 0px -50px 0px"
  });

  revealElements.forEach(el => revealObserver.observe(el));
}

function initSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      const targetId = this.getAttribute('href');
      if (targetId === '#') return;
      
      const targetElement = document.querySelector(targetId);
      if (targetElement) {
        e.preventDefault();
        targetElement.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    });
  });
}

const verses = [
  {
    ar_text: "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا", ar_source: "سورة الشرح - آية 5",
    en_text: "For indeed, with hardship [will be] ease.", en_source: "Surah Ash-Sharh - Ayah 5"
  },
  {
    ar_text: "وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَى", ar_source: "سورة الضحى - آية 5",
    en_text: "And your Lord is going to give you, and you will be satisfied.", en_source: "Surah Ad-Duhaa - Ayah 5"
  },
  {
    ar_text: "لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا", ar_source: "سورة التوبة - آية 40",
    en_text: "Do not grieve; indeed Allah is with us.", en_source: "Surah At-Tawbah - Ayah 40"
  },
  {
    ar_text: "وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ", ar_source: "سورة الحديد - آية 4",
    en_text: "And He is with you wherever you are.", en_source: "Surah Al-Hadid - Ayah 4"
  },
  {
    ar_text: "فَاذْكُرُونِي أَذْكُرْكُمْ", ar_source: "سورة البقرة - آية 152",
    en_text: "So remember Me; I will remember you.", en_source: "Surah Al-Baqarah - Ayah 152"
  },
  {
    ar_text: "وَاللَّهُ يَعْلَمُ وَأَنتُمْ لَا تَعْلَمُونَ", ar_source: "سورة البقرة - آية 216",
    en_text: "But Allah knows, and you know not.", en_source: "Surah Al-Baqarah - Ayah 216"
  },
  {
    ar_text: "إِنَّ مَعَ الصَّبْرِ نَصْرًا", ar_source: "حديث شريف",
    en_text: "Indeed, victory comes with patience.", en_source: "Hadith"
  }
];

let typewriterTimeout = null;

function initTypewriter() {
  const verseEl = document.getElementById('typewriterVerse');
  const sourceEl = document.getElementById('verseSource');
  if (!verseEl || !sourceEl) return;

  // Clean any active timeout from previous languages or executions
  if (typewriterTimeout) {
    clearTimeout(typewriterTimeout);
  }

  const randomVerse = verses[Math.floor(Math.random() * verses.length)];
  
  // Use currentLang which is global from the language switcher
  const txt = currentLang === 'en' ? randomVerse.en_text : randomVerse.ar_text;
  const sourceTxt = currentLang === 'en' ? randomVerse.en_source : randomVerse.ar_source;
  
  let i = 0;
  const speed = 80; // typing speed
  
  // Clean before typing
  verseEl.textContent = '';
  sourceEl.textContent = '';
  sourceEl.classList.remove('show');

  function typeWriter() {
    if (i < txt.length) {
      verseEl.textContent += txt.charAt(i);
      i++;
      typewriterTimeout = setTimeout(typeWriter, speed);
    } else {
      sourceEl.textContent = sourceTxt;
      sourceEl.classList.add('show');
    }
  }

  // Start typing automatically after a short delay
  typewriterTimeout = setTimeout(typeWriter, 1200);
}

// Translation Dictionary
const translations = {
  ar: {
    page_title: "بيت الإسلام | تطبيق إسلامي شامل",
    brand_name: "بيت الإسلام",
    nav_features: "المميزات",
    nav_screenshots: "صور التطبيق",
    nav_download: "التحميل",
    nav_about: "عن التطبيق",
    nav_privacy: "سياسة الخصوصية",
    badge_text: "رفيقك اليومي",
    hero_title: "مرحباً بك في <br><span class=\"text-gradient\">بيت الإسلام</span>",
    hero_subtitle: "كل ما يحتاجه المسلم في تطبيق واحد.. القرآن الكريم، الأذكار، مواقيت الصلاة، الخواطر الإيمانية، اتجاه القبلة، والمزيد بتصميم عصري وتجربة فائقة الجمال.",
    btn_apkpure: "تحميل من APKPure",
    btn_universal: "نسخة (APK)",
    btn_arm64: "نسخة (ARM64)",
    btn_arm32: "نسخة (ARM32)",
    btn_x86: "نسخة (x86_64)",
    btn_all_versions: "تصفح جميع النسخ",
    btn_ios: "متوفر قريباً",
    hero_note: "آمن، سريع، ويعمل بدون إنترنت (في أغلب الخصائص)",
    card1_title: "تلاوات خاشعة",
    card1_desc: "نخبة من القراء",
    card2_title: "مواقيت دقيقة",
    card2_desc: "حسب موقعك",
    card3_title: "اتجاه القبلة",
    card3_desc: "مؤشر ذكي للقبلة",
    daily_title: "إشراقة اليوم",
    feat_title: "لماذا <span class=\"text-gradient\">بيت الإسلام؟</span>",
    feat_subtitle: "صُمم ليكون وجهتك الأولى والأخيرة لكل ما تبحث عنه من أدوات، محتوى ديني، ومراجع إسلامية بتصميم يسر العيـن والقلب.",
    feat1_t: "القرآن الكريم",
    feat1_d: "تصفح المصحف، استمع لأكثر من 100 قارئ، واقرأ التفسير بضغطة زر. علامات مرجعية وحفظ تلقائي للصفحات.",
    feat2_t: "الأذكار والأدعية",
    feat2_d: "أذكار الصباح والمساء، أذكار الصلاة، وحصن المسلم، بتصميم يسهل القراءة والتمرير مع عداد لكل ذكر.",
    feat3_t: "مواعيد الصلاة والأذان",
    feat3_d: "تحديد دقيق لأوقات الصلاة أينما كنت. منبه الأذان بأجمل الأصوات مع تنبيهات قبل وبعد دخول الوقت.",
    feat4_t: "بوصلة القبلة",
    feat4_d: "اتجاه القبلة بدقة تامة باستخدام بوصلة بصرية، تعمل في كل مكان وبدون تعقيدات لمعرفة الاتجاه فوراً.",
    feat5_t: "المسبحة الإلكترونية",
    feat5_d: "عش تجربة التسبيح الذكية المدمجة، سبّح الله مع حاسة اللمس وحفظ الأرقام لمواصلة الورد في أي وقت.",
    feat6_t: "إذاعات ومحتوى وصوتي",
    feat6_d: "بث مباشر لإذاعة القرآن، راديو التلاوة لمختلف القراء، ومقاطع وفوائد دعوية مختارة للقلوب.",
    showcase_badge: "استكشف المزايا",
    showcase_title: "مصمم ليرتقي بعبادتك",
    showcase_subtitle: "كل زاوية في التطبيق صنعت بعناية لتوفر لك تجربة إيمانية متكاملة وبلا تعقيد.",
    zg1_title: "تجربة تلاوة استثنائية",
    zg1_desc: "اقرأ وتدبر آيات القرآن الكريم في أي وقت وبدون الحاجة إلى الإنترنت، مع تصميم يريح العين ويسهل التلاوة في الوضع الليلي.",
    zg1_li1: "علامات مرجعية سريعة",
    zg1_li2: "تغيير حجم الخط ونوعه",
    zg1_li3: "دعاء ختم القرآن وإحصائيات",
    zg2_title: "أذكارك اليومية في جيبك",
    zg2_desc: "حصن كل مسلم يبدأ بحفظ أذكاره. يوفر التطبيق أذكار الصباح والمساء، أذكار بعد الصلاة، ومسبحة إلكترونية ذكية تحفظ العدد تلقائياً.",
    zg2_li1: "عداد ذكي للتسبيح",
    zg2_li2: "تنبيهات لقراءة الأذكار",
    zg2_li3: "الاهتزاز عند اكتمال الورد",
    zg3_title: "دقة متناهية في المواقيت",
    zg3_desc: "لا تفوت صلاتك أبداً مع توقيت ذكي يعتمد على موقعك الجغرافي. احصل على تنبيهات قبل الصلاة وعند دخول وقتها بصوت أعذب المؤذنين.",
    zg3_li1: "بوصلة قبلة دقيقة 100%",
    zg3_li2: "تنبيهات صوتية مخصصة",
    zg3_li3: "تخصيص أوقات الإقامة",
    cta_title: "دليلك وجليسك للمسيرة نحو الجنة",
    cta_desc: "انضم إلى الآلاف، حمل تطبيق بيت الإسلام اليوم واستمتع بتجربة إسلامية تنظم وقتك وتثري يومك بالطاعات.",
    footer_desc: "مشروع يهدف إلى توفير أدوات إسلامية متكاملة لخدمة المسلمين حول العالم.",
    footer_links: "روابط هامة",
    footer_social: "تواصل معنا",
    footer_privacy: "سياسة الخصوصية",
    footer_copyright: "بيت الإسلام. تمت برمجته وتصميمه لخدمة الإسلام.",
    footer_love: "صُنع بكل حب 🤍 في العالم العربي",
    dev_title: "عن المطور",
    dev_subtitle: "تعرف على قصة بناء هذا التطبيق",
    dev_name: "ادغار محمد",
    dev_role: "صاحب الفكرة ومطور التطبيق",
    dev_bio: "تم تطوير تطبيق \"بيت الإسلام\" كمشروع تخرج وصدقة جارية لمساعدة المسلمين حول العالم في الحفاظ على أداء عباداتهم وأذكارهم بكل سهولة من خلال واجهة عصرية، سلسة، وخالية تماماً من الإعلانات المزعجة.",
    dev_github: "حساب المطور (GitHub)",
    dev_linkedin: "تواصل معي (LinkedIn)",
    screenshots_title: "لقطات من التطبيق",
    screenshots_subtitle: "نظرة سريعة على تصميم التطبيق وواجهته الأنيقة"
  },
  en: {
    page_title: "IslamHome | Complete Islamic App",
    brand_name: "IslamHome",
    nav_features: "Features",
    nav_screenshots: "Screenshots",
    nav_download: "Download",
    nav_about: "About",
    nav_privacy: "Privacy Policy",
    badge_text: "Your Daily Companion",
    hero_title: "Welcome to <br><span class=\"text-gradient\">IslamHome</span>",
    hero_subtitle: "Everything a Muslim needs in one app... Holy Quran, Azkar, Prayer Times, Islamic Thoughts, Qibla Direction, and more. Modern design and a beautiful experience.",
    btn_apkpure: "Download from APKPure",
    btn_universal: "Version (APK)",
    btn_arm64: "Version (ARM64)",
    btn_arm32: "Version (ARM32)",
    btn_x86: "Version (x86_64)",
    btn_all_versions: "View All Versions",
    btn_ios: "Coming Soon",
    hero_note: "Secure, fast, and works offline (for most features)",
    card1_title: "Reverent Recitations",
    card1_desc: "Elite Reciters",
    card2_title: "Accurate Times",
    card2_desc: "Based on location",
    card3_title: "Qibla Direction",
    card3_desc: "Smart Indicator",
    daily_title: "Today's Inspiration",
    feat_title: "Why <span class=\"text-gradient\">IslamHome?</span>",
    feat_subtitle: "Designed to be your first and last destination for all Islamic tools, content, and references with an eye-pleasing design.",
    feat1_t: "Holy Quran",
    feat1_d: "Browse the Quran, listen to 100+ reciters, and read Tafsir with a click. Bookmarks and auto-save included.",
    feat2_t: "Azkar & Supplications",
    feat2_d: "Morning & Evening Azkar, Prayer Azkar, and Fortress of the Muslim, designed for easy reading with a counter.",
    feat3_t: "Prayer Times & Azan",
    feat3_d: "Accurate prayer times wherever you are. Azan alarm with beautiful voices and pre/post alerts.",
    feat4_t: "Qibla Compass",
    feat4_d: "Accurate Qibla direction using a visual compass, works everywhere instantly without complexity.",
    feat5_t: "Electronic Rosary",
    feat5_d: "Experience the smart integrated Tasbeeh with haptic feedback and number saving to continue anytime.",
    feat6_t: "Radio & Audio Content",
    feat6_d: "Live broadcast of Quran Radio, recitation radio for various reciters, and selected beneficial audio clips.",
    showcase_badge: "Explore Features",
    showcase_title: "Designed to Elevate Your Worship",
    showcase_subtitle: "Every aspect of the app is crafted carefully to provide a complete, seamless faith experience.",
    zg1_title: "Exceptional Reading Experience",
    zg1_desc: "Read and ponder upon the verses of the Holy Quran anytime without internet. Complete with an eye-friendly design and smooth night mode.",
    zg1_li1: "Quick Bookmarks",
    zg1_li2: "Adjustable Font Size & Type",
    zg1_li3: "Khatm Dua & Statistics",
    zg2_title: "Your Daily Azkar in Pocket",
    zg2_desc: "The fortress of every Muslim begins with memory. The app provides morning/evening Azkar, post-prayer Azkar, and a smart electronic Rosary.",
    zg2_li1: "Smart Counter for Tasbeeh",
    zg2_li2: "Notifications for Daily Azkar",
    zg2_li3: "Vibration on Goal Completion",
    zg3_title: "Ultimate Prayer Times Accuracy",
    zg3_desc: "Never miss a prayer again with a smart time engine based on your location. Get alerts before prayer and Athan from the most beautiful voices.",
    zg3_li1: "100% Accurate Qibla Compass",
    zg3_li2: "Customizable Audio Alerts",
    zg3_li3: "Iqama Time Adjustments",
    cta_title: "Your guide towards Paradise",
    cta_desc: "Join thousands, download IslamHome app today and enjoy an Islamic experience that enriches your day.",
    footer_desc: "A project aiming to provide integrated Islamic tools to serve Muslims worldwide.",
    footer_links: "Important Links",
    footer_social: "Contact Us",
    footer_privacy: "Privacy Policy",
    footer_copyright: "IslamHome. Programmed and designed to serve Islam.",
    footer_love: "Made with love 🤍 in the Arab World",
    dev_title: "About the Developer",
    dev_subtitle: "Learn the story behind building this app",
    dev_name: "Dghar Mohamed",
    dev_role: "Founder & Full-stack Developer",
    dev_bio: "The \"IslamHome\" application was developed as a graduation project and continuous charity (Sadaqah Jariyah) to help Muslims around the world maintain their worship and Azkar easily through a modern, smooth, and completely ad-free interface.",
    dev_github: "Developer Profile (GitHub)",
    dev_linkedin: "Connect on LinkedIn",
    screenshots_title: "App Screenshots",
    screenshots_subtitle: "A quick look at the app's elegant design and interface"
  }
};

let currentLang = localStorage.getItem('appLang') || 'ar'; // Default language

function applyLanguage(lang) {
  currentLang = lang;
  localStorage.setItem('appLang', lang);
  
  // Set HTML lang and dir attributes
  document.documentElement.lang = lang;
  document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';

  // Update button label
  const langLabel = document.getElementById('langLabel');
  if (langLabel) {
    langLabel.textContent = lang === 'ar' ? 'EN' : 'AR';
  }

  // Update all elements with data-i18n
  document.querySelectorAll('[data-i18n]').forEach(element => {
    const key = element.getAttribute('data-i18n');
    if (translations[lang][key]) {
      if (element.tagName === 'TITLE') {
        document.title = translations[lang][key];
      } else {
        element.innerHTML = translations[lang][key];
      }
    }
  });

  // Update screenshots based on language
  const screenPath = lang === 'en' ? 'English' : 'Arabic';
  document.querySelectorAll('.screenshot-img').forEach(img => {
    const fileName = img.getAttribute('data-filename');
    if (fileName) {
      img.src = `assets/screenshots/${screenPath}/${fileName}`;
    }
  });

  // Restart typewriter with new language
  if (document.readyState === 'complete' || document.readyState === 'interactive') {
    initTypewriter();
  }
}

function initCarousel() {
  const carousel = document.getElementById('screenshotsCarousel');
  if (!carousel) return;

  let autoScrollInterval;
  let isHovering = false;

  // Auto-scroll logic
  const startAutoScroll = () => {
    if (autoScrollInterval) clearInterval(autoScrollInterval);
    autoScrollInterval = setInterval(() => {
      if (!isHovering) {
        const isRtl = document.documentElement.dir === 'rtl';
        const oldScrollLeft = carousel.scrollLeft;
        
        // Scroll continuously by a small amount
        carousel.scrollBy({ left: isRtl ? -1 : 1, behavior: 'auto' });
        
        // If scrollLeft didn't change, we hit the end. Reset to start.
        if (carousel.scrollLeft === oldScrollLeft) {
          carousel.scrollTo({ left: 0, behavior: 'auto' });
        }
      }
    }, 20); // Smooth continuous speed
  };

  startAutoScroll();

  // Pause auto-scroll on hover or touch
  carousel.addEventListener('mouseenter', () => isHovering = true);
  carousel.addEventListener('mouseleave', () => isHovering = false);
  carousel.addEventListener('touchstart', () => isHovering = true, {passive: true});
  carousel.addEventListener('touchend', () => isHovering = false);
}

function initLanguageSwitch() {
  const langToggleBtn = document.getElementById('langToggle');
  if (langToggleBtn) {
    langToggleBtn.addEventListener('click', () => {
      const newLang = currentLang === 'ar' ? 'en' : 'ar';
      applyLanguage(newLang);
    });
  }
  
  // Initial apply
  applyLanguage(currentLang);
}

document.addEventListener("DOMContentLoaded", () => {
  initLanguageSwitch();
  configureStoreLinks();
  setCurrentYear();
  initMobileMenu();
  initScrollReveal();
  initSmoothScroll();
  initCarousel();
});







