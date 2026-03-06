// i18n.js - 国际化支持

const translations = {
  zh: {
    'site-title': '工具箱',
    'search-placeholder': '搜索工具...',
    'category-image': '图片处理',
    'category-audio': '音频处理',
    'category-video': '视频处理',
    'category-document': '文档处理',
    'category-data': '数据转换',
    'category-calculator': '计算工具',
    'category-generator': '生成工具',
    'category-analyzer': '分析工具',
    'category-utility': '实用工具',
    'popular-tools': '热门工具',
    'latest-tools': '最新工具',
    'footer-text': '© 2026 工具箱'
  },
  en: {
    'site-title': 'Toolbox',
    'search-placeholder': 'Search tools...',
    'category-image': 'Image Processing',
    'category-audio': 'Audio Processing',
    'category-video': 'Video Processing',
    'category-document': 'Document Processing',
    'category-data': 'Data Conversion',
    'category-calculator': 'Calculator Tools',
    'category-generator': 'Generator Tools',
    'category-analyzer': 'Analyzer Tools',
    'category-utility': 'Utility Tools',
    'popular-tools': 'Popular Tools',
    'latest-tools': 'Latest Tools',
    'footer-text': '© 2026 Toolbox'
  }
};

let currentLang = 'zh';

function setLanguage(lang) {
  currentLang = lang;
  localStorage.setItem('lang', lang);
  
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (translations[lang][key]) {
      el.textContent = translations[lang][key];
    }
  });
  
  document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
    const key = el.getAttribute('data-i18n-placeholder');
    if (translations[lang][key]) {
      el.placeholder = translations[lang][key];
    }
  });
  
  document.documentElement.lang = lang;
}

function initI18n() {
  const savedLang = localStorage.getItem('lang') || 'zh';
  const langSwitcher = document.getElementById('lang-switcher');
  
  if (langSwitcher) {
    langSwitcher.value = savedLang;
    langSwitcher.addEventListener('change', (e) => {
      setLanguage(e.target.value);
    });
  }
  
  setLanguage(savedLang);
}

document.addEventListener('DOMContentLoaded', initI18n);
