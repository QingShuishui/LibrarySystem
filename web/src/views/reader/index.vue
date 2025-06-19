<script setup lang="ts">
import { reactive, ref } from 'vue'
import { getReaderCategoryAPI } from '@/api/readerCategory'
import { getReaderPageAPI, addReaderAPI, deleteReadersAPI } from '@/api/reader'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox, ElTable } from 'element-plus'

// ------ .d.ts 属性类型接口 ------
// 接收到不在接口中定义的属性的数据，ts会报错，但是类型推断错误不会妨碍接收，控制台还是能打印的
interface Reader {
  id: number
  name: string
  categoryId: number
  sex: number
  wAddress: string
  hAddress: string
  phone: string
  email: string
  createTime: string
  notes: string
}
interface ReaderDTO {
  name: string
  categoryId: number
  sex: number
  wAddress: string
  hAddress: string
  phone: string
  email: string
  notes: string
}
interface Category {
  id: number
  name: string
}

// 配置
const dialogFormVisible = ref(false)
const formLabelWidth = '140px'

// ------ 数据 ------
// dialog中的表单信息
const form = reactive<ReaderDTO>({
  name: '',
  categoryId: 1,
  sex: 1,
  wAddress: '',
  hAddress: '',
  phone: '',
  email: '',
  notes: '',
})
// 当前页的书籍列表
const readerList = ref<Reader[]>([])
// 书籍id对应的分类列表，即categoryId字段不能只展示id值，应该根据id查询到对应的分类名进行回显
const categoryList = ref<Category[]>([])
// 分页参数
const pageData = reactive({
  name: '',
  categoryId: '',
  status: '',
  page: 1,
  pageSize: 6,
})
// 性别列表
const sexList = [
  {
    id: 1,
    name: '男',
  },
  {
    id: 0,
    name: '女',
  }
]

const isValidForm = ref()
const total = ref(0)
const multiTableRef = ref<InstanceType<typeof ElTable>>()
const multiSelection = ref<Reader[]>([])

// 表单校验
const rules = {
  name: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  categoryId: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  sex: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  wAddress: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  hAddress: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  phone: [
    { required: true, trigger: 'blur', message: '不能为空' },
    { pattern: /^[1][3-9][0-9]{9}$/, message: '请输入正确的手机号格式', trigger: 'blur' },
  ],
  email: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  notes: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ]
}

// 初始化时拿到分类列表，得到 id-name 对应关系
const init = async () => {
  const { data: res_category } = await getReaderCategoryAPI({ page: 1, pageSize: 100 })   // 分页加载员工
  console.log(res_category)
  categoryList.value = res_category.data.records
  console.log('categoryList: ', categoryList.value)
}
// 刷新页面的分页数据
const showPageList = async () => {
  console.log('根据该条件获取分页书籍列表', pageData)
  const { data: res } = await getReaderPageAPI(pageData)
  readerList.value = res.data.records
  console.log('书籍列表', readerList.value)
  total.value = res.data.total
}
init() // 页面初始化，写在这里时的生命周期是beforecreated/created的时候
showPageList() // 页面一开始就要展示分页书籍列表

const handleCurrentChange = (val: any) => {
  console.log(`当前页: ${val}`)
  showPageList()
}
const handleSizeChange = (val: any) => {
  console.log(`每页 ${val} 条`)
  showPageList()
}
const handleSelectionChange = (val: Reader[]) => {
  multiSelection.value = val
  console.log('value', val)
  console.log('multiSelection.value', multiSelection.value)
}

// 新增借阅人
const add_btn = async () => {
  try {
    const valid = await isValidForm.value.validate()
    if (valid) {
      dialogFormVisible.value = false
      const { data: res } = await addReaderAPI(form)
      if (res.code == 1) return false
      console.log(res)
      // 提示新增成功
      ElMessage({
        message: '新增借阅人成功！',
        type: 'success',
      })
      // 新增借阅人后刷新页面，更新数据
      showPageList()
    } else {
      console.log('error submit!')
      return false;
    }
  } catch (error) {
    console.error('An error occurred during form validation:', error)
  }
}

// 模糊查询读者列表
const search_btn = async () => {
  console.log('查询书籍的条件')
  console.log(pageData)
  const { data: res } = await getReaderPageAPI(pageData)
  // 删除后刷新页面，更新数据
  console.log(res)
  readerList.value = res.data.records
  total.value = res.data.total
  showPageList()
}

// 修改借阅人(路径传参，到update页面后，根据id查询借阅人信息，回显到表单中)
const router = useRouter()
const update_btn = (row: any) => {
  console.log('要修改的行数据')
  console.log(row)
  router.push({
    name: 'readerUpdate',
    query: {
      id: row.id
    }
  })
}

