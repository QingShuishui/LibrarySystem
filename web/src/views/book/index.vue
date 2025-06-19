<script setup lang="ts">
import { reactive, ref } from 'vue'
import { getBookCategoryAPI } from '@/api/bookCategory'
import { getBookPageAPI, addBookAPI, updateBookStatusAPI, deleteBooksAPI } from '@/api/book'
import { useRouter } from 'vue-router';
import { ElMessage, ElMessageBox, ElTable } from 'element-plus'

// ------ .d.ts 属性类型接口 ------
// 接收到不在接口中定义的属性的数据，ts会报错，但是类型推断错误不会妨碍接收，控制台还是能打印的
interface Book {
  id: number
  name: string
  categoryId: number
  author: string
  press: string
  publishDate: string
  price: number
  pageNumber: number
  keywords: string
  createTime: string
  status: number
  notes: string
}
interface BookDTO {
  name: string
  categoryId: number
  author: string
  press: string
  publishDate: string
  price: number
  pageNumber: number
  keywords: string
  notes: string
}
interface Category {
  id: number
  name: string
}

// ------ 配置 ------
const dialogFormVisible = ref(false)
const formLabelWidth = '140px'

// ------ 数据 ------
// dialog中的表单信息
const form = reactive<BookDTO>({
  name: '',
  categoryId: 1,
  author: '',
  press: '',
  publishDate: '',
  price: 0,
  pageNumber: 0,
  keywords: '',
  notes: ''
})
// 当前页的书籍列表
const bookList = ref<Book[]>([])
// 书籍id对应的分类列表，即categoryId字段不能只展示id值，应该根据id查询到对应的分类名进行回显
const categoryList = ref<Category[]>([])
// 分页参数
const pageData = reactive({
  name: '',
  categoryId: '',
  status: '',
  page: 1,
  pageSize: 20,
})

// 辅助方法
const getCategoryTagType = (categoryId: number) => {
  const types = ['primary', 'success', 'info', 'warning', 'danger']
  return types[categoryId % types.length]
}
// // 输入框：模糊查询的关键词
// const input = ref()
// const inputRef = ref<HTMLInputElement | null>(null)
const isValidForm = ref()
const total = ref(0)
const options = [
  {
    value: '1',
    label: '已借出',
  },
  {
    value: '0',
    label: '未借出',
  }
]
const multiTableRef = ref<InstanceType<typeof ElTable>>()
const multiSelection = ref<Book[]>([])

// 表单校验
const rules = {
  name: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  categoryId: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  author: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  press: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  publishDate: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  price: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  pageNumber: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  keywords: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  notes: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ]
}

