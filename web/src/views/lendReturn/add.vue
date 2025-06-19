<script setup lang="ts">
import { reactive, ref } from 'vue'
import { getBookCategoryAPI } from '@/api/bookCategory'
import { getReaderCategoryAPI } from '@/api/readerCategory'
import { getBookPageAPI } from '@/api/book'
import { getReaderPageAPI } from '@/api/reader'
import { addBorrowAPI } from '@/api/lendReturn'
import { ElMessage, ElTable } from 'element-plus'

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
interface BookCategory {
  id: number
  name: string
}
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
interface ReaderCategory {
  id: number
  name: string
}
interface LendReturnDTO {
  rId: number
  bId: number
  lendDate: string
  returnDate: string
  status: number
  notes: string
}

// ------ 数据 ------
// 1、书籍
// 当前选择的书籍，防止未定义报错，要先给个初始值
const selectedBook = ref<Book>({
  id: 0,
  name: '',
  categoryId: 1,
  author: '',
  press: '',
  publishDate: '',
  price: 0,
  pageNumber: 0,
  keywords: '',
  createTime: '',
  status: 0,
  notes: ''
})
// 当前页的书籍列表
const bookList = ref<Book[]>([])
// 书籍id对应的分类列表，即categoryId字段不能只展示id值，应该根据id查询到对应的分类名进行回显
const bookCategoryList = ref<BookCategory[]>([])
// 书籍分页参数(只展示未借出的书籍)
const bookPageData = reactive({
  name: '',
  categoryId: '',
  status: 0,
  page: 1,
  pageSize: 6,
})
const bookTotal = ref(0)
const singleBookRef = ref<InstanceType<typeof ElTable>>()

// 2、读者
// 当前选择的读者，防止未定义报错，要先给个初始值
const selectedReader = ref<Reader>({
  id: 0,
  name: '',
  categoryId: 1,
  sex: 1,
  wAddress: '',
  hAddress: '',
  phone: '',
  email: '',
  createTime: '',
  notes: ''
})
// 当前页的读者列表
const readerList = ref<Reader[]>([])
// 读者id对应的分类列表，即categoryId字段不能只展示id值，应该根据id查询到对应的分类名进行回显
const readerCategoryList = ref<ReaderCategory[]>([])
// 读者分页参数
const readerPageData = reactive({
  name: '',
  categoryId: '',
  page: 1,
  pageSize: 6,
})
const readerTotal = ref(0)
const singleReaderRef = ref<InstanceType<typeof ElTable>>()

// 3、借还书
// 表单信息
const form = reactive<LendReturnDTO>({
  rId: 1,
  bId: 1,
  lendDate: '',
  returnDate: '',
  status: 0, // 默认0代表出借中
  notes: '',
})
const isValidForm = ref()
// 表单校验
const rules = {
  rId: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  bId: [
    { required: true, trigger: 'blur', message: '不能为空' },
  ],
  lendDate: [
    { required: true, trigger: 'blur', message: '不能为空' }
  ]
}

// ------ 方法 ------
// 页面初始化: 获取书籍分类、读者分类列表
const init = async () => {
  const { data: bookCategory } = await getBookCategoryAPI({ page: 1, pageSize: 100 })
  bookCategoryList.value = bookCategory.data.records
  console.log('bookCategoryList: ', bookCategoryList.value)
  const { data: readerCategory } = await getReaderCategoryAPI({ page: 1, pageSize: 100 })
  readerCategoryList.value = readerCategory.data.records
  console.log('readerCategoryList: ', readerCategoryList.value)
}
// 刷新书籍分页数据
const showBookPage = async () => {
  console.log('根据该条件获取分页书籍列表', bookPageData)
  const { data: res } = await getBookPageAPI(bookPageData)
  console.log('书籍列表')
  console.log(res.data)
  bookList.value = res.data.records
  bookTotal.value = res.data.total
}
// 刷新读者分页数据
const showReaderPage = async () => {
  console.log('根据该条件获取分页读者列表', readerPageData)
  const { data: res } = await getReaderPageAPI(readerPageData)
  console.log('书籍列表')
  console.log(res.data)
  readerList.value = res.data.records
  readerTotal.value = res.data.total
}
init() // 页面初始化，写在这里时的生命周期是beforecreated/created的时候
showBookPage() // 页面一开始就要展示分页书籍列表
showReaderPage() // 页面一开始就要展示分页读者列表

