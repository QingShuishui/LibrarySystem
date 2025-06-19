<script setup lang="ts" name="layout">
import { ref } from 'vue'
import { RouterView, useRouter } from 'vue-router'
import { ElMessageBox, ElMessage } from 'element-plus'
import { useManagerStore } from '@/store'

// ------ data ------
const managerStore = useManagerStore()
const router = useRouter()

// 展开的菜单项
const expandedMenus = ref<string[]>([])

// 主题切换状态
const isDarkMode = ref(true)

// 现代化菜单配置
const menuList = [
  {
    title: '数据概览',
    path: '/home',
    icon: 'DataAnalysis',
  },
  {
    title: '图书分类',
    path: '/bookCategory',
    icon: 'Collection',
  },
  {
    title: '图书管理',
    path: '/book',
    icon: 'Reading',
  },
  {
    title: '读者分类',
    path: '/readerCategory',
    icon: 'UserFilled',
  },
  {
    title: '读者管理',
    path: '/reader',
    icon: 'Avatar',
  },
  {
    title: '借阅管理',
    path: '/lendReturn',
    icon: 'DocumentCopy',
    children: {
      0: {
        subpath: '/lendReturn/add',
        title: '新增借书',
        icon: 'Plus',
        children: null
      },
      1: {
        subpath: '/lendReturn',
        title: '借阅记录',
        icon: 'List',
        children: null
      }
    }
  },
  {
    title: '系统设置',
    path: '/manager',
    icon: 'Setting',
  },
]

// ------ methods ------
// 退出登录
const quitFn = () => {
  ElMessageBox.confirm(
    '确定要退出系统吗？',
    '退出确认',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
    }
  )
    .then(() => {
      ElMessage({
        type: 'success',
        message: '退出成功',
      })
      managerStore.managerInfo = null
      router.push('/login')
    })
    .catch(() => {
      ElMessage({
        type: 'info',
        message: '已取消退出',
      })
    })
}

// 切换子菜单展开状态
const toggleSubmenu = (path: string) => {
  const index = expandedMenus.value.indexOf(path)
  if (index > -1) {
    expandedMenus.value.splice(index, 1)
  } else {
    expandedMenus.value.push(path)
  }
}

// 主题切换
const toggleTheme = () => {
  isDarkMode.value = !isDarkMode.value
  document.documentElement.setAttribute('data-theme', isDarkMode.value ? 'dark' : 'light')
}
</script>

<template>
  <div class="modern-layout">
    <!-- 现代化顶部导航栏 -->
    <header class="modern-header glass-effect">
      <div class="header-content">
        <!-- Logo和标题区域 -->
        <div class="logo-section">
          <div class="logo-icon">
            <el-icon size="32"><Reading /></el-icon>
          </div>
          <h1 class="system-title">
            <span class="title-main">智慧图书馆</span>
            <span class="title-sub">Library Management System</span>
          </h1>
        </div>

        <!-- 搜索栏 -->
        <div class="search-section">
          <div class="search-container glass-effect">
            <el-icon class="search-icon"><Search /></el-icon>
            <input type="text" placeholder="搜索图书、读者..." class="search-input" />
          </div>
        </div>

        <!-- 用户信息区域 -->
        <div class="user-section">
          <!-- 通知按钮 -->
          <div class="notification-btn glass-effect">
            <el-icon size="20"><Bell /></el-icon>
            <span class="notification-badge">3</span>
          </div>

          <!-- 主题切换按钮 -->
          <div class="theme-toggle glass-effect" @click="toggleTheme">
            <el-icon size="20"><Sunny /></el-icon>
          </div>

          <!-- 用户下拉菜单 -->
          <el-dropdown class="user-dropdown">
            <div class="user-avatar glass-effect">
              <div class="avatar-placeholder">
                <el-icon size="20"><User /></el-icon>
              </div>
              <div class="user-info">
                <span class="user-name">{{ managerStore.managerInfo ? managerStore.managerInfo.name : '未登录' }}</span>
                <span class="user-role">管理员</span>
              </div>
              <el-icon class="dropdown-arrow"><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu class="modern-dropdown">
                <el-dropdown-item class="dropdown-item">
                  <el-icon><User /></el-icon>
                  个人资料
                </el-dropdown-item>
                <el-dropdown-item class="dropdown-item">
                  <el-icon><Setting /></el-icon>
                  系统设置
                </el-dropdown-item>
                <el-dropdown-item class="dropdown-item" divided @click="quitFn">
                  <el-icon><SwitchButton /></el-icon>
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </header>

    <!-- 主体容器 -->
    <div class="main-container">
      <!-- 现代化侧边栏 -->
      <aside class="modern-sidebar">
        <nav class="sidebar-nav">
          <div class="nav-menu">
            <!-- 主菜单项 -->
            <div v-for="item in menuList" :key="item.path" class="menu-group">
              <!-- 无子菜单的项目 -->
              <router-link
                v-if="!item.children"
                :to="item.path"
                class="menu-item"
                :class="{ active: $route.path === item.path }"
              >
                <div class="menu-item-content">
                  <div class="menu-icon">
                    <el-icon size="20">
                      <component :is="item.icon" />
                    </el-icon>
                  </div>
                  <span class="menu-text">{{ item.title }}</span>
                  <div class="menu-indicator"></div>
                </div>
              </router-link>

              <!-- 有子菜单的项目 -->
              <div v-else class="menu-item-with-children">
                <div class="menu-item parent-menu" @click="toggleSubmenu(item.path)">
                  <div class="menu-item-content">
                    <div class="menu-icon">
                      <el-icon size="20">
                        <component :is="item.icon" />
                      </el-icon>
                    </div>
                    <span class="menu-text">{{ item.title }}</span>
                    <el-icon class="expand-icon" :class="{ expanded: expandedMenus.includes(item.path) }">
                      <ArrowRight />
                    </el-icon>
                  </div>
                </div>

                <!-- 子菜单 -->
                <div class="submenu" :class="{ expanded: expandedMenus.includes(item.path) }">
                  <router-link
                    v-for="(subItem, index) in item.children"
                    :key="subItem.subpath"
                    :to="subItem.subpath"
                    class="submenu-item"
                    :class="{ active: $route.path === subItem.subpath }"
                  >
                    <div class="submenu-item-content">
                      <div class="submenu-icon">
                        <el-icon size="16">
                          <component :is="subItem.icon" />
                        </el-icon>
                      </div>
                      <span class="submenu-text">{{ subItem.title }}</span>
                    </div>
                  </router-link>
                </div>
              </div>
            </div>
          </div>
        </nav>
      </aside>

      <!-- 主内容区域 -->
      <main class="main-content">
        <div class="content-wrapper">
          <router-view></router-view>
        </div>

        <!-- 现代化页脚 -->
        <footer class="modern-footer">
          <div class="footer-content">
            <p class="copyright">© 2025 智慧图书馆管理系统 - 让阅读更智能</p>
            <div class="footer-links">
              <span>技术支持</span>
              <span>帮助中心</span>
              <span>关于我们</span>
            </div>
          </div>
        </footer>
      </main>
    </div>
  </div>
