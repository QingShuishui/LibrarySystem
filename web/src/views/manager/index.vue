<script setup lang="ts" name="manager-settings">
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ref, reactive, onMounted } from 'vue'
import { useManagerStore } from '@/store'
import { updateAPI } from '@/api/manager'

// ------ data ------
const managerStore = useManagerStore()
const router = useRouter()
const loading = ref(false)

const form = reactive({
  name: '',
  oldPwd: '',
  newPwd: '',
  rePwd: '',
})
const tmpform = ref()

// 自定义校验规则: 两次密码是否一致
const samePwd = (rules: any, value: any, callback: any) => {
  if (value !== form.newPwd) {
    callback(new Error('两次输入的密码不一致!'))
  } else {
    callback()
  }
}

const rules = {
  name: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 2, max: 20, message: '用户名长度在 2 到 20 个字符', trigger: 'blur' }
  ],
  oldPwd: [
    { required: true, message: '请输入原密码', trigger: 'blur' },
    { pattern: /^\S{6,20}$/, message: '密码必须是6-20位的非空字符', trigger: 'blur' }
  ],
  newPwd: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { pattern: /^\S{6,20}$/, message: '密码必须是6-20位的非空字符', trigger: 'blur' }
  ],
  rePwd: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    { pattern: /^\S{6,20}$/, message: '密码必须是6-20位的非空字符', trigger: 'blur' },
    { validator: samePwd, trigger: 'blur' }
  ]
}

// 初始化表单数据
onMounted(() => {
  if (managerStore.managerInfo) {
    form.name = managerStore.managerInfo.name
  }
})

// ------ methods ------
// 修改管理员信息
const submit = async () => {
  try {
    const valid = await tmpform.value.validate()
    if (!valid) return false

    loading.value = true

    const submitForm = {
      name: form.name,
      oldPwd: form.oldPwd,
      newPwd: form.newPwd,
    }

    console.log('提交表单信息:', submitForm)

    const { data: res } = await updateAPI(submitForm)
    if (res.code !== 0) {
      return false // 错误信息会在响应拦截器中处理
    }

    ElMessage.success('修改成功！请重新登录')

    // 更新store中的用户信息
    if (managerStore.managerInfo) {
      managerStore.managerInfo.name = form.name
    }

    // 延迟跳转，让用户看到成功提示
    setTimeout(() => {
      router.push('/login')
    }, 1500)

  } catch (error) {
    console.error('修改失败:', error)
    ElMessage.error('修改失败，请检查网络连接')
  } finally {
    loading.value = false
  }
}

// 取消修改
const cancel = () => {
  router.push('/home')
}

// 重置表单
const resetForm = () => {
  tmpform.value.resetFields()
  if (managerStore.managerInfo) {
    form.name = managerStore.managerInfo.name
  }
}
</script>

<template>
  <div class="modern-manager-settings">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <el-icon class="title-icon"><Setting /></el-icon>
          个人设置
        </h1>
        <p class="page-subtitle">修改个人信息和密码设置</p>
      </div>
    </div>

    <!-- 设置容器 -->
    <div class="settings-container">
      <!-- 用户信息卡片 -->
      <div class="user-info-card modern-card">
        <div class="card-header">
          <h3 class="card-title">
            <el-icon><User /></el-icon>
            当前用户信息
          </h3>
        </div>
        <div class="user-info-content">
          <div class="user-avatar">
            <div class="avatar-placeholder">
              <el-icon size="32"><User /></el-icon>
            </div>
          </div>
          <div class="user-details">
            <h4 class="user-name">{{ managerStore.managerInfo?.name || '未登录' }}</h4>
            <p class="user-role">系统管理员</p>
            <p class="user-status">
              <el-tag type="success" effect="dark" size="small">在线</el-tag>
            </p>
          </div>
        </div>
      </div>

      <!-- 修改信息表单 -->
      <div class="settings-form-card modern-card">
        <div class="card-header">
          <h3 class="card-title">
            <el-icon><Edit /></el-icon>
            修改个人信息
          </h3>
        </div>

        <el-form
          :model="form"
          :rules="rules"
          ref="tmpform"
          class="modern-form"
          label-width="100px"
        >
          <div class="form-section">
            <h4 class="section-title">基本信息</h4>
            <el-form-item label="用户名" prop="name">
              <el-input
                v-model="form.name"
                placeholder="请输入用户名"
                class="modern-input"
                size="large"
              >
                <template #prefix>
                  <el-icon><User /></el-icon>
                </template>
              </el-input>
            </el-form-item>
          </div>

          <div class="form-section">
            <h4 class="section-title">密码设置</h4>
            <el-form-item label="原密码" prop="oldPwd">
              <el-input
                type="password"
                v-model="form.oldPwd"
                placeholder="请输入原密码"
                class="modern-input"
                size="large"
                show-password
              >
                <template #prefix>
                  <el-icon><Lock /></el-icon>
                </template>
              </el-input>
            </el-form-item>

            <el-form-item label="新密码" prop="newPwd">
              <el-input
                type="password"
                v-model="form.newPwd"
                placeholder="请输入新密码"
                class="modern-input"
                size="large"
                show-password
              >
                <template #prefix>
                  <el-icon><Lock /></el-icon>
                </template>
              </el-input>
            </el-form-item>

            <el-form-item label="确认密码" prop="rePwd">
              <el-input
                type="password"
                v-model="form.rePwd"
                placeholder="请再次输入新密码"
                class="modern-input"
                size="large"
                show-password
              >
                <template #prefix>
                  <el-icon><Lock /></el-icon>
                </template>
              </el-input>
            </el-form-item>
          </div>

          <div class="form-actions">
            <el-button
              type="primary"
              @click="submit"
              class="submit-btn"
              size="large"
              :loading="loading"
            >
              <el-icon v-if="!loading"><Check /></el-icon>
              {{ loading ? '保存中...' : '保存修改' }}
            </el-button>

            <el-button
              @click="resetForm"
              class="reset-btn"
              size="large"
            >
              <el-icon><RefreshLeft /></el-icon>
              重置
            </el-button>

            <el-button
              @click="cancel"
              class="cancel-btn"
              size="large"
            >
              <el-icon><Close /></el-icon>
              取消
            </el-button>
          </div>
        </el-form>
      </div>
    </div>
  </div>
