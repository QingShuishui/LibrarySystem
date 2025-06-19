<script setup lang="ts">

import { reactive, ref } from 'vue'
import { addReaderCategoryAPI, getReaderCategoryAPI, deleteReaderCategoryAPI } from '@/api/readerCategory'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'

// ------ .d.ts 属性类型接口 ------
interface ReaderCategoryDTO {
  name: string
  amount: number
  lendPeriod: string
  effectPeriod: string
  notes: string
}
interface ReaderCategory {
  id: number
  name: string
  keywords: string
  notes: string
}

// ------ 配置 ------
const dialogFormVisible = ref(false)
const formLabelWidth = '140px'
const isValidForm = ref()

// ------ 数据 ------
// dialog中的表单信息
const form = reactive<ReaderCategoryDTO>({
  name: '',
  amount: 0,
  lendPeriod: '',
  effectPeriod: '',
  notes: ''
})
// 当前页的分类列表
const readerCategoryList = ref<ReaderCategory[]>([])
// 带查询条件的分页参数
const pageData = reactive({
  page: 1,
  pageSize: 6,
  name: ''
})
const total = ref(0)
// 表单校验
const rules = {
  name: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  amount: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  lendPeriod: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  effectPeriod: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  notes: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ]
}

// ------ 方法 ------

// 页面初始化，就根据token去获取用户信息，才能实现如果没有token/token过期，刚开始就能够跳转到登录页
const init = async () => {
  // 参数解构再传进去，不用传total
  const { data: res } = await getReaderCategoryAPI(pageData)
  console.log(res)
  console.log('分类列表')
  console.log(res.data)
  readerCategoryList.value = res.data.records
  total.value = res.data.total
}

init()  // 页面初始化/分页查询，写在这里时的生命周期是beforecreated/created的时候

// 监听翻页和每页显示数量的变化
const handleCurrentChange = (val: number) => {
  pageData.page = val
  // 条件分页查询
  init()
}

const handleSizeChange = (val: number) => {
  pageData.pageSize = val
  // 条件分页查询
  init()
}

// 新增读者分类
const add_btn = async () => {
  try {
    const valid = await isValidForm.value.validate()
    if (valid) {
      const date = new Date(form.effectPeriod)
      // 将日期转换为年月日格式
      form.effectPeriod = date.getFullYear() + '-' +
        String(date.getMonth() + 1).padStart(2, '0') + '-' +
        String(date.getDate()).padStart(2, '0')
      console.log('要提交的表单信息', form)
      const { data: res } = await addReaderCategoryAPI(form)
      console.log("cnm!!!!" + res)
      if (res.code === 1) return false
      dialogFormVisible.value = false
      // 提示新增成功
      ElMessage({
        message: '新增读者分类成功！',
        type: 'success',
      })
      // 新增书籍后刷新页面，更新数据
      init()
    } else {
      console.log('error submit!');
      return false;
    }
  } catch (error) {
    console.error('An error occurred during form validation:', error);
  }
}

// 修改分类(路径传参，到update页面后，根据id查询分类信息，回显到表单中)
const router = useRouter()
const update_btn = (row: any) => {
  console.log('要修改的行数据')
  console.log(row)
  router.push({
    name: 'readerCategoryUpdate',
    query: {
      id: row.id
    }
  })
}

// 删除分类
const delete_btn = (row: any) => {
  console.log('要删除的行数据')
  console.log(row)
  ElMessageBox.confirm(
    '该操作会永久删除分类，是否继续？',
    'Warning',
    {
      confirmButtonText: 'OK',
      cancelButtonText: 'Cancel',
      type: 'warning',
    }
  )
    .then(async () => {
      console.log('要删除的行数据')
      console.log(row)
      await deleteReaderCategoryAPI(row.id)
      // 删除后刷新页面，更新数据
      init()
      ElMessage({
        type: 'success',
        message: '删除成功',
      })
    })
    .catch(() => {
      ElMessage({
        type: 'info',
        message: '取消删除',
      })
    })
}
</script>

