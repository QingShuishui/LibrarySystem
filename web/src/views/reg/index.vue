<script setup lang="ts" name="my-register">
import { registerAPI } from '@/api/manager'
import { useRouter } from 'vue-router'
import { ref } from 'vue'
import { ElMessage } from 'element-plus'

const form = ref({
  name: '',
  password: '',
  repassword: ''
})

const registerRef = ref()
const loading = ref(false)
const router = useRouter()

// 自定义校验规则: 两次密码是否一致
const samePwd = (rule: any, value: any, callback: any) => {
  if (value !== form.value.password) {
    callback(new Error('两次输入的密码不一致!'))
  } else {
    callback()
  }
}

const rules = {
  name: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    {
      pattern: /^[a-zA-Z0-9]{3,20}$/,
      message: '用户名必须是3-20位的字母数字组合',
      trigger: 'blur'
    }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    {
      pattern: /^\S{6,20}$/,
      message: '密码必须是6-20位的非空字符',
      trigger: 'blur'
    }
  ],
  repassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    { pattern: /^\S{6,20}$/, message: '密码必须是6-20位的非空字符', trigger: 'blur' },
    { validator: samePwd, trigger: 'blur' }
  ]
}

const registerFn = async () => {
  try {
    const valid = await registerRef.value.validate()
    if (!valid) return false
    
    loading.value = true
    
    const { data: res } = await registerAPI(form.value)
    console.log(res)
    
    if (res.code !== 0) {
      ElMessage.error(res.msg || '注册失败，请重试')
      return false
    }
    
    ElMessage.success('注册成功！即将跳转到登录页面')
    
    // 延迟跳转，让用户看到成功提示
    setTimeout(() => {
      router.push('/login')
    }, 1500)
    
  } catch (error) {
    console.error('注册失败:', error)
    ElMessage.error('注册失败，请检查网络连接')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="modern-register">
    <!-- 背景装饰 -->
    <div class="register-background">
      <div class="bg-shape shape-1"></div>
      <div class="bg-shape shape-2"></div>
      <div class="bg-shape shape-3"></div>
    </div>
    
    <!-- 注册容器 -->
    <div class="register-container">
      <!-- 左侧信息面板 -->
      <div class="info-panel glass-effect">
        <div class="panel-content">
          <div class="logo-section">
            <div class="logo-icon">
              <el-icon size="48"><UserFilled /></el-icon>
            </div>
            <h1 class="system-name">加入智慧图书馆</h1>
            <p class="system-desc">Join Our Library Management System</p>
          </div>
          
          <div class="benefits-list">
            <div class="benefit-item">
              <el-icon class="benefit-icon"><Check /></el-icon>
              <span>免费注册使用</span>
            </div>
            <div class="benefit-item">
              <el-icon class="benefit-icon"><Check /></el-icon>
              <span>专业图书管理</span>
            </div>
            <div class="benefit-item">
              <el-icon class="benefit-icon"><Check /></el-icon>
              <span>数据安全保障</span>
            </div>
          </div>
          
          <div class="welcome-text">
            <p>创建您的管理员账户</p>
            <p>开始您的智能图书管理之旅</p>
          </div>
        </div>
      </div>
      
      <!-- 右侧注册表单 -->
      <div class="register-panel glass-effect">
        <div class="register-content">
          <div class="register-header">
            <h2 class="register-title">创建新账户</h2>
            <p class="register-subtitle">请填写以下信息完成注册</p>
          </div>
          
          <el-form 
            :model="form" 
            :rules="rules" 
            ref="registerRef" 
            class="register-form"
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
            
            <el-form-item prop="repassword">
              <div class="input-wrapper">
                <el-icon class="input-icon"><Lock /></el-icon>
                <el-input 
                  type="password" 
                  v-model="form.repassword" 
                  placeholder="请再次确认密码"
                  class="modern-input"
                  size="large"
                  show-password
                />
              </div>
            </el-form-item>
            
            <el-form-item>
              <el-button 
                type="primary" 
                class="register-btn modern-btn" 
                @click="registerFn"
                size="large"
                :loading="loading"
              >
                <span v-if="!loading">立即注册</span>
                <span v-else>注册中...</span>
              </el-button>
            </el-form-item>
            
            <div class="register-footer">
              <el-link class="login-link" @click="router.push('/login')">
                已有账户？立即登录
              </el-link>
            </div>
          </el-form>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="less" scoped>
/* 现代化注册页面样式 */
.modern-register {
  min-height: 100vh;
  background: var(--bg-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

/* 背景装饰 */
.register-background {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  
  .bg-shape {
    position: absolute;
    border-radius: 50%;
    background: var(--gradient-secondary);
    opacity: 0.1;
    animation: float 8s ease-in-out infinite;
    
    &.shape-1 {
      width: 250px;
      height: 250px;
      top: 15%;
      right: 10%;
      animation-delay: 0s;
    }
    
    &.shape-2 {
      width: 180px;
      height: 180px;
      bottom: 20%;
      left: 15%;
      animation-delay: 3s;
    }
    
    &.shape-3 {
      width: 120px;
      height: 120px;
      top: 50%;
      left: 70%;
      animation-delay: 6s;
    }
  }
}

@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-30px) rotate(180deg); }
}

/* 注册容器 */
.register-container {
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
  background: linear-gradient(135deg, rgba(240, 147, 251, 0.1) 0%, rgba(245, 87, 108, 0.1) 100%);
  
  .panel-content {
    width: 100%;
    text-align: center;
  }
  
  .logo-section {
    margin-bottom: 60px;
    
    .logo-icon {
      width: 80px;
      height: 80px;
      background: var(--gradient-secondary);
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
  
  .benefits-list {
    margin-bottom: 40px;
    
    .benefit-item {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 12px;
      padding: 16px 0;
      color: var(--text-secondary);
      font-size: 16px;
      
      .benefit-icon {
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

/* 右侧注册面板 */
.register-panel {
  flex: 1;
  padding: 60px 40px;
  display: flex;
  align-items: center;

  .register-content {
    width: 100%;
    max-width: 400px;
    margin: 0 auto;
  }

  .register-header {
    text-align: center;
    margin-bottom: 40px;

    .register-title {
      font-size: 32px;
      font-weight: 700;
      color: var(--text-primary);
      margin: 0 0 8px 0;
    }

    .register-subtitle {
      font-size: 16px;
      color: var(--text-secondary);
      margin: 0;
    }
  }

  .register-form {
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
            border-color: rgba(240, 147, 251, 0.5);
            box-shadow: 0 0 0 1px rgba(240, 147, 251, 0.2);
          }

          &.is-focus {
            border-color: #f093fb;
            box-shadow: 0 0 0 2px rgba(240, 147, 251, 0.2);
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

    .register-btn {
      width: 100%;
      height: 48px;
      font-size: 16px;
      font-weight: 600;
      margin-bottom: 24px;
      background: var(--gradient-secondary);
      border: none;
      border-radius: var(--radius-md);

      &:hover {
        background: var(--gradient-warning);
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(240, 147, 251, 0.4);
      }
    }

    .register-footer {
      text-align: center;

      .login-link {
        color: var(--text-secondary);
        font-size: 14px;
        text-decoration: none;
        transition: var(--transition-smooth);

        &:hover {
          color: #f093fb;
        }
      }
    }
  }
}

/* 响应式设计 */
@media (max-width: 1024px) {
  .register-container {
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

    .benefits-list {
      display: none;
    }
  }

  .register-panel {
    padding: 40px 30px;

    .register-header .register-title {
      font-size: 24px;
    }
  }
}

@media (max-width: 768px) {
  .modern-register {
    padding: 20px;
  }

  .register-container {
    margin: 0;
    border-radius: var(--radius-lg);
  }

  .info-panel,
  .register-panel {
    padding: 30px 20px;
  }

  .bg-shape {
    display: none;
  }
}
</style>