</template>

<style lang="less" scoped>
/* 现代化布局样式 */
.modern-layout {
  min-height: 100vh;
  background: var(--bg-primary);
  display: flex;
  flex-direction: column;
}

/* 现代化头部 */
.modern-header {
  height: 80px;
  padding: 0 32px;
  border-bottom: var(--border-glass);
  position: sticky;
  top: 0;
  z-index: 1000;

  .header-content {
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    max-width: 1920px;
    margin: 0 auto;
  }
}

/* Logo区域 */
.logo-section {
  display: flex;
  align-items: center;
  gap: 16px;

  .logo-icon {
    width: 48px;
    height: 48px;
    background: var(--gradient-primary);
    border-radius: var(--radius-md);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    box-shadow: var(--shadow-glass);
  }

  .system-title {
    display: flex;
    flex-direction: column;

    .title-main {
      font-size: 24px;
      font-weight: 700;
      color: var(--text-primary);
      line-height: 1.2;
    }

    .title-sub {
      font-size: 12px;
      color: var(--text-secondary);
      font-weight: 400;
      text-transform: uppercase;
      letter-spacing: 1px;
    }
  }
}

/* 搜索区域 */
.search-section {
  flex: 1;
  max-width: 400px;
  margin: 0 40px;

  .search-container {
    position: relative;
    border-radius: var(--radius-lg);
    padding: 12px 20px;
    display: flex;
    align-items: center;
    gap: 12px;

    .search-icon {
      color: var(--text-secondary);
    }

    .search-input {
      flex: 1;
      background: transparent;
      border: none;
      outline: none;
      color: var(--text-primary);
      font-size: 14px;

      &::placeholder {
        color: var(--text-muted);
      }
    }
  }
}

/* 用户区域 */
.user-section {
  display: flex;
  align-items: center;
  gap: 16px;
}

.notification-btn,
.theme-toggle {
  width: 44px;
  height: 44px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  position: relative;

  &:hover {
    transform: translateY(-2px);
  }
}

.notification-badge {
  position: absolute;
  top: -4px;
  right: -4px;
  background: var(--gradient-warning);
  color: white;
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 10px;
  min-width: 16px;
  text-align: center;
}

/* 用户下拉菜单 */
.user-dropdown {
  .user-avatar {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 8px 16px;
    border-radius: var(--radius-lg);
    cursor: pointer;

    .avatar-placeholder {
      width: 36px;
      height: 36px;
      border-radius: 50%;
      background: var(--gradient-primary);
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
    }

    .user-info {
      display: flex;
      flex-direction: column;

      .user-name {
        font-size: 14px;
        font-weight: 600;
        color: var(--text-primary);
      }

      .user-role {
        font-size: 12px;
        color: var(--text-secondary);
      }
    }

    .dropdown-arrow {
      color: var(--text-secondary);
      transition: var(--transition-smooth);
    }

    &:hover .dropdown-arrow {
      transform: rotate(180deg);
    }
  }
}

/* 主体容器 */
.main-container {
  flex: 1;
  display: flex;
  overflow: hidden;
}