// ------ 方法 ------
// 页面初始化: 获取书籍分类列表
const init = async () => {
  const { data: res_category } = await getBookCategoryAPI({ page: 1, pageSize: 100 })
  console.log('分类列表')
  console.log(res_category.data)
  categoryList.value = res_category.data.records
  console.log('categoryList: ', categoryList.value)
}
// 刷新页面的分页数据
const showPageList = async () => {
  const { data: res } = await getBookPageAPI(pageData)
  console.log('书籍列表')
  console.log(res.data)
  bookList.value = res.data.records
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
const handleSelectionChange = (val: Book[]) => {
  multiSelection.value = val
  console.log('value', val)
  console.log('multiSelection.value', multiSelection.value)
}

// 新增书籍
const add_btn = async () => {
  try {
    const valid = await isValidForm.value.validate()
    if (valid) {
      const date = new Date(form.publishDate)
      // 将日期转换为年月日格式(不能换行，空格和\n会被算进去...)
      form.publishDate = date.getFullYear() + '-' +
        String(date.getMonth() + 1).padStart(2, '0') + '-' +
        String(date.getDate()).padStart(2, '0')
      console.log('要提交的表单信息', form)
      const { data: res } = await addBookAPI(form)
      if (res.code == 1) return false
      console.log(res)
      dialogFormVisible.value = false
      // 提示新增成功
      ElMessage({
        message: '新增书籍成功！',
        type: 'success',
      })
      // 新增书籍后刷新页面，更新数据
      showPageList()
    } else {
      console.log('error submit!')
      return false;
    }
  } catch (error) {
    console.error('An error occurred during form validation:', error)
  }
}

// 模糊查询书籍列表
const search_btn = async () => {
  console.log('查询书籍的条件')
  console.log(pageData)
  let res = await getBookPageAPI(pageData)
  // 删除后刷新页面，更新数据
  console.log(res)
  bookList.value = res.data.data.records
  total.value = res.data.data.total
  showPageList()
}

// 修改书籍(路径传参，到update页面后，根据id查询书籍信息，回显到表单中)
const router = useRouter()
const update_btn = (row: any) => {
  console.log('要修改的行数据')
  console.log(row)
  router.push({
    name: 'bookUpdate',
    query: {
      id: row.id
    }
  })
}

// 修改书籍状态
const change_btn = async (row: any) => {
  console.log('要修改的行数据')
  console.log(row)
  await updateBookStatusAPI(row.id)
  // 修改后刷新页面，更新数据
  showPageList()
  ElMessage({
    type: 'success',
    message: '修改成功',
  })
}

// 删除书籍
const delete_btn = async (row: any) => {
  ElMessageBox.confirm(
    '是否删除该书籍？',
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
      await deleteBooksAPI(row.id)
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
// 批量删除书籍
const deleteBatch = (row?: any) => {
  console.log('要删除的行数据')
  console.log(row)
  ElMessageBox.confirm(
    '是否批量删除选中的书籍？',
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
            message: '请先选择要删除的书籍',
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
        let res = await deleteBooksAPI(ids)
        if (res.data.code != 0) return
      }
      // 2. 传入行数据，单个删除
      else {
        console.log('id包装成数组，然后调用批量删除接口')
        console.log(row.id)
        let res = await deleteBooksAPI(row.id)
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
  <el-dialog v-model="dialogFormVisible" title="添加图书" class="my-info-dialog">
    <el-form :model="form" :rules="rules" ref="isValidForm">
      <el-form-item label="书名" :label-width="formLabelWidth" prop="name">
        <el-input v-model="form.name" autocomplete="off" />
      </el-form-item>
      <el-form-item label="分类" :label-width="formLabelWidth" prop="categoryId">
        <el-select clearable v-model="form.categoryId" placeholder="选择分类类型">
          <el-option v-for="item in categoryList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="作者" :label-width="formLabelWidth" prop="author">
        <el-input v-model="form.author" autocomplete="off" />
      </el-form-item>
      <el-form-item label="出版社" :label-width="formLabelWidth" prop="press">
        <el-input v-model="form.press" autocomplete="off" />
      </el-form-item>
      <el-form-item label="出版日期" :label-width="formLabelWidth" prop="publishDate">
        <el-date-picker v-model="form.publishDate" type="date" placeholder="请选择出版日期" style="width: 100%" />
      </el-form-item>
      <el-form-item label="价格" :label-width="formLabelWidth" prop="price">
        <el-input v-model="form.price" autocomplete="off" />
      </el-form-item>
      <el-form-item label="页码数" :label-width="formLabelWidth" prop="pageNumber">
        <el-input v-model="form.pageNumber" autocomplete="off" />
      </el-form-item>
      <el-form-item label="关键词" :label-width="formLabelWidth" prop="keywords">
        <el-input v-model="form.keywords" autocomplete="off" />
      </el-form-item>
      <el-form-item label="备注" :label-width="formLabelWidth" prop="notes">
        <el-input v-model="form.notes" autocomplete="off" />
      </el-form-item>
    </el-form>
    <template #footer>
      <div class="dialog-footer">
        <el-button plain type="info" @click="dialogFormVisible = false">取消</el-button>
        <el-button type="primary" @click="add_btn()">确认</el-button>
      </div>
    </template>
  </el-dialog>

  <div class="modern-book-management">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <el-icon class="title-icon"><Reading /></el-icon>
          图书管理
        </h1>
        <p class="page-subtitle">管理图书信息，包括新增、编辑、删除等操作</p>
      </div>
    </div>

    <!-- 搜索和操作栏 -->
    <div class="search-toolbar modern-card">
      <div class="search-section">
        <div class="search-group">
          <label class="search-label">书名</label>
          <el-input
            v-model="pageData.name"
            placeholder="请输入书名"
            class="search-input"
            clearable
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>

        <div class="search-group">
          <label class="search-label">分类</label>
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

        <div class="search-group">
          <label class="search-label">状态</label>
          <el-select
            v-model="pageData.status"
            placeholder="选择状态"
            class="search-select"
            clearable
          >
            <el-option
              v-for="item in options"
              :key="item.value"
              :label="item.label"
              :value="item.value"
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
          新增图书
        </el-button>
      </div>
    </div>

    <!-- 现代化表格 -->
    <div class="table-container modern-card">
      <div class="table-header">
        <div class="table-info">
          <span class="table-title">图书列表</span>
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
        :data="bookList"
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

        <el-table-column prop="id" label="书号" width="80" />

        <el-table-column prop="name" label="书名" min-width="150" show-overflow-tooltip>
          <template #default="scope">
            <div class="book-name">
              <el-icon class="book-icon"><Reading /></el-icon>
              <span>{{ scope.row.name }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column prop="categoryId" label="分类" width="120">
          <template #default="scope">
            <el-tag
              :type="getCategoryTagType(scope.row.categoryId)"
              size="small"
              effect="dark"
            >
              {{ categoryList.find(item => item.id === scope.row.categoryId)?.name || '未知' }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="author" label="作者" width="120" show-overflow-tooltip />

        <el-table-column prop="press" label="出版社" width="150" show-overflow-tooltip />

        <el-table-column prop="publishDate" label="出版日期" width="120" />

        <el-table-column prop="price" label="价格" width="80">
          <template #default="scope">
            <span class="price-text">¥{{ scope.row.price }}</span>
          </template>
        </el-table-column>

        <el-table-column prop="pageNumber" label="页数" width="80" />

        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag
              :type="scope.row.status === 1 ? 'danger' : 'success'"
              size="small"
              effect="dark"
            >
              {{ scope.row.status === 1 ? '已借出' : '可借阅' }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="createTime" label="创建时间" width="160" />

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
            <el-icon size="64" class="empty-icon"><Reading /></el-icon>
            <p class="empty-text">暂无图书数据</p>
            <el-button type="primary" @click="dialogFormVisible = true">
              <el-icon><Plus /></el-icon>
              添加第一本图书
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
/* 现代化图书管理页面样式 */
.modern-book-management {
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
        background: var(--gradient-primary);
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
      background: var(--gradient-primary);
      border: none;
      border-radius: var(--radius-sm);

      &:hover {
        background: var(--gradient-accent);
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
        background: var(--gradient-success);
        border: none;

        &:hover {
          background: var(--gradient-accent);
          transform: translateY(-1px);
          box-shadow: 0 4px 12px rgba(67, 233, 123, 0.4);
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

    .book-name {
      display: flex;
      align-items: center;
      gap: 8px;

      .book-icon {
        color: var(--text-accent);
      }
    }

    .price-text {
      font-weight: 600;
      color: var(--text-accent);
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
        background: var(--gradient-primary);
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

  .el-button {
    min-width: 120px;
    border-radius: var(--radius-sm);
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
  .modern-book-management {
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
.el-dialog {
  background: var(--bg-secondary) !important;
  border: var(--border-glass) !important;
  border-radius: var(--radius-lg) !important;
  box-shadow: var(--shadow-glass) !important;
}

.el-dialog__header {
  background: var(--bg-tertiary) !important;
  border-bottom: var(--border-glass) !important;
  padding: 20px 24px !important;
}

.el-dialog__title {
  color: var(--text-primary) !important;
  font-weight: 600 !important;
}

.el-dialog__body {
  padding: 24px !important;
  max-height: 60vh !important;
  overflow-y: auto !important;
}

.el-form-item__label {
  color: var(--text-secondary) !important;
}

.el-input__wrapper {
  background: var(--bg-glass) !important;
  border: var(--border-glass) !important;
  border-radius: var(--radius-sm) !important;
}

.el-input__inner {
  color: var(--text-primary) !important;
}

.el-select__wrapper {
  background: var(--bg-glass) !important;
  border: var(--border-glass) !important;
  border-radius: var(--radius-sm) !important;
}

.el-date-editor .el-input__wrapper {
  background: var(--bg-glass) !important;
  border: var(--border-glass) !important;
}
</style>