</template>

<style lang="less" scoped>
/* 现代化个人设置页面样式 */
.modern-manager-settings {
  padding: 24px;
  background: var(--bg-primary);
  min-height: 100vh;
}

/* 页面标题 */
.page-header {
  margin-bottom: 32px;

  .header-content {
    text-align: center;

    .page-title {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 12px;
      font-size: 28px;
      font-weight: 700;
      color: var(--text-primary);
      margin-bottom: 8px;

      .title-icon {
        background: var(--gradient-warning);
        padding: 8px;
        border-radius: var(--radius-md);
        color: white;
      }
    }

    .page-subtitle {
      font-size: 14px;
      color: var(--text-secondary);
      margin: 0;
    }
  }
}

/* 设置容器 */
.settings-container {
  display: grid;
  grid-template-columns: 300px 1fr;
  gap: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

/* 用户信息卡片 */
.user-info-card {
  padding: 24px;
  height: fit-content;

  .card-header {
    margin-bottom: 24px;

    .card-title {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 16px;
      font-weight: 600;
      color: var(--text-primary);
      margin: 0;
    }
  }

  .user-info-content {
    text-align: center;

    .user-avatar {
      margin-bottom: 20px;

      .avatar-placeholder {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        background: var(--gradient-warning);
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto;
        color: white;
        box-shadow: var(--shadow-glass);
      }
    }

    .user-details {
      .user-name {
        font-size: 20px;
        font-weight: 600;
        color: var(--text-primary);
        margin: 0 0 8px 0;
      }

      .user-role {
        font-size: 14px;
        color: var(--text-secondary);
        margin: 0 0 12px 0;
      }

      .user-status {
        margin: 0;
      }
    }
  }
}

/* 设置表单卡片 */
.settings-form-card {
  padding: 24px;

  .card-header {
    margin-bottom: 32px;

    .card-title {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 18px;
      font-weight: 600;
      color: var(--text-primary);
      margin: 0;
    }
  }

  .modern-form {
    .form-section {
      margin-bottom: 32px;

      .section-title {
        font-size: 16px;
        font-weight: 600;
        color: var(--text-primary);
        margin: 0 0 20px 0;
        padding-bottom: 8px;
        border-bottom: var(--border-glass);
      }

      .el-form-item {
        margin-bottom: 24px;

        .modern-input {
          :deep(.el-input__wrapper) {
            background: var(--bg-glass);
            border: var(--border-glass);
            border-radius: var(--radius-sm);
            transition: var(--transition-smooth);

            &:hover {
              border-color: rgba(250, 173, 20, 0.5);
            }

            &.is-focus {
              border-color: #faad14;
              box-shadow: 0 0 0 2px rgba(250, 173, 20, 0.2);
            }
          }

          :deep(.el-input__inner) {
            color: var(--text-primary);

            &::placeholder {
              color: var(--text-muted);
            }
          }

          :deep(.el-input__prefix) {
            color: var(--text-muted);
          }
        }
      }
    }

    .form-actions {
      display: flex;
      gap: 16px;
      justify-content: center;
      padding-top: 24px;
      border-top: var(--border-glass);

      .submit-btn {
        background: var(--gradient-warning);
        border: none;
        min-width: 120px;

        &:hover {
          background: var(--gradient-accent);
          transform: translateY(-2px);
          box-shadow: 0 8px 25px rgba(250, 173, 20, 0.4);
        }
      }

      .reset-btn,
      .cancel-btn {
        background: var(--bg-glass);
        border: var(--border-glass);
        color: var(--text-secondary);
        min-width: 100px;

        &:hover {
          background: var(--bg-glass-hover);
          color: var(--text-primary);
          transform: translateY(-1px);
        }
      }
    }
  }
}

/* 响应式设计 */
@media (max-width: 1024px) {
  .settings-container {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .user-info-card {
    .user-info-content {
      display: flex;
      align-items: center;
      gap: 20px;
      text-align: left;

      .user-avatar .avatar-placeholder {
        width: 60px;
        height: 60px;
      }
    }
  }
}

@media (max-width: 768px) {
  .modern-manager-settings {
    padding: 16px;
  }

  .settings-form-card {
    padding: 16px;

    .modern-form .form-actions {
      flex-direction: column;

      .submit-btn,
      .reset-btn,
      .cancel-btn {
        width: 100%;
      }
    }
  }

  .page-header .header-content .page-title {
    font-size: 24px;
  }

  .user-info-card {
    padding: 16px;

    .user-info-content {
      flex-direction: column;
      text-align: center;
    }
  }
}
</style>

<!-- 全局样式覆盖 -->
<style>
.modern-form .el-form-item__label {
  color: var(--text-secondary) !important;
  font-weight: 500 !important;
}

.modern-input .el-input__wrapper {
  background: var(--bg-glass) !important;
  border: var(--border-glass) !important;
  border-radius: var(--radius-sm) !important;
}

.modern-input .el-input__inner {
  color: var(--text-primary) !important;
}
</style>