/* 现代化侧边栏 */
.modern-sidebar {
  width: 280px;
  background: var(--bg-secondary);
  border-right: var(--border-glass);
  overflow-y: auto;
  transition: var(--transition-smooth);

  .sidebar-nav {
    padding: 24px 16px;

    .nav-menu {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
  }
}

/* 菜单项样式 */
.menu-group {
  margin-bottom: 4px;
}

.menu-item {
  display: block;
  text-decoration: none;
  color: var(--text-secondary);
  border-radius: var(--radius-md);
  transition: var(--transition-smooth);
  position: relative;
  overflow: hidden;

  &:hover {
    color: var(--text-primary);
    background: var(--bg-glass);
    transform: translateX(4px);
  }

  &.active {
    color: var(--text-primary);
    background: var(--gradient-primary);
    box-shadow: var(--shadow-glass);

    .menu-indicator {
      opacity: 1;
      transform: scaleY(1);
    }
  }

  .menu-item-content {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 16px 20px;
    position: relative;

    .menu-icon {
      width: 24px;
      height: 24px;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
    }

    .menu-text {
      font-size: 14px;
      font-weight: 500;
      flex: 1;
    }

    .menu-indicator {
      position: absolute;
      left: 0;
      top: 50%;
      transform: translateY(-50%) scaleY(0);
      width: 4px;
      height: 24px;
      background: var(--gradient-accent);
      border-radius: 0 4px 4px 0;
      opacity: 0;
      transition: var(--transition-smooth);
    }
  }
}

/* 父菜单项 */
.parent-menu {
  cursor: pointer;

  .expand-icon {
    transition: var(--transition-smooth);

    &.expanded {
      transform: rotate(90deg);
    }
  }
}

/* 子菜单 */
.submenu {
  max-height: 0;
  overflow: hidden;
  transition: max-height 0.3s ease;
  margin-left: 20px;

  &.expanded {
    max-height: 200px;
  }
}

.submenu-item {
  display: block;
  text-decoration: none;
  color: var(--text-muted);
  border-radius: var(--radius-sm);
  transition: var(--transition-smooth);
  margin: 4px 0;

  &:hover {
    color: var(--text-secondary);
    background: var(--bg-glass);
  }

  &.active {
    color: var(--text-accent);
    background: rgba(79, 172, 254, 0.1);
  }

  .submenu-item-content {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;

    .submenu-icon {
      width: 20px;
      height: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .submenu-text {
      font-size: 13px;
      font-weight: 400;
    }
  }
}

/* 主内容区域 */
.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;

  .content-wrapper {
    flex: 1;
    padding: 24px;
    overflow-y: auto;
    background: var(--bg-primary);
  }
}

/* 现代化页脚 */
.modern-footer {
  padding: 16px 24px;
  border-top: var(--border-glass);
  background: var(--bg-secondary);

  .footer-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    max-width: 1920px;
    margin: 0 auto;

    .copyright {
      font-size: 12px;
      color: var(--text-muted);
      margin: 0;
    }

    .footer-links {
      display: flex;
      gap: 24px;

      span {
        font-size: 12px;
        color: var(--text-secondary);
        cursor: pointer;
        transition: var(--transition-smooth);

        &:hover {
          color: var(--text-accent);
        }
      }
    }
  }
}

/* 响应式设计 */
@media (max-width: 1024px) {
  .modern-sidebar {
    width: 240px;
  }

  .search-section {
    max-width: 300px;
    margin: 0 20px;
  }
}

@media (max-width: 768px) {
  .modern-header {
    padding: 0 16px;

    .header-content {
      gap: 16px;
    }
  }

  .logo-section .system-title .title-sub {
    display: none;
  }

  .search-section {
    display: none;
  }

  .modern-sidebar {
    width: 200px;
  }

  .main-content .content-wrapper {
    padding: 16px;
  }
}
</style>

<!-- 全局样式覆盖 -->
<style>
/* Element Plus 组件样式覆盖 */
.modern-dropdown {
  background: var(--bg-secondary) !important;
  border: var(--border-glass) !important;
  border-radius: var(--radius-md) !important;
  box-shadow: var(--shadow-glass) !important;
  backdrop-filter: blur(20px);

  .dropdown-item {
    color: var(--text-secondary) !important;
    padding: 12px 16px !important;
    display: flex !important;
    align-items: center !important;
    gap: 8px !important;
    transition: var(--transition-smooth) !important;

    &:hover {
      background: var(--bg-glass) !important;
      color: var(--text-primary) !important;
    }
  }
}

/* 滚动条样式 */
.modern-sidebar::-webkit-scrollbar {
  width: 4px;
}

.modern-sidebar::-webkit-scrollbar-track {
  background: transparent;
}

.modern-sidebar::-webkit-scrollbar-thumb {
  background: var(--bg-glass);
  border-radius: 2px;
}

.content-wrapper::-webkit-scrollbar {
  width: 6px;
}

.content-wrapper::-webkit-scrollbar-track {
  background: var(--bg-secondary);
}

.content-wrapper::-webkit-scrollbar-thumb {
  background: var(--gradient-primary);
  border-radius: 3px;
}
</style>

