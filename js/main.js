// main.js - 主逻辑

async function loadTools() {
  try {
    const response = await fetch('tools-index.json');
    if (!response.ok) {
      throw new Error('Failed to load tools-index.json');
    }
    const data = await response.json();
    const tools = data.tools || [];
    
    // 渲染热门工具
    const popularTools = tools.filter(t => t.popular).slice(0, 6);
    renderTools('popular-tools', popularTools);
    
    // 渲染最新工具
    const latestTools = tools.sort((a, b) => 
      new Date(b.createdAt) - new Date(a.createdAt)
    ).slice(0, 6);
    renderTools('latest-tools', latestTools);
    
    return tools;
  } catch (error) {
    console.error('Failed to load tools:', error);
    const popularContainer = document.getElementById('popular-tools');
    const latestContainer = document.getElementById('latest-tools');
    if (popularContainer) popularContainer.innerHTML = '<p class="no-tools">加载工具失败，请刷新页面重试</p>';
    if (latestContainer) latestContainer.innerHTML = '<p class="no-tools">加载工具失败，请刷新页面重试</p>';
    return [];
  }
}

function renderTools(containerId, tools) {
  const container = document.getElementById(containerId);
  if (!container) return;
  
  const lang = localStorage.getItem('lang') || 'zh';
  
  if (tools.length === 0) {
    container.innerHTML = '<p class="no-tools">暂无工具</p>';
    return;
  }
  
  container.innerHTML = tools.map(tool => {
    const name = tool.name[lang] || tool.name.zh || 'Unnamed';
    const desc = tool.description ? (tool.description[lang] || tool.description.zh || '') : '';
    const icon = tool.icon || '🔧';
    const url = tool.url || '#';
    
    return '<a href="' + url + '" class="tool-card">' +
      '<div class="tool-icon">' + icon + '</div>' +
      '<div class="tool-name">' + name + '</div>' +
      '<div class="tool-desc">' + desc + '</div>' +
      '</a>';
  }).join('');
}

document.addEventListener('DOMContentLoaded', function() {
  loadTools();
});
