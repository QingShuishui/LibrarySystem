<script setup lang="ts">
import { reactive, ref } from 'vue'
import { getBorrowPageAPI, deleteBorrowsAPI } from '@/api/lendReturn'
import { ElMessage, ElMessageBox, ElTable } from 'element-plus'
import { useRouter } from 'vue-router'

// ------ .d.ts 属性类型接口 ------
// 接收到不在接口中定义的属性的数据，ts会报错，但是类型推断错误不会妨碍接收，控制台还是能打印的
interface LendReturn {
  id: number
  rId: number
  bId: number
  lendDate: string
  returnDate: string
  status: number
  notes: string
}

// ------ 数据 ------
// 当前页的借还书记录列表
const borrowList = ref<LendReturn[]>([])
// 分页参数
const pageData = reactive({
  rId: '',
  bId: '',
  notes: '',
  page: 1,
  pageSize: 6,
})
// const isValidForm = ref()
const total = ref(0)
const multiTableRef = ref<InstanceType<typeof ElTable>>()
const multiSelection = ref<LendReturn[]>([])

const statusList = [
  { id: 0, name: '出借中' },
  { id: 1, name: '正常归还' },
  { id: 2, name: '逾期归还' },
  { id: 3, name: '丢失无法归还' },
  { id: 4, name: '损坏归还' },
  { id: 5, name: '其他(备注说明)' },
]

// 初始化时分页查询借还书记录
const init = async () => {
  const { data: resultBorrow } = await getBorrowPageAPI(pageData)
  console.log(resultBorrow)
  borrowList.value = resultBorrow.data.records
  total.value = resultBorrow.data.total
  console.log(borrowList)
}
// 初始化
init()

const handleCurrentChange = (val: any) => {
  console.log(`当前页: ${val}`);
  init()
}
const handleSizeChange = (val: any) => {
  console.log(`每页 ${val} 条`);
  init()
}
const handleSelectionChange = (val: LendReturn[]) => {
  multiSelection.value = val
  console.log('value', val)
  console.log('multiSelection.value', multiSelection.value)
}

// 根据状态值返回对应的标签类型
const getStatusTagType = (status: number) => {
  // 0：出借中  1：正常归还  2：逾期归还  3：丢失无法归还  4：损坏归还  5：其他(见备注)
  switch (status) {
    case 0:
      return 'info'      // 出借中 - 灰色
    case 1:
      return 'success'   // 正常归还 - 绿色
    case 2:
      return 'warning'   // 逾期归还 - 黄色
    case 3:
      return 'danger'    // 丢失无法归还 - 红色
    case 4:
      return 'warning'   // 损坏归还 - 橙色
    case 5:
      return 'primary'   // 其他 - 蓝色
    default:
      return 'info'
  }
}
// 模糊查询借还书记录列表
const search_btn = async () => {
  console.log('查询借还书记录的条件')
  console.log(pageData)
  const { data: res } = await getBorrowPageAPI(pageData)
  // 删除后刷新页面，更新数据
  console.log(res)
  borrowList.value = res.data.records
  total.value = res.data.total
  init()
}

// 修改借阅人(路径传参，到update页面后，根据id查询借阅人信息，回显到表单中)
const router = useRouter()
const update_btn = (row: any) => {
  console.log('要修改的行数据')
  console.log(row)
  router.push({
    name: 'lendReturnUpdate',
    query: {
      id: row.id
    }
  })
}

