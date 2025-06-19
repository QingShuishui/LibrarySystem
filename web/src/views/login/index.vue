<script setup lang="ts">
import { loginAPI } from '@/api/manager'
import { useRouter } from 'vue-router'
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { useManagerStore } from '@/store'

const store = useManagerStore()

const form = ref({
  name: '',
  password: ''
});
// 表单校验的ref
const loginRef = ref()

const rules = {
  name: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { pattern: /^[a-zA-Z0-9]{1,10}$/, message: '用户名必须是1-10的字母数字', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { pattern: /^\S{6,15}$/, message: '密码必须是6-15的非空字符', trigger: 'blur' }
  ]
}

const router = useRouter()
const loading = ref(false)

const loginFn = async () => {
  try {
    // 先校验输入格式是否合法
    const valid = await loginRef.value.validate()
    if (!valid) return false

    loading.value = true

    // 调用登录接口
    const { data: res } = await loginAPI(form.value)
    console.log(res)

    if (res.code !== 0) {
      // 登录失败，提示用户(响应拦截器统一处理)
      return false
    }

    // 登录成功，提示用户
    ElMessage.success('登录成功！欢迎回来')
    // 把后端返回的token存储到Pinia里
    store.managerInfo = res.data
    // 跳转到首页
    router.push('/')
  } catch (error) {
    console.error('登录失败:', error)
    ElMessage.error('登录失败，请检查网络连接')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="modern-login">
    <!-- 背景装饰 -->
    <div class="login-background">
      <div class="bg-shape shape-1"></div>
      <div class="bg-shape shape-2"></div>
      <div class="bg-shape shape-3"></div>
    </div>

    <!-- 登录容器 -->
    <div class="login-container">
      <!-- 左侧信息面板 -->
      <div class="info-panel glass-effect">
        <div class="panel-content">
          <div class="logo-section">
            <div class="logo-icon">
              <el-icon size="48"><Reading /></el-icon>
            </div>
            <h1 class="system-name">智慧图书馆</h1>
            <p class="system-desc">Library Management System</p>
          </div>

          <div class="features-list">
            <div class="feature-item">
              <el-icon class="feature-icon"><DataAnalysis /></el-icon>
              <span>智能数据分析</span>
            </div>
            <div class="feature-item">
              <el-icon class="feature-icon"><Collection /></el-icon>
              <span>图书智能管理</span>
            </div>
            <div class="feature-item">
              <el-icon class="feature-icon"><UserFilled /></el-icon>
              <span>读者服务优化</span>
            </div>
          </div>

          <div class="welcome-text">
            <p>欢迎使用现代化图书管理系统</p>
            <p>让阅读更智能，让管理更高效</p>
          </div>
        </div>
      </div>

      <!-- 右侧登录表单 -->
      <div class="login-panel glass-effect">
        <div class="login-content">
          <div class="login-header">
            <h2 class="login-title">欢迎回来</h2>
            <p class="login-subtitle">请登录您的账户</p>
          </div>

          <el-form
            :model="form"
            :rules="rules"
            ref="loginRef"
            class="login-form"
            label-width="0"
          >
            <el-form-item prop="name">
              <div class="input-wrapper">
                <el-icon class="input-icon"><User /></el-icon>
                <el-input
                  v-model="form.name"
                  placeholder="请输入用户名"
                  class="modern-input"
                  size="large"
                />
              </div>
            </el-form-item>

            <el-form-item prop="password">
              <div class="input-wrapper">
                <el-icon class="input-icon"><Lock /></el-icon>
                <el-input
                  type="password"
                  v-model="form.password"
                  placeholder="请输入密码"
                  class="modern-input"
                  size="large"
                  show-password
                />
              </div>
            </el-form-item>

            <el-form-item>
              <el-button
                type="primary"
                class="login-btn modern-btn"
                @click="loginFn"
                size="large"
                :loading="loading"
              >
                <span v-if="!loading">立即登录</span>
                <span v-else>登录中...</span>
              </el-button>
            </el-form-item>

            <div class="login-footer">
              <el-link class="register-link" @click="$router.push('/reg')">
                还没有账户？立即注册
              </el-link>
            </div>
          </el-form>
        </div>
      </div>
    </div>
  </div>
</template>


<style lang="less" scoped>
/* 现代化登录页面样式 */
.modern-login {
  min-height: 100vh;
  background: var(--bg-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

/* 背景装饰 */
.login-background {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0;

  .bg-shape {
    position: absolute;
    border-radius: 50%;
    background: var(--gradient-primary);
    opacity: 0.1;
    animation: float 6s ease-in-out infinite;

    &.shape-1 {
      width: 300px;
      height: 300px;
      top: 10%;
      left: 10%;
      animation-delay: 0s;
    }

    &.shape-2 {
      width: 200px;
      height: 200px;
      top: 60%;
      right: 15%;
      animation-delay: 2s;
    }

    &.shape-3 {
      width: 150px;
      height: 150px;
      bottom: 20%;
      left: 60%;
      animation-delay: 4s;
    }
  }
}

@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-20px) rotate(180deg); }
}

/* 登录容器 */
.login-container {
  display: flex;
  width: 100%;
  max-width: 1200px;
  height: 600px;
  border-radius: var(--radius-xl);
  overflow: hidden;
  box-shadow: var(--shadow-glass);
  z-index: 1;
  margin: 0 24px;
}

/* 左侧信息面板 */
.info-panel {
  flex: 1;
  padding: 60px 40px;
  display: flex;
  align-items: center;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);

  .panel-content {
    width: 100%;
    text-align: center;
  }

  .logo-section {
    margin-bottom: 60px;

    .logo-icon {
      width: 80px;
      height: 80px;
      background: var(--gradient-primary);
      border-radius: var(--radius-xl);
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 20px;
      color: white;
      box-shadow: var(--shadow-glass);
    }

    .system-name {
      font-size: 36px;
      font-weight: 700;
      color: var(--text-primary);
      margin: 0 0 8px 0;
    }

    .system-desc {
      font-size: 14px;
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 2px;
      margin: 0;
    }
  }

  .features-list {
    margin-bottom: 40px;

    .feature-item {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 12px;
      padding: 16px 0;
      color: var(--text-secondary);
      font-size: 16px;

      .feature-icon {
        color: var(--text-accent);
      }
    }
  }

  .welcome-text {
    p {
      color: var(--text-muted);
      font-size: 14px;
      line-height: 1.6;
      margin: 8px 0;
    }
  }
}