<template>
  <!-- 现代化对话框 -->
  <el-dialog v-model="dialogFormVisible" title="添加读者分类" class="modern-dialog">
    <el-form :model="form" :rules="rules" ref="isValidForm" class="modern-form">
      <el-form-item label="分类名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入读者分类名称" class="modern-input" />
      </el-form-item>
      <el-form-item label="最大借书数量" prop="amount">
        <el-input-number
          v-model="form.amount"
          :min="1"
          :max="50"
          placeholder="请输入最大借书数量"
          class="modern-input"
          style="width: 100%"
        />
      </el-form-item>
      <el-form-item label="借书期限(天)" prop="lendPeriod">
        <el-input-number
          v-model="form.lendPeriod"
          :min="1"
          :max="365"
          placeholder="请输入借书期限"
          class="modern-input"
          style="width: 100%"
        />
      </el-form-item>
      <el-form-item label="有效期" prop="effectPeriod">
        <el-date-picker
          v-model="form.effectPeriod"
          type="date"
          placeholder="请选择有效期"
          class="modern-input"
          style="width: 100%"
        />
      </el-form-item>
      <el-form-item label="备注" prop="notes">
        <el-input
          v-model="form.notes"
          type="textarea"
          :rows="3"
          placeholder="请输入备注信息"
          class="modern-input"
        />
      </el-form-item>
    </el-form>
    <template #footer>
      <div class="dialog-footer">
        <el-button @click="dialogFormVisible = false" class="cancel-btn">取消</el-button>
        <el-button type="primary" @click="add_btn()" class="confirm-btn">确认添加</el-button>
      </div>
    </template>
  </el-dialog>

  <div class="modern-reader-category-management">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <el-icon class="title-icon"><UserFilled /></el-icon>
          读者分类管理
        </h1>
        <p class="page-subtitle">管理读者分类信息，设置借阅权限和期限</p>
      </div>
    </div>

    <!-- 搜索和操作栏 -->
    <div class="search-toolbar modern-card">
      <div class="search-section">
        <div class="search-group">
          <label class="search-label">分类名</label>
          <el-input
            v-model="pageData.name"
            placeholder="请输入分类名"
            class="search-input"
            clearable
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>

        <el-button
          type="primary"
          class="search-btn"
          @click="init()"
        >
          <el-icon><Search /></el-icon>
          搜索
        </el-button>
      </div>

      <div class="action-section">
        <el-button
          type="primary"
          class="action-btn primary"
          @click="dialogFormVisible = true"
        >
          <el-icon><Plus /></el-icon>
          新增分类
        </el-button>
      </div>
    </div>

    <!-- 现代化表格 -->
    <div class="table-container modern-card">
      <div class="table-header">
        <div class="table-info">
          <span class="table-title">读者分类列表</span>
          <span class="table-count">共 {{ total }} 条记录</span>
        </div>
        <div class="table-actions">
          <el-button size="small" @click="init()">
            <el-icon><Refresh /></el-icon>
          </el-button>
        </div>
      </div>

      <el-table
        :data="readerCategoryList"
        class="modern-table"
        :header-cell-style="{
          background: 'var(--bg-secondary)',
          color: 'var(--text-primary)',
          borderColor: 'var(--border-glass)'
        }"
        :cell-style="{
          borderColor: 'var(--border-glass)',
          background: 'transparent'
        }"
      >
        <el-table-column prop="id" label="ID" width="80" />

        <el-table-column prop="name" label="分类名" min-width="150">
          <template #default="scope">
            <div class="category-name">
              <el-icon class="category-icon"><UserFilled /></el-icon>
              <span>{{ scope.row.name }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column prop="amount" label="最大借书数" width="120">
          <template #default="scope">
            <el-tag type="primary" effect="dark" size="small">
              {{ scope.row.amount }} 本
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="lendPeriod" label="借书期限" width="120">
          <template #default="scope">
            <el-tag type="success" effect="dark" size="small">
              {{ scope.row.lendPeriod }} 天
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="effectPeriod" label="有效期" width="120">
          <template #default="scope">
            <span class="date-text">{{ scope.row.effectPeriod }}</span>
          </template>
        </el-table-column>

        <el-table-column prop="notes" label="备注" min-width="200" show-overflow-tooltip />

        <el-table-column label="操作" width="180" fixed="right">
          <template #default="scope">
            <div class="action-buttons">
              <el-button
                size="small"
                type="primary"
                @click="update_btn(scope.row)"
                class="action-btn-small"
              >
                <el-icon><Edit /></el-icon>
                编辑
              </el-button>

              <el-button
                size="small"
                type="danger"
                @click="delete_btn(scope.row)"
                class="action-btn-small"
              >
                <el-icon><Delete /></el-icon>
                删除
              </el-button>
            </div>
          </template>
        </el-table-column>

        <template #empty>
          <div class="empty-state">
            <el-icon size="64" class="empty-icon"><UserFilled /></el-icon>
            <p class="empty-text">暂无读者分类数据</p>
            <el-button type="primary" @click="dialogFormVisible = true">
              <el-icon><Plus /></el-icon>
              添加第一个分类
            </el-button>
          </div>
        </template>
      </el-table>
    </div>

    <!-- 现代化分页 -->
    <div class="pagination-container">
      <el-pagination
        v-model:current-page="pageData.page"
        v-model:page-size="pageData.pageSize"
        :page-sizes="[10, 20, 50, 100]"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
        background
        class="modern-pagination"
        @current-change="handleCurrentChange"
        @size-change="handleSizeChange"
      />
    </div>
  </div>
</template>


<style lang="less" scoped>
/* 现代化读者分类管理页面样式 */
.modern-reader-category-management {
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
        background: var(--gradient-secondary);
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

/* 搜索工具栏 */
.search-toolbar {
  padding: 24px;
  margin-bottom: 24px;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 24px;
  flex-wrap: wrap;

  .search-section {
    display: flex;
    gap: 20px;
    align-items: flex-end;
    flex-wrap: wrap;
    flex: 1;

    .search-group {
      display: flex;
      flex-direction: column;
      gap: 8px;
      min-width: 160px;

      .search-label {
        font-size: 12px;
        color: var(--text-secondary);
        font-weight: 500;
      }

      .search-input {
        :deep(.el-input__wrapper) {
          background: var(--bg-glass);
          border: var(--border-glass);
          border-radius: var(--radius-sm);
          transition: var(--transition-smooth);

          &:hover {
            border-color: rgba(240, 147, 251, 0.5);
          }

          &.is-focus {
            border-color: #f093fb;
            box-shadow: 0 0 0 2px rgba(240, 147, 251, 0.2);
          }
        }

        :deep(.el-input__inner) {
          color: var(--text-primary);

          &::placeholder {
            color: var(--text-muted);
          }
        }
      }
    }

    .search-btn {
      height: 40px;
      padding: 0 20px;
      background: var(--gradient-secondary);
      border: none;
      border-radius: var(--radius-sm);

      &:hover {
        background: var(--gradient-warning);
        transform: translateY(-1px);
      }
    }
  }

  .action-section {
    display: flex;
    gap: 12px;

    .action-btn {
      height: 40px;
      padding: 0 20px;
      border-radius: var(--radius-sm);
      font-weight: 500;
      transition: var(--transition-smooth);

      &.primary {
        background: var(--gradient-secondary);
        border: none;

        &:hover {
          background: var(--gradient-warning);
          transform: translateY(-1px);
          box-shadow: 0 4px 12px rgba(240, 147, 251, 0.4);
        }
      }
    }
  }
}

/* 表格容器 */
.table-container {
  padding: 0;
  overflow: hidden;
  margin-bottom: 24px;

  .table-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 24px;
    border-bottom: var(--border-glass);

    .table-info {
      display: flex;
      align-items: center;
      gap: 16px;

      .table-title {
        font-size: 16px;
        font-weight: 600;
        color: var(--text-primary);
      }

      .table-count {
        font-size: 12px;
        color: var(--text-secondary);
        background: var(--bg-glass);
        padding: 4px 8px;
        border-radius: var(--radius-sm);
      }
    }

    .table-actions {
      display: flex;
      gap: 8px;
    }
  }

  .modern-table {
    background: transparent;

    :deep(.el-table__header) {
      background: var(--bg-secondary);
    }

    :deep(.el-table__row) {
      background: transparent;

      &:hover {
        background: var(--bg-glass) !important;
      }
    }

    :deep(.el-table__cell) {
      border-color: var(--border-glass);
      color: var(--text-primary);
    }

    .category-name {
      display: flex;
      align-items: center;
      gap: 8px;

      .category-icon {
        color: #f093fb;
      }
    }

    .date-text {
      color: var(--text-accent);
      font-weight: 500;
    }

    .action-buttons {
      display: flex;
      gap: 8px;

      .action-btn-small {
        padding: 4px 8px;
        font-size: 12px;
        border-radius: var(--radius-sm);
      }
    }

    .empty-state {
      padding: 60px 20px;
      text-align: center;

      .empty-icon {
        color: var(--text-muted);
        margin-bottom: 16px;
      }

      .empty-text {
        color: var(--text-secondary);
        font-size: 16px;
        margin-bottom: 20px;
      }
    }
  }
}

/* 分页容器 */
.pagination-container {
  display: flex;
  justify-content: center;
  padding: 20px 0;

  .modern-pagination {
    :deep(.el-pagination__total),
    :deep(.el-pagination__sizes),
    :deep(.el-pagination__jump) {
      color: var(--text-secondary);
    }

    :deep(.el-pager li) {
      background: var(--bg-glass);
      border: var(--border-glass);
      color: var(--text-secondary);

      &:hover {
        background: var(--bg-glass-hover);
        color: var(--text-primary);
      }

      &.is-active {
        background: var(--gradient-secondary);
        color: white;
      }
    }

    :deep(.btn-prev),
    :deep(.btn-next) {
      background: var(--bg-glass);
      border: var(--border-glass);
      color: var(--text-secondary);

      &:hover {
        background: var(--bg-glass-hover);
        color: var(--text-primary);
      }
    }
  }
}

/* 对话框样式 */
.dialog-footer {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin: 20px 0;

  .cancel-btn,
  .confirm-btn {
    min-width: 120px;
    border-radius: var(--radius-sm);
  }

  .confirm-btn {
    background: var(--gradient-secondary);
    border: none;

    &:hover {
      background: var(--gradient-warning);
    }
  }
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .search-toolbar {
    flex-direction: column;
    align-items: stretch;

    .search-section {
      justify-content: flex-start;
    }

    .action-section {
      justify-content: flex-end;
    }
  }
}

@media (max-width: 768px) {
  .modern-reader-category-management {
    padding: 16px;
  }

  .search-toolbar {
    padding: 16px;

    .search-section {
      flex-direction: column;
      gap: 16px;

      .search-group {
        min-width: auto;
      }
    }

    .action-section {
      flex-direction: column;

      .action-btn {
        width: 100%;
      }
    }
  }

  .table-container {
    .table-header {
      padding: 16px;
      flex-direction: column;
      gap: 12px;
      align-items: flex-start;
    }
  }

  .page-header .header-content .page-title {
    font-size: 24px;
  }
}
</style>

<!-- 全局样式覆盖 -->
<style>
.modern-dialog {
  background: var(--bg-secondary) !important;
  border: var(--border-glass) !important;
  border-radius: var(--radius-lg) !important;
  box-shadow: var(--shadow-glass) !important;
}

.modern-dialog .el-dialog__header {
  background: var(--bg-tertiary) !important;
  border-bottom: var(--border-glass) !important;
  padding: 20px 24px !important;
}

.modern-dialog .el-dialog__title {
  color: var(--text-primary) !important;
  font-weight: 600 !important;
}

.modern-dialog .el-dialog__body {
  padding: 24px !important;
}

.modern-form .el-form-item__label {
  color: var(--text-secondary) !important;
}

.modern-input .el-input__wrapper,
.modern-input .el-textarea__inner,
.modern-input .el-input-number__wrapper {
  background: var(--bg-glass) !important;
  border: var(--border-glass) !important;
  border-radius: var(--radius-sm) !important;
  color: var(--text-primary) !important;
}

.modern-input .el-input__inner,
.modern-input .el-textarea__inner,
.modern-input .el-input-number__inner {
  color: var(--text-primary) !important;
}

.modern-input .el-date-editor .el-input__wrapper {
  background: var(--bg-glass) !important;
  border: var(--border-glass) !important;
}
</style>