// 删除借还书记录
const delete_btn = async (row: any) => {
  ElMessageBox.confirm(
    '删除异常借还书记录会删除对应书籍，是否继续？',
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
      await deleteBorrowsAPI(row.id)
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

// 批量删除借阅人
const deleteBatch = (row?: any) => {
  console.log('要删除的行数据')
  console.log(row)
  ElMessageBox.confirm(
    '批量删除异常记录会删除对应书籍，请谨慎操作！',
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
            message: '请先选择要删除的借还书记录',
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
        let res = await deleteBorrowsAPI(ids)
        if (res.data.code != 0) return
      }
      // 2. 传入行数据，单个删除
      else {
        console.log('id包装成数组，然后调用批量删除接口')
        console.log(row.id)
        let res = await deleteBorrowsAPI(row.id)
        if (res.data.code != 0) return
      }
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
  <div class="modern-lend-return-management">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <el-icon class="title-icon"><DocumentCopy /></el-icon>
          借阅管理
        </h1>
        <p class="page-subtitle">管理图书借阅记录，包括借书、还书、状态跟踪等</p>
      </div>
    </div>

    <!-- 搜索和操作栏 -->
    <div class="search-toolbar modern-card">
      <div class="search-section">
        <div class="search-group">
          <label class="search-label">读者编号</label>
          <el-input
            v-model="pageData.rId"
            placeholder="请输入读者编号"
            class="search-input"
            clearable
          >
            <template #prefix>
              <el-icon><User /></el-icon>
            </template>
          </el-input>
        </div>

        <div class="search-group">
          <label class="search-label">图书编号</label>
          <el-input
            v-model="pageData.bId"
            placeholder="请输入图书编号"
            class="search-input"
            clearable
          >
            <template #prefix>
              <el-icon><Reading /></el-icon>
            </template>
          </el-input>
        </div>

        <div class="search-group">
          <label class="search-label">备注信息</label>
          <el-input
            v-model="pageData.notes"
            placeholder="请输入备注信息"
            class="search-input"
            clearable
          >
            <template #prefix>
              <el-icon><Document /></el-icon>
            </template>
          </el-input>
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

        <router-link to="/lendReturn/add">
          <el-button
            type="primary"
            class="action-btn primary"
          >
            <el-icon><Plus /></el-icon>
            新增借书
          </el-button>
        </router-link>
      </div>
    </div>

    <!-- 现代化表格 -->
    <div class="table-container modern-card">
      <div class="table-header">
        <div class="table-info">
          <span class="table-title">借阅记录列表</span>
          <span class="table-count">共 {{ total }} 条记录</span>
        </div>
        <div class="table-actions">
          <el-button size="small" @click="init()">
            <el-icon><Refresh /></el-icon>
          </el-button>
        </div>
      </div>

      <el-table
        ref="multiTableRef"
        :data="borrowList"
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

        <el-table-column prop="id" label="编号" width="80" />

        <el-table-column prop="rId" label="读者编号" width="120">
          <template #default="scope">
            <div class="reader-id">
              <el-icon class="id-icon"><User /></el-icon>
              <span>{{ scope.row.rId }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column prop="bId" label="图书编号" width="120">
          <template #default="scope">
            <div class="book-id">
              <el-icon class="id-icon"><Reading /></el-icon>
              <span>{{ scope.row.bId }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column prop="lendDate" label="借书日期" width="150">
          <template #default="scope">
            <span class="date-text">{{ scope.row.lendDate }}</span>
          </template>
        </el-table-column>

        <el-table-column prop="returnDate" label="归还日期" width="150">
          <template #default="scope">
            <span class="date-text">{{ scope.row.returnDate || '未归还' }}</span>
          </template>
        </el-table-column>

        <el-table-column prop="status" label="状态" width="120">
          <template #default="scope">
            <el-tag
              :type="getStatusTagType(scope.row.status)"
              size="small"
              effect="dark"
            >
              {{ statusList.find(item => item.id === scope.row.status)?.name || '未知' }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="notes" label="备注" min-width="150" show-overflow-tooltip />

        <el-table-column label="操作" width="180" fixed="right">
          <template #default="scope">
            <div class="action-buttons">
              <el-button
                size="small"
                type="primary"
                @click="update_btn(scope.row)"
                class="action-btn-small"
                :disabled="scope.row.status !== 0"
              >
                <el-icon><Check /></el-icon>
                还书
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
            <el-icon size="64" class="empty-icon"><DocumentCopy /></el-icon>
            <p class="empty-text">暂无借阅记录</p>
            <router-link to="/lendReturn/add">
              <el-button type="primary">
                <el-icon><Plus /></el-icon>
                添加第一条借阅记录
              </el-button>
            </router-link>
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
/* 现代化借阅管理页面样式 */
.modern-lend-return-management {
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
      min-width: 140px;

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
            border-color: rgba(67, 233, 123, 0.5);
          }

          &.is-focus {
            border-color: #43e97b;
            box-shadow: 0 0 0 2px rgba(67, 233, 123, 0.2);
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
      background: var(--gradient-success);
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
      text-decoration: none;

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

    .reader-id,
    .book-id {
      display: flex;
      align-items: center;
      gap: 8px;

      .id-icon {
        color: var(--text-accent);
      }
    }

    .date-text {
      color: var(--text-secondary);
      font-weight: 500;
    }

    .action-buttons {
      display: flex;
      gap: 8px;

      .action-btn-small {
        padding: 4px 8px;
        font-size: 12px;
        border-radius: var(--radius-sm);

        &:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }
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

      a {
        text-decoration: none;
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
  .modern-lend-return-management {
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