// 删除借阅人
const delete_btn = async (row: any) => {
  ElMessageBox.confirm(
    '是否删除该借阅人？',
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
      await deleteReadersAPI(row.id)
      // 删除后刷新页面，更新数据
      showPageList()
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

// 批量删除借阅人
const deleteBatch = (row?: any) => {
  console.log('要删除的行数据')
  console.log(row)
  ElMessageBox.confirm(
    '是否批量删除选中的读者？',
    'Warning',
    {
      confirmButtonText: 'OK',
      cancelButtonText: 'Cancel',
      type: 'warning',
    }
  )
    .then(async () => {
      // 1. 没传入行数据，批量删除
      if (row == undefined) {
        console.log(multiSelection.value)
        if (multiSelection.value.length == 0) {
          ElMessage({
            type: 'warning',
            message: '请先选择要删除的读者',
          })
          return
        }
        // 拿到当前 multiSelection.value 的所有id，然后调用批量删除接口
        let ids: any = []
        multiSelection.value.map(item => {
          ids.push(item.id)
        })
        ids = ids.join(',')
        console.log('ids', ids)
        let res = await deleteReadersAPI(ids)
        if (res.data.code != 0) return
      }
      // 2. 传入行数据，单个删除
      else {
        console.log('id包装成数组，然后调用批量删除接口')
        console.log(row.id)
        let res = await deleteReadersAPI(row.id)
        if (res.data.code != 0) return
      }
      // 删除后刷新页面，更新数据
      showPageList()
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
  <el-dialog v-model="dialogFormVisible" title="添加读者" class="modern-dialog" width="600px">
    <el-form :model="form" :rules="rules" ref="isValidForm" class="modern-form" label-width="100px">
      <div class="form-grid">
        <el-form-item label="姓名" prop="name">
          <el-input v-model="form.name" placeholder="请输入读者姓名" class="modern-input" />
        </el-form-item>

        <el-form-item label="读者分类" prop="categoryId">
          <el-select v-model="form.categoryId" placeholder="选择读者分类" class="modern-input" style="width: 100%">
            <el-option v-for="item in categoryList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>

        <el-form-item label="性别" prop="sex">
          <el-select v-model="form.sex" placeholder="选择性别" class="modern-input" style="width: 100%">
            <el-option v-for="item in sexList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>

        <el-form-item label="手机号" prop="phone">
          <el-input v-model="form.phone" placeholder="请输入手机号" class="modern-input" />
        </el-form-item>

        <el-form-item label="邮箱" prop="email" class="full-width">
          <el-input v-model="form.email" placeholder="请输入邮箱地址" class="modern-input" />
        </el-form-item>

        <el-form-item label="工作单位" prop="wAddress" class="full-width">
          <el-input v-model="form.wAddress" placeholder="请输入工作单位" class="modern-input" />
        </el-form-item>

        <el-form-item label="家庭住址" prop="hAddress" class="full-width">
          <el-input v-model="form.hAddress" placeholder="请输入家庭住址" class="modern-input" />
        </el-form-item>

        <el-form-item label="备注" prop="notes" class="full-width">
          <el-input
            v-model="form.notes"
            type="textarea"
            :rows="3"
            placeholder="请输入备注信息"
            class="modern-input"
          />
        </el-form-item>
      </div>
    </el-form>
    <template #footer>
      <div class="dialog-footer">
        <el-button @click="dialogFormVisible = false" class="cancel-btn">取消</el-button>
        <el-button type="primary" @click="add_btn()" class="confirm-btn">确认添加</el-button>
      </div>
    </template>
  </el-dialog>

  <div class="modern-reader-management">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <el-icon class="title-icon"><Avatar /></el-icon>
          读者管理
        </h1>
        <p class="page-subtitle">管理读者信息，包括新增、编辑、删除等操作</p>
      </div>
    </div>

    <!-- 搜索和操作栏 -->
    <div class="search-toolbar modern-card">
      <div class="search-section">
        <div class="search-group">
          <label class="search-label">读者姓名</label>
          <el-input
            v-model="pageData.name"
            placeholder="请输入读者姓名"
            class="search-input"
            clearable
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>

        <div class="search-group">
          <label class="search-label">读者分类</label>
          <el-select
            v-model="pageData.categoryId"
            placeholder="选择分类"
            class="search-select"
            clearable
          >
            <el-option
              v-for="item in categoryList"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </div>

        <el-button
          type="primary"
          class="search-btn"
          @click="search_btn()"
        >
          <el-icon><Search /></el-icon>
          搜索
        </el-button>
      </div>

      <div class="action-section">
        <el-button
          type="danger"
          class="action-btn"
          @click="deleteBatch()"
          :disabled="multiSelection.length === 0"
        >
          <el-icon><Delete /></el-icon>
          批量删除
        </el-button>

        <el-button
          type="primary"
          class="action-btn primary"
          @click="dialogFormVisible = true"
        >
          <el-icon><Plus /></el-icon>
          新增读者
        </el-button>
      </div>
    </div>

    <!-- 现代化表格 -->
    <div class="table-container modern-card">
      <div class="table-header">
        <div class="table-info">
          <span class="table-title">读者列表</span>
          <span class="table-count">共 {{ total }} 条记录</span>
        </div>
        <div class="table-actions">
          <el-button size="small" @click="showPageList()">
            <el-icon><Refresh /></el-icon>
          </el-button>
        </div>
      </div>

      <el-table
        ref="multiTableRef"
        :data="readerList"
        @selection-change="handleSelectionChange"
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
        <el-table-column type="selection" width="55" />

        <el-table-column prop="id" label="读者号" width="80" />

        <el-table-column prop="name" label="姓名" min-width="120">
          <template #default="scope">
            <div class="reader-name">
              <el-icon class="reader-icon"><Avatar /></el-icon>
              <span>{{ scope.row.name }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column prop="categoryId" label="分类" width="120">
          <template #default="scope">
            <el-tag
              type="primary"
              size="small"
              effect="dark"
            >
              {{ categoryList.find(item => item.id === scope.row.categoryId)?.name || '未知' }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="sex" label="性别" width="80">
          <template #default="scope">
            <el-tag
              :type="scope.row.sex === 1 ? 'info' : 'warning'"
              size="small"
              effect="dark"
            >
              {{ scope.row.sex === 1 ? '男' : '女' }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="phone" label="电话" width="130" />

        <el-table-column prop="email" label="邮箱" min-width="180" show-overflow-tooltip />

        <el-table-column prop="wAddress" label="工作单位" min-width="150" show-overflow-tooltip />

        <el-table-column prop="hAddress" label="家庭住址" min-width="150" show-overflow-tooltip />

        <el-table-column prop="createTime" label="创建时间" width="160" />

        <el-table-column prop="notes" label="备注" min-width="120" show-overflow-tooltip />

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
            <el-icon size="64" class="empty-icon"><Avatar /></el-icon>
            <p class="empty-text">暂无读者数据</p>
            <el-button type="primary" @click="dialogFormVisible = true">
              <el-icon><Plus /></el-icon>
              添加第一个读者
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
/* 现代化读者管理页面样式 */
.modern-reader-management {
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
        background: var(--gradient-accent);
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

      .search-input,
      .search-select {
        :deep(.el-input__wrapper),
        :deep(.el-select__wrapper) {
          background: var(--bg-glass);
          border: var(--border-glass);
          border-radius: var(--radius-sm);
          transition: var(--transition-smooth);

          &:hover {
            border-color: rgba(79, 172, 254, 0.5);
          }

          &.is-focus {
            border-color: var(--text-accent);
            box-shadow: 0 0 0 2px rgba(79, 172, 254, 0.2);
          }
        }

        :deep(.el-input__inner),
        :deep(.el-select__input) {
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
      background: var(--gradient-accent);
      border: none;
      border-radius: var(--radius-sm);

      &:hover {
        background: var(--gradient-primary);
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
        background: var(--gradient-accent);
        border: none;

        &:hover {
          background: var(--gradient-primary);
          transform: translateY(-1px);
          box-shadow: 0 4px 12px rgba(79, 172, 254, 0.4);
        }
      }

      &:not(.primary) {
        background: var(--bg-glass);
        border: var(--border-glass);
        color: var(--text-secondary);

        &:hover:not(:disabled) {
          background: var(--bg-glass-hover);
          color: var(--text-primary);
          transform: translateY(-1px);
        }

        &:disabled {
          opacity: 0.5;
          cursor: not-allowed;
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

    .reader-name {
      display: flex;
      align-items: center;
      gap: 8px;

      .reader-icon {
        color: var(--text-accent);
      }
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
        background: var(--gradient-accent);
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
.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;

  .full-width {
    grid-column: 1 / -1;
  }
}

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
    background: var(--gradient-accent);
    border: none;

    &:hover {
      background: var(--gradient-primary);
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

  .form-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .modern-reader-management {
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
.modern-input .el-select__wrapper {
  background: var(--bg-glass) !important;
  border: var(--border-glass) !important;
  border-radius: var(--radius-sm) !important;
  color: var(--text-primary) !important;
}

.modern-input .el-input__inner,
.modern-input .el-textarea__inner,
.modern-input .el-select__input {
  color: var(--text-primary) !important;
}
</style>