/* 右侧登录面板 */
.login-panel {
  flex: 1;
  padding: 60px 40px;
  display: flex;
  align-items: center;

  .login-content {
    width: 100%;
    max-width: 400px;
    margin: 0 auto;
  }

  .login-header {
    text-align: center;
    margin-bottom: 40px;

    .login-title {
      font-size: 32px;
      font-weight: 700;
      color: var(--text-primary);
      margin: 0 0 8px 0;
    }

    .login-subtitle {
      font-size: 16px;
      color: var(--text-secondary);
      margin: 0;
    }
  }

  .login-form {
    .input-wrapper {
      position: relative;
      margin-bottom: 24px;

      .input-icon {
        position: absolute;
        left: 16px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--text-muted);
        z-index: 2;
      }

      .modern-input {
        padding-left: 48px;

        :deep(.el-input__wrapper) {
          background: var(--bg-glass);
          border: var(--border-glass);
          border-radius: var(--radius-md);
          box-shadow: var(--shadow-glass);
          backdrop-filter: blur(20px);
          transition: var(--transition-smooth);

          &:hover {
            border-color: rgba(79, 172, 254, 0.5);
            box-shadow: 0 0 0 1px rgba(79, 172, 254, 0.2);
          }

          &.is-focus {
            border-color: var(--text-accent);
            box-shadow: 0 0 0 2px rgba(79, 172, 254, 0.2);
          }
        }

        :deep(.el-input__inner) {
          color: var(--text-primary);
          background: transparent;

          &::placeholder {
            color: var(--text-muted);
          }
        }
      }
    }

    .login-btn {
      width: 100%;
      height: 48px;
      font-size: 16px;
      font-weight: 600;
      margin-bottom: 24px;
      background: var(--gradient-primary);
      border: none;
      border-radius: var(--radius-md);

      &:hover {
        background: var(--gradient-accent);
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(79, 172, 254, 0.4);
      }
    }

    .login-footer {
      text-align: center;

      .register-link {
        color: var(--text-secondary);
        font-size: 14px;
        text-decoration: none;
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
  .login-container {
    flex-direction: column;
    height: auto;
    max-width: 500px;
  }

  .info-panel {
    padding: 40px 30px;

    .logo-section {
      margin-bottom: 30px;

      .logo-icon {
        width: 60px;
        height: 60px;
      }

      .system-name {
        font-size: 28px;
      }
    }

    .features-list {
      display: none;
    }
  }

  .login-panel {
    padding: 40px 30px;

    .login-header .login-title {
      font-size: 24px;
    }
  }
}

@media (max-width: 768px) {
  .modern-login {
    padding: 20px;
  }

  .login-container {
    margin: 0;
    border-radius: var(--radius-lg);
  }

  .info-panel,
  .login-panel {
    padding: 30px 20px;
  }

  .bg-shape {
    display: none;
  }
}
</style>
