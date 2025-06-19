<template>
  <div id="app" class="modern-app">
    <router-view />
  </div>
</template>

<style>
/* 现代化全局样式重置 */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

/* 深色主题全局变量 */
:root {
  /* 深色主题色彩系统 */
  --bg-primary: #0a0a0f;
  --bg-secondary: #1a1a2e;
  --bg-tertiary: #16213e;
  --bg-glass: rgba(255, 255, 255, 0.1);
  --bg-glass-hover: rgba(255, 255, 255, 0.15);

  /* 渐变色系 */
  --gradient-primary: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  --gradient-secondary: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  --gradient-accent: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  --gradient-success: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
  --gradient-warning: linear-gradient(135deg, #fa709a 0%, #fee140 100%);

  /* 文字颜色 */
  --text-primary: #ffffff;
  --text-secondary: #b8bcc8;
  --text-muted: #6c7293;
  --text-accent: #00f2fe;

  /* 边框和阴影 */
  --border-glass: 1px solid rgba(255, 255, 255, 0.2);
  --shadow-glass: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
  --shadow-neumorphic: 20px 20px 60px #0d0d12, -20px -20px 60px #0d0d12;
  --shadow-hover: 0 12px 40px 0 rgba(31, 38, 135, 0.5);

  /* 圆角 */
  --radius-sm: 8px;
  --radius-md: 16px;
  --radius-lg: 24px;
  --radius-xl: 32px;

  /* 动画 */
  --transition-smooth: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  --transition-bounce: all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}

/* 全局深色主题 */
body {
  background: var(--bg-primary);
  color: var(--text-primary);
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  line-height: 1.6;
  overflow-x: hidden;
  transition: var(--transition-smooth);
}

/* 现代化滚动条 */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: var(--bg-secondary);
  border-radius: var(--radius-sm);
}

::-webkit-scrollbar-thumb {
  background: var(--gradient-primary);
  border-radius: var(--radius-sm);
  transition: var(--transition-smooth);
}

::-webkit-scrollbar-thumb:hover {
  background: var(--gradient-accent);
}

/* 现代化应用容器 */
.modern-app {
  min-height: 100vh;
  background: var(--bg-primary);
  position: relative;
  overflow: hidden;
}

/* 背景装饰效果 */
.modern-app::before {
  content: '';
  position: fixed;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle, rgba(102, 126, 234, 0.1) 0%, transparent 50%);
  animation: backgroundFloat 20s ease-in-out infinite;
  z-index: -1;
}

@keyframes backgroundFloat {
  0%, 100% { transform: translate(0, 0) rotate(0deg); }
  33% { transform: translate(30px, -30px) rotate(120deg); }
  66% { transform: translate(-20px, 20px) rotate(240deg); }
}

/* 玻璃拟态效果基础类 */
.glass-effect {
  background: var(--bg-glass);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: var(--border-glass);
  box-shadow: var(--shadow-glass);
  transition: var(--transition-smooth);
}

.glass-effect:hover {
  background: var(--bg-glass-hover);
  box-shadow: var(--shadow-hover);
  transform: translateY(-2px);
}

/* 新拟物效果基础类 */
.neumorphic {
  background: var(--bg-secondary);
  box-shadow: var(--shadow-neumorphic);
  border-radius: var(--radius-md);
  transition: var(--transition-smooth);
}

.neumorphic:hover {
  box-shadow: inset 20px 20px 60px #0d0d12, inset -20px -20px 60px #0d0d12;
}

/* 现代化按钮样式 */
.modern-btn {
  background: var(--gradient-primary);
  border: none;
  border-radius: var(--radius-md);
  color: var(--text-primary);
  padding: 12px 24px;
  font-weight: 600;
  cursor: pointer;
  transition: var(--transition-bounce);
  position: relative;
  overflow: hidden;
}

.modern-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s;
}

.modern-btn:hover::before {
  left: 100%;
}

.modern-btn:hover {
  transform: translateY(-3px) scale(1.05);
  box-shadow: 0 10px 25px rgba(102, 126, 234, 0.4);
}

/* 现代化卡片样式 */
.modern-card {
  background: var(--bg-glass);
  backdrop-filter: blur(20px);
  border: var(--border-glass);
  border-radius: var(--radius-lg);
  padding: 24px;
  box-shadow: var(--shadow-glass);
  transition: var(--transition-smooth);
  position: relative;
  overflow: hidden;
}

.modern-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: var(--gradient-accent);
  opacity: 0;
  transition: var(--transition-smooth);
}

.modern-card:hover::before {
  opacity: 1;
}

.modern-card:hover {
  transform: translateY(-5px);
  box-shadow: var(--shadow-hover);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .modern-card {
    padding: 16px;
    border-radius: var(--radius-md);
  }

  .modern-btn {
    padding: 10px 20px;
  }
}
</style>