const disabledDateLend = (time: Date) => {
  return time.getTime() > Date.now()
}

const bookCurrentChange = (val: any) => {
  console.log(`当前页: ${val}`)
  showBookPage()
}
// 单选书籍
const singleBookChange = (val: Book) => {
  selectedBook.value = val
}
// 清空书籍单选状态
const clearBook = (row?: Book) => {
  singleBookRef.value!.setCurrentRow(row)
}
const readerCurrentChange = (val: any) => {
  console.log(`当前页: ${val}`)
  showReaderPage()
}
// 单选读者
const singleReaderChange = (val: Reader) => {
  selectedReader.value = val
}
// 清空读者单选状态
const clearReader = (row?: Reader) => {
  singleReaderRef.value!.setCurrentRow(row)
}


// 模糊查询书籍列表
const search_book_btn = async () => {
  console.log('查询书籍的条件')
  console.log(bookPageData)
  const { data: res } = await getBookPageAPI(bookPageData)
  // 删除后刷新页面，更新数据
  console.log(res)
  bookList.value = res.data.records
  bookTotal.value = res.data.total
  showBookPage()
}
// 模糊查询读者列表
const search_reader_btn = async () => {
  console.log('查询读者的条件')
  console.log(readerPageData)
  const { data: res } = await getReaderPageAPI(readerPageData)
  // 删除后刷新页面，更新数据
  console.log(res)
  readerList.value = res.data.records
  readerTotal.value = res.data.total
  showBookPage()
}

// 新增借还书记录
const add_btn = async () => {
  try {
    const valid = await isValidForm.value.validate()
    console.log('新增借还书记录,提交的表单form: ', form)
    if (valid) {
      if (form.returnDate && form.lendDate > form.returnDate) {
        ElMessage({
          message: '还书日期不能早于借书日期！',
          type: 'error',
        })
        return false
      }
      // 将书籍id和读者id赋值给form
      form.bId = selectedBook.value.id
      form.rId = selectedReader.value.id
      if (!form.bId || !form.rId) {
        ElMessage({
          message: '必须先选择借书人和书籍！',
          type: 'error',
        })
        return false
      }
      // 将日期转换为年月日格式(不能换行，空格和\n会被算进去...)
      let date = new Date(form.lendDate)
      form.lendDate = date.getFullYear() + '-' +
        String(date.getMonth() + 1).padStart(2, '0') + '-' +
        String(date.getDate()).padStart(2, '0')
      if (form.returnDate) {
        date = new Date(form.returnDate)
        form.returnDate = date.getFullYear() + '-' +
          String(date.getMonth() + 1).padStart(2, '0') + '-' +
          String(date.getDate()).padStart(2, '0')
      }
      const { data: res } = await addBorrowAPI(form)
      if (res.code == 1) return false
      console.log(res)
      // 提示新增成功
      ElMessage({
        message: '新增借还书记录成功！',
        type: 'success',
      })
      // 新增后刷新页面，更新数据
      showBookPage()
    } else {
      console.log('error submit!')
      return false;
    }
  } catch (error) {
    console.error('An error occurred during form validation:', error)
  }
}
</script>

