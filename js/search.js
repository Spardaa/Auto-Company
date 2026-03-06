// search.js - 搜索功能

let allTools = [];

async function initSearch() {
  try {
    const response = await fetch('tools-index.json');
    const data = await response.json();
    allTools = data.tools || [];
  } catch (e) {
    console.error('Failed to load tools for search:', e);
  }
}

function performSearch(query) {
  if (!query || query.length < 2) {
    return [];
  }
  
  query = query.toLowerCase();
  
  return allTools.filter(tool => {
    const nameZh = (tool.name.zh || '').toLowerCase();
    const nameEn = (tool.name.en || '').toLowerCase();
    const descZh = (tool.description?.zh || '').toLowerCase();
    const descEn = (tool.description?.en || '').toLowerCase();
    const tags = (tool.tags || []).join(' ').toLowerCase();
    
    return nameZh.includes(query) || 
           nameEn.includes(query) || 
           descZh.includes(query) || 
           descEn.includes(query) ||
           tags.includes(query);
  }).slice(0, 10);
}

function renderSearchResults(results) {
  const container = document.getElementById('search-results');
  if (!container) return;
  
  if (results.length === 0) {
    container.classList.remove('active');
    return;
  }
  
  const lang = localStorage.getItem('lang') || 'zh';
  
  container.innerHTML = results.map(tool => {
    const name = tool.name[lang] || tool.name.zh || 'Unnamed';
    const url = tool.url || '#';
    return '<a href="' + url + '" class="search-result-item">' + name + '</a>';
  }).join('');
  
  container.classList.add('active');
}

document.addEventListener('DOMContentLoaded', () => {
  initSearch();
  
  const input = document.getElementById('search-input');
  const results = document.getElementById('search-results');
  
  if (input) {
    input.addEventListener('input', (e) => {
      const query = e.target.value;
      const results = performSearch(query);
      renderSearchResults(results);
    });
    
    input.addEventListener('focus', () => {
      if (input.value.length >= 2) {
        const results = performSearch(input.value);
        renderSearchResults(results);
      }
    });
  }
  
  document.addEventListener('click', (e) => {
    if (!e.target.closest('.search-box')) {
      if (results) {
        results.classList.remove('active');
      }
    }
  });
});