<template>
  <div class="modern-add-lend">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <el-icon class="title-icon"><Plus /></el-icon>
          新增借阅记录
        </h1>
        <p class="page-subtitle">选择读者和图书，创建新的借阅记录</p>
      </div>
    </div>

    <!-- 借阅信息表单 -->
    <div class="form-container modern-card">
      <div class="form-header">
        <h3 class="form-title">
          <el-icon><DocumentAdd /></el-icon>
          借阅信息
        </h3>
      </div>

      <el-form :model="form" :rules="rules" ref="isValidForm" class="modern-form" label-width="120px">
        <div class="form-grid">
          <el-form-item label="选中读者" prop="rId">
            <div class="selected-info reader-info">
              <el-icon class="info-icon"><User /></el-icon>
              <span class="info-text">{{ selectedReader?.id ? `${selectedReader.id} - ${selectedReader.name}` : '请选择读者' }}</span>
            </div>
          </el-form-item>

          <el-form-item label="选中图书" prop="bId">
            <div class="selected-info book-info">
              <el-icon class="info-icon"><Reading /></el-icon>
              <span class="info-text">{{ selectedBook?.id ? `${selectedBook.id} - ${selectedBook.name}` : '请选择图书' }}</span>
            </div>
          </el-form-item>

          <el-form-item label="借书日期" prop="lendDate">
            <el-date-picker
              v-model="form.lendDate"
              type="date"
              :disabled-date="disabledDateLend"
              placeholder="请选择借书日期"
              class="modern-input"
              style="width: 100%"
            />
          </el-form-item>

          <el-form-item label="备注信息">
            <el-input
              v-model="form.notes"
              type="textarea"
              :rows="2"
              placeholder="请输入备注信息（可选）"
              class="modern-input"
            />
          </el-form-item>
        </div>

        <div class="form-actions">
          <el-button type="primary" @click="add_btn()" class="submit-btn" size="large">
            <el-icon><Check /></el-icon>
            创建借阅记录
          </el-button>
          <router-link to="/lendReturn">
            <el-button class="cancel-btn" size="large">
              <el-icon><Close /></el-icon>
              取消返回
            </el-button>
          </router-link>
        </div>
      </el-form>
    </div>

    <!-- 读者选择区域 -->
    <div class="selection-container">
      <div class="reader-section modern-card">
        <div class="section-header">
          <h3 class="section-title">
            <el-icon><User /></el-icon>
            选择读者
          </h3>
          <div class="section-actions">
            <el-button size="small" @click="clearReader()" type="info">
              <el-icon><RefreshLeft /></el-icon>
              清除选择
            </el-button>
          </div>
        </div>

        <!-- 读者搜索 -->
        <div class="search-section">
          <div class="search-group">
            <el-input
              v-model="readerPageData.name"
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
            <el-select
              v-model="readerPageData.categoryId"
              placeholder="选择分类"
              class="search-select"
              clearable
            >
              <el-option v-for="item in readerCategoryList" :key="item.id" :label="item.name" :value="item.id" />
            </el-select>
          </div>

          <el-button type="primary" @click="search_reader_btn()" class="search-btn">
            <el-icon><Search /></el-icon>
            搜索
          </el-button>
        </div>

        <!-- 读者表格 -->
        <el-table
          ref="singleReaderRef"
          :data="readerList"
          highlight-current-row
          @current-change="singleReaderChange"
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
          <el-table-column prop="id" label="读者号" width="80" />
          <el-table-column prop="name" label="姓名" min-width="100" />
          <el-table-column prop="categoryId" label="分类" width="120">
            <template #default="scope">
              <el-tag type="primary" size="small" effect="dark">
                {{ readerCategoryList.find(item => item.id === scope.row.categoryId)?.name || '未知' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="sex" label="性别" width="80">
            <template #default="scope">
              <el-tag :type="scope.row.sex === 1 ? 'info' : 'warning'" size="small" effect="dark">
                {{ scope.row.sex === 1 ? '男' : '女' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="phone" label="电话" min-width="120" />
          <template #empty>
            <div class="empty-state">
              <el-icon size="48" class="empty-icon"><User /></el-icon>
              <p class="empty-text">暂无读者数据</p>
            </div>
          </template>
        </el-table>

        <!-- 读者分页 -->
        <div class="pagination-container">
          <el-pagination
            layout="total, prev, pager, next, jumper"
            :total="readerTotal"
            :page-size="6"
            v-model:current-page="readerPageData.page"
            @current-change="readerCurrentChange"
            background
            class="modern-pagination"
          />
        </div>
      </div>

      <!-- 图书选择区域 -->
      <div class="book-section modern-card">
        <div class="section-header">
          <h3 class="section-title">
            <el-icon><Reading /></el-icon>
            选择图书
          </h3>
          <div class="section-actions">
            <el-button size="small" @click="clearBook()" type="info">
              <el-icon><RefreshLeft /></el-icon>
              清除选择
            </el-button>
          </div>
        </div>

        <!-- 图书搜索 -->
        <div class="search-section">
          <div class="search-group">
            <el-input
              v-model="bookPageData.name"
              placeholder="请输入图书名称"
              class="search-input"
              clearable
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </div>

          <div class="search-group">
            <el-select
              v-model="bookPageData.categoryId"
              placeholder="选择分类"
              class="search-select"
              clearable
            >
              <el-option v-for="item in bookCategoryList" :key="item.id" :label="item.name" :value="item.id" />
            </el-select>
          </div>

          <el-button type="primary" @click="search_book_btn()" class="search-btn">
            <el-icon><Search /></el-icon>
            搜索
          </el-button>
        </div>

        <!-- 图书表格 -->
        <el-table
          ref="singleBookRef"
          :data="bookList"
          highlight-current-row
          @current-change="singleBookChange"
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
          <el-table-column prop="id" label="图书号" width="80" />
          <el-table-column prop="name" label="书名" min-width="150" show-overflow-tooltip />
          <el-table-column prop="categoryId" label="分类" width="120">
            <template #default="scope">
              <el-tag type="success" size="small" effect="dark">
                {{ bookCategoryList.find(item => item.id === scope.row.categoryId)?.name || '未知' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="author" label="作者" min-width="100" show-overflow-tooltip />
          <el-table-column prop="press" label="出版社" min-width="120" show-overflow-tooltip />
          <el-table-column prop="price" label="价格" width="80">
            <template #default="scope">
              <span class="price-text">¥{{ scope.row.price }}</span>
            </template>
          </el-table-column>
          <template #empty>
            <div class="empty-state">
              <el-icon size="48" class="empty-icon"><Reading /></el-icon>
              <p class="empty-text">暂无可借图书</p>
            </div>
          </template>
        </el-table>

        <!-- 图书分页 -->
        <div class="pagination-container">
          <el-pagination
            layout="total, prev, pager, next, jumper"
            :total="bookTotal"
            :page-size="6"
            v-model:current-page="bookPageData.page"
            @current-change="bookCurrentChange"
            background
            class="modern-pagination"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="less" scoped>
/* 现代化新增借阅页面样式 */
.modern-add-lend {
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
        background: var(--gradient-success);
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

/* 表单容器 */
.form-container {
  padding: 24px;
  margin-bottom: 24px;

  .form-header {
    margin-bottom: 24px;

    .form-title {
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
    .form-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 24px;
      margin-bottom: 32px;

      .el-form-item:nth-child(4) {
        grid-column: 1 / -1;
      }
    }

    .selected-info {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px 16px;
      background: var(--bg-glass);
      border: var(--border-glass);
      border-radius: var(--radius-sm);
      min-height: 40px;

      .info-icon {
        color: var(--text-accent);
      }

      .info-text {
        color: var(--text-primary);
        font-weight: 500;
      }

      &.reader-info {
        border-left: 3px solid #f093fb;
      }

      &.book-info {
        border-left: 3px solid #43e97b;
      }
    }

    .form-actions {
      display: flex;
      justify-content: center;
      gap: 16px;

      .submit-btn {
        background: var(--gradient-success);
        border: none;
        min-width: 160px;

        &:hover {
          background: var(--gradient-accent);
          transform: translateY(-2px);
          box-shadow: 0 8px 25px rgba(67, 233, 123, 0.4);
        }
      }

      .cancel-btn {
        background: var(--bg-glass);
        border: var(--border-glass);
        color: var(--text-secondary);
        min-width: 120px;

        &:hover {
          background: var(--bg-glass-hover);
          color: var(--text-primary);
          transform: translateY(-1px);
        }
      }
    }
  }
}

/* 选择容器 */
.selection-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

.reader-section,
.book-section {
  padding: 0;
  overflow: hidden;

  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 24px;
    border-bottom: var(--border-glass);

    .section-title {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 16px;
      font-weight: 600;
      color: var(--text-primary);
      margin: 0;
    }

    .section-actions {
      display: flex;
      gap: 8px;
    }
  }

  .search-section {
    display: flex;
    gap: 12px;
    padding: 16px 24px;
    border-bottom: var(--border-glass);

    .search-group {
      flex: 1;

      .search-input,
      .search-select {
        :deep(.el-input__wrapper),
        :deep(.el-select__wrapper) {
          background: var(--bg-glass);
          border: var(--border-glass);
          border-radius: var(--radius-sm);
          transition: var(--transition-smooth);

          &:hover {
            border-color: rgba(67, 233, 123, 0.5);
          }

          &.is-focus {
            border-color: #43e97b;
            box-shadow: 0 0 0 2px rgba(67, 233, 123, 0.2);
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
      background: var(--gradient-success);
      border: none;
      border-radius: var(--radius-sm);

      &:hover {
        background: var(--gradient-accent);
        transform: translateY(-1px);
      }
    }
  }

  .modern-table {
    background: transparent;

    :deep(.el-table__header) {
      background: var(--bg-secondary);
    }

    :deep(.el-table__row) {
      background: transparent;
      cursor: pointer;

      &:hover {
        background: var(--bg-glass) !important;
      }

      &.current-row {
        background: rgba(67, 233, 123, 0.1) !important;

        td {
          background: transparent !important;
        }
      }
    }

    :deep(.el-table__cell) {
      border-color: var(--border-glass);
      color: var(--text-primary);
    }

    .price-text {
      color: var(--text-accent);
      font-weight: 600;
    }

    .empty-state {
      padding: 40px 20px;
      text-align: center;

      .empty-icon {
        color: var(--text-muted);
        margin-bottom: 12px;
      }

      .empty-text {
        color: var(--text-secondary);
        font-size: 14px;
        margin: 0;
      }
    }
  }

  .pagination-container {
    display: flex;
    justify-content: center;
    padding: 16px;

    .modern-pagination {
      :deep(.el-pagination__total),
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
          background: var(--gradient-success);
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
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .selection-container {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .form-container .modern-form .form-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .modern-add-lend {
    padding: 16px;
  }

  .form-container {
    padding: 16px;
  }

  .reader-section,
  .book-section {
    .search-section {
      flex-direction: column;
      gap: 12px;
    }
  }

  .page-header .header-content .page-title {
    font-size: 24px;
  }

  .form-container .modern-form .form-actions {
    flex-direction: column;

    .submit-btn,
    .cancel-btn {
      width: 100%;
    }
  }
}
</style>

<!-- 全局样式覆盖 -->
<style>
.modern-form .el-form-item__label {
  color: var(--text-secondary) !important;
}

.modern-input .el-input__wrapper,
.modern-input .el-textarea__inner,
.modern-input .el-date-editor .el-input__wrapper {
  background: var(--bg-glass) !important;
  border: var(--border-glass) !important;
  border-radius: var(--radius-sm) !important;
  color: var(--text-primary) !important;
}

.modern-input .el-input__inner,
.modern-input .el-textarea__inner {
  color: var(--text-primary) !important;
}
</style>