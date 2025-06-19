<script lang="ts" setup>
import { reactive, ref, onMounted, watchEffect } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'
import {
  getBookCategoryDataAPI, getReaderCategoryDataAPI, getLendDataAPI,
  getReturnDataAPI, getBookTopDataAPI, getReaderTopDataAPI, getOverdueCountAPI
} from '@/api/data'
import * as echarts from 'echarts'

type Pie = { value: number, name: string }

// ------ 数据 ------
const daysOptions = [
  {
    value: 7,
    label: '近7天',
  },
  {
    value: 14,
    label: '近14天',
  },
  {
    value: 30,
    label: '近30天',
  },
]
const topOptions = [
  {
    value: 7,
    label: '周榜',
  },
  {
    value: 30,
    label: '月榜',
  },
  {
    value: 365,
    label: '年榜',
  },
  {
    value: 3000,
    label: '总榜',
  },
]
const lendDays = ref(7)
const lend_data_x = ref()
const lend_data_y = ref()

const returnDays = ref(7)
const return_data_x = ref()
const return_data_y = ref()

const book_pie_data = ref<Pie[]>([])
const reader_pie_data = ref<Pie[]>([])

const bookDays = ref(7)
const book_top_x = ref()
const book_top_y = ref()

const readerDays = ref(7)
const reader_top_x = ref()
const reader_top_y = ref()

// 统计卡片数据
const statsData = ref([
  {
    title: '图书总数',
    value: '0',
    icon: 'Reading',
    gradient: 'var(--gradient-primary)',
    trend: 'up',
    change: '+0%'
  },
  {
    title: '读者总数',
    value: '0',
    icon: 'UserFilled',
    gradient: 'var(--gradient-secondary)',
    trend: 'up',
    change: '+0%'
  },
  {
    title: '今日借阅',
    value: '0',
    icon: 'DocumentCopy',
    gradient: 'var(--gradient-success)',
    trend: 'up',
    change: '+0%'
  },
  {
    title: '逾期未还',
    value: '0',
    icon: 'Warning',
    gradient: 'var(--gradient-warning)',
    trend: 'down',
    change: '+0%'
  }
])

// 获取统计数据
const getStatsData = async () => {
  try {
    // 获取图书分类数据来计算图书总数
    const { data: bookRes } = await getBookCategoryDataAPI()
    if (bookRes.code === 0) {
      const bookNums = bookRes.data.bookCategoryNums.split(",")
      const totalBooks = bookNums.reduce((sum, num) => sum + parseInt(num), 0)
      statsData.value[0].value = totalBooks.toLocaleString()
    }

    // 获取读者分类数据来计算读者总数
    const { data: readerRes } = await getReaderCategoryDataAPI()
    if (readerRes.code === 0) {
      const readerNums = readerRes.data.readerCategoryNums.split(",")
      const totalReaders = readerNums.reduce((sum, num) => sum + parseInt(num), 0)
      statsData.value[1].value = totalReaders.toLocaleString()
    }

    // 获取今日借阅数据
    const { data: lendRes } = await getLendDataAPI(1)
    if (lendRes.code === 0) {
      const todayLend = lendRes.data.lendOrReturnList.split(",").pop()
      statsData.value[2].value = parseInt(todayLend || '0').toLocaleString()
    }

    // 获取逾期未还数据
    const { data: overdueRes } = await getOverdueCountAPI()
    if (overdueRes.code === 0) {
      statsData.value[3].value = overdueRes.data.toString()
    }

  } catch (error) {
    console.error('获取统计数据失败:', error)
  }
}

// ------ 方法 ------
// 获取统计数据
const getBookCategoryData = async () => {
  const { data: res } = await getBookCategoryDataAPI()
  console.log('书籍分类', res)
  const book_pie_x = res.data.bookCategoryNames.split(",")
  const book_pie_y = res.data.bookCategoryNums.split(",")
  for (let i = 0; i < book_pie_x.length; i++) {
    book_pie_data.value.push({ value: book_pie_y[i], name: book_pie_x[i] })
  }
  console.log('book_pie_data', book_pie_data.value)
}
const getReaderCategoryData = async () => {
  const { data: res } = await getReaderCategoryDataAPI()
  console.log('读者分类', res)
  const reader_pie_x = res.data.readerCategoryNames.split(",")
  const reader_pie_y = res.data.readerCategoryNums.split(",")
  for (let i = 0; i < reader_pie_x.length; i++) {
    reader_pie_data.value.push({ value: reader_pie_y[i], name: reader_pie_x[i] })
  }
  console.log('reader_pie_data', reader_pie_data.value)
}
const getLendData = async () => {
  const { data: res } = await getLendDataAPI(lendDays.value)
  console.log('借书统计', res)
  lend_data_x.value = res.data.dateList.split(",")
  lend_data_y.value = res.data.lendOrReturnList.split(",")
}
const getReturnData = async () => {
  const { data: res } = await getReturnDataAPI(returnDays.value)
  console.log('还书统计', res)
  return_data_x.value = res.data.dateList.split(",")
  return_data_y.value = res.data.lendOrReturnList.split(",")
}
const getBookTopData = async () => {
  const { data: res } = await getBookTopDataAPI(bookDays.value)
  console.log('书籍人气Top', res)
  book_top_x.value = res.data.nameList.split(",")
  book_top_y.value = res.data.topList.split(",")
}
const getReaderTopData = async () => {
  const { data: res } = await getReaderTopDataAPI(readerDays.value)
  console.log('读者借书排行榜Top', res)
  reader_top_x.value = res.data.nameList.split(",")
  reader_top_y.value = res.data.topList.split(",")
}


// 加载/绘制图表
// 1、不同类别图书数量饼图 - 现代化深色主题
const loadBookPie = async () => {
  await getBookCategoryData()
  const bookPie = echarts.init(document.getElementById('bookPie'), 'dark')
  const bookPieOption = {
    backgroundColor: 'transparent',
    title: {
      text: '图书分类分布',
      textStyle: {
        color: '#ffffff',
        fontSize: 16,
        fontWeight: 'bold'
      },
      left: 'center',
      top: 20
    },
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b} : {c} ({d}%)',
      backgroundColor: 'rgba(0, 0, 0, 0.8)',
      borderColor: 'rgba(255, 255, 255, 0.2)',
      textStyle: {
        color: '#ffffff'
      }
    },
    legend: {
      top: '20%',
      left: 'center',
      textStyle: {
        color: '#b8bcc8'
      }
    },
    series: [
      {
        name: '图书数量',
        type: 'pie',
        radius: ['30%', '70%'],
        center: ['50%', '60%'],
        data: book_pie_data.value,
        itemStyle: {
          borderRadius: 8,
          borderColor: 'rgba(255, 255, 255, 0.1)',
          borderWidth: 2
        },
        emphasis: {
          itemStyle: {
            shadowBlur: 20,
            shadowOffsetX: 0,
            shadowColor: 'rgba(102, 126, 234, 0.5)'
          },
          scale: true,
          scaleSize: 5
        },
        animationType: 'scale',
        animationEasing: 'elasticOut'
      }
    ]
  }
  bookPie.setOption(bookPieOption)
}

// 2、不同类别读者数量饼图
const loadReaderPie = async () => {
  await getReaderCategoryData()
  const readerPie = echarts.init(document.getElementById('readerPie')) // 默认主题为亮白色
  const readerPieOption = {
    title: {
      text: '不同类别读者数量统计',
      subtext: 'my layout',
      left: 'center'
    },
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b} : {c} ({d}%)'
    },
    legend: {
      top: '15%',
      left: 'center',
    },
    series: [
      {
        name: '图书数量',
        type: 'pie',
        radius: ['20%', '55%'],
        center: ['50%', '65%'],
        data: reader_pie_data.value,
        itemStyle: {
          borderRadius: 6,
          borderColor: '#fff',
          borderWidth: 2,
        },
      }
    ]
  }
  // 使用刚指定的配置项和数据显示图表。
  readerPie.setOption(readerPieOption)
}

// 3、近期借书数量折线图 - 现代化深色主题
const loadLendChart = async () => {
  await getLendData()
  const lendChart = echarts.init(document.getElementById('lend'), 'dark')
  const lendOption = {
    backgroundColor: 'transparent',
    title: {
      text: '借阅趋势',
      textStyle: {
        color: '#ffffff',
        fontSize: 16,
        fontWeight: 'bold'
      },
      left: 'center',
      top: 20
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: lend_data_x.value,
      axisLine: {
        lineStyle: {
          color: 'rgba(255, 255, 255, 0.2)'
        }
      },
      axisLabel: {
        color: '#b8bcc8'
      }
    },
    yAxis: {
      type: 'value',
      axisLine: {
        lineStyle: {
          color: 'rgba(255, 255, 255, 0.2)'
        }
      },
      axisLabel: {
        color: '#b8bcc8'
      },
      splitLine: {
        lineStyle: {
          color: 'rgba(255, 255, 255, 0.1)'
        }
      }
    },
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(0, 0, 0, 0.8)',
      borderColor: 'rgba(255, 255, 255, 0.2)',
      textStyle: {
        color: '#ffffff'
      }
    },
    series: [
      {
        name: '借阅数量',
        data: lend_data_y.value,
        type: 'line',
        smooth: true,
        symbol: 'circle',
        symbolSize: 8,
        itemStyle: {
          color: '#4facfe'
        },
        lineStyle: {
          width: 3,
          color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
            { offset: 0, color: '#4facfe' },
            { offset: 1, color: '#00f2fe' }
          ])
        },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(79, 172, 254, 0.3)' },
            { offset: 1, color: 'rgba(0, 242, 254, 0.1)' }
          ])
        },
        emphasis: {
          itemStyle: {
            shadowBlur: 15,
            shadowColor: 'rgba(79, 172, 254, 0.8)'
          }
        }
      }
    ]
  }
  lendChart.setOption(lendOption)
}

// 4、近期还书数量折线图
const loadReturnChart = async () => {
  await getReturnData()
  const returnChart = echarts.init(document.getElementById('return')) // 默认主题为亮白色
  const returnOption = {
    title: {
      text: '近期还书数量统计',
      subtext: 'my layout',
      left: 'center'
    },
    xAxis: {
      type: 'category',
      data: return_data_x.value,
    },
    yAxis: {
      type: 'value',
    },
    tooltip: {
      trigger: 'item'
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        data: return_data_y.value,
        type: 'line',
        itemStyle: {
          color: '#00aaff' // 设置点的颜色
        },
        lineStyle: {
          width: 2,
          color: '#00aaff'
        },
        areaStyle: {
          // opacity: 0.5,
          // 从上到下渐变，(0,0)是上部，(0,1)是下部
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            {
              offset: 0,
              color: 'rgba(0, 221, 255, 1)'
            },
            {
              offset: 1,
              color: 'rgba(0, 221, 255, 0)'
            }
          ])
        },
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 255, 0.5)'
          }
        },
      }
    ]
  }
  // 使用刚指定的配置项和数据显示图表。
  returnChart.setOption(returnOption)
}

// 5、图书人气排行榜柱状图
const loadBookTopChart = async () => {
  await getBookTopData()
  console.log('mounted还没拿到吗！', book_top_x.value, book_top_y.value)
  const bookTopChart = echarts.init(document.getElementById('bookTop')) // 默认主题为亮白色
  const bookTopOption = {
    title: {
      text: '近期人气借阅书籍Top排行榜',
      subtext: 'my layout',
      left: 'center'
    },
    yAxis: {
      type: 'category',
      data: book_top_x.value,
      inverse: true, // 设置为true，使得数据倒序
    },
    xAxis: {
      type: 'value',
    },
    grid: {
      left: '5%',
      right: '10%',
      bottom: '3%',
      containLabel: true
    },
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        data: book_top_y.value,
        type: 'bar',
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        },
        itemStyle: {
          color: (params: any) => {
            // 根据数据值动态设置颜色
            const colors = ['#992213', '#bb4413', '#dd7713', '#ee9913', '#eebb2F', '#eedd2F', '#ffee2F'] // 颜色数组
            return colors[params.dataIndex % colors.length] // 取余操作来循环轮流排列颜色
          }
        }
      }
    ]
  }
  // 使用刚指定的配置项和数据显示图表
  bookTopChart.setOption(bookTopOption)
}

// 6、读者借书排行榜柱状图
const loadReaderTopChart = async () => {
  await getReaderTopData()
  const readerTopChart = echarts.init(document.getElementById('readerTop')) // 默认主题为亮白色
  const readerTopOption = {
    title: {
      text: '近期读者借书Top排行榜',
      subtext: 'my layout',
      left: 'center'
    },
    yAxis: {
      type: 'category',
      data: reader_top_x.value,
      inverse: true, // 设置为true，使得数据倒序
    },
    xAxis: {
      type: 'value',
    },
    grid: {
      left: '5%',
      right: '10%',
      bottom: '3%',
      containLabel: true
    },
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        data: reader_top_y.value,
        type: 'bar',
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        },
        itemStyle: {
          color: (params: any) => {
            // 根据数据值动态设置颜色
            const colors = ['#55ff66', '#55ee88', '#55dda5', '#55ccb9', '#55bbcc', '#5599dd', '#5577ee', '#5555ff'] // 颜色数组
            return colors[params.dataIndex % colors.length] // 取余操作来循环轮流排列颜色
          }
        }
      }
    ]
  }
  // 使用刚指定的配置项和数据显示图表。
  readerTopChart.setOption(readerTopOption)
}

// 挂载时才能获取dom元素
onMounted(() => {
  getStatsData() // 获取统计数据
  loadBookPie()
  loadReaderPie()
  loadLendChart()
  loadReturnChart()
  loadBookTopChart()
  loadReaderTopChart()
})

watchEffect(() => {
  console.log('watchEffect配置的回调执行了，根据情况动态加载，不用显式指明属性')
  loadLendChart()
  loadReturnChart()
  loadBookTopChart()
  loadReaderTopChart()
})
</script>

<template>
  <div class="modern-dashboard">
    <!-- 仪表板标题 -->
    <div class="dashboard-header">
      <h1 class="dashboard-title">
        <el-icon class="title-icon"><DataAnalysis /></el-icon>
        数据概览
      </h1>
      <p class="dashboard-subtitle">实时监控图书馆运营数据</p>
    </div>

    <!-- 统计卡片区域 -->
    <div class="stats-grid">
      <div class="stat-card modern-card" v-for="stat in statsData" :key="stat.title">
        <div class="stat-icon" :style="{ background: stat.gradient }">
          <el-icon :size="24">
            <component :is="stat.icon" />
          </el-icon>
        </div>
        <div class="stat-content">
          <h3 class="stat-value">{{ stat.value }}</h3>
          <p class="stat-title">{{ stat.title }}</p>
          <div class="stat-trend" :class="stat.trend">
            <el-icon><ArrowUp v-if="stat.trend === 'up'" /><ArrowDown v-else /></el-icon>
            <span>{{ stat.change }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 图表区域 -->
    <div class="charts-grid">
      <!-- 图书分类饼图 -->
      <div class="chart-container modern-card">
        <div class="chart-header">
          <h3 class="chart-title">
            <el-icon><Collection /></el-icon>
            图书分类分布
          </h3>
          <div class="chart-actions">
            <el-button size="small" type="primary" text>
              <el-icon><Refresh /></el-icon>
            </el-button>
          </div>
        </div>
        <div class="chart-content">
          <div id="bookPie" class="chart-canvas"></div>
        </div>
      </div>

      <!-- 借阅趋势图 -->
      <div class="chart-container modern-card">
        <div class="chart-header">
          <h3 class="chart-title">
            <el-icon><TrendCharts /></el-icon>
            借阅趋势
          </h3>
          <div class="chart-controls">
            <el-select v-model="lendDays" size="small" style="width: 120px">
              <el-option v-for="item in daysOptions" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </div>
        </div>
        <div class="chart-content">
          <div id="lend" class="chart-canvas"></div>
        </div>
      </div>

      <!-- 读者分类饼图 -->
      <div class="chart-container modern-card">
        <div class="chart-header">
          <h3 class="chart-title">
            <el-icon><UserFilled /></el-icon>
            读者分类分布
          </h3>
          <div class="chart-actions">
            <el-button size="small" type="primary" text>
              <el-icon><Refresh /></el-icon>
            </el-button>
          </div>
        </div>
        <div class="chart-content">
          <div id="readerPie" class="chart-canvas"></div>
        </div>
      </div>

      <!-- 归还趋势图 -->
      <div class="chart-container modern-card">
        <div class="chart-header">
          <h3 class="chart-title">
            <el-icon><DocumentChecked /></el-icon>
            归还趋势
          </h3>
          <div class="chart-controls">
            <el-select v-model="returnDays" size="small" style="width: 120px">
              <el-option v-for="item in daysOptions" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </div>
        </div>
        <div class="chart-content">
          <div id="return" class="chart-canvas"></div>
        </div>
      </div>
    </div>

    <!-- 排行榜区域 -->
    <div class="ranking-grid">
      <!-- 热门图书排行 -->
      <div class="ranking-container modern-card">
        <div class="ranking-header">
          <h3 class="ranking-title">
            <el-icon><Trophy /></el-icon>
            热门图书排行
          </h3>
          <div class="ranking-controls">
            <el-select v-model="bookDays" size="small" style="width: 120px">
              <el-option v-for="item in topOptions" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </div>
        </div>
        <div class="ranking-content">
          <div id="bookTop" class="chart-canvas"></div>
        </div>
      </div>

      <!-- 活跃读者排行 -->
      <div class="ranking-container modern-card">
        <div class="ranking-header">
          <h3 class="ranking-title">
            <el-icon><Star /></el-icon>
            活跃读者排行
          </h3>
          <div class="ranking-controls">
            <el-select v-model="readerDays" size="small" style="width: 120px">
              <el-option v-for="item in topOptions" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </div>
        </div>
        <div class="ranking-content">
          <div id="readerTop" class="chart-canvas"></div>
        </div>
      </div>
    </div>

    <!-- 快速操作区域 -->
    <div class="quick-actions modern-card">
      <h3 class="actions-title">
        <el-icon><Operation /></el-icon>
        快速操作
      </h3>
      <div class="actions-grid">
        <router-link to="/book" class="action-item">
          <div class="action-icon">
            <el-icon><Reading /></el-icon>
          </div>
          <span class="action-text">图书管理</span>
        </router-link>
        <router-link to="/reader" class="action-item">
          <div class="action-icon">
            <el-icon><Avatar /></el-icon>
          </div>
          <span class="action-text">读者管理</span>
        </router-link>
        <router-link to="/lendReturn/add" class="action-item">
          <div class="action-icon">
            <el-icon><Plus /></el-icon>
          </div>
          <span class="action-text">新增借书</span>
        </router-link>
        <router-link to="/lendReturn" class="action-item">
          <div class="action-icon">
            <el-icon><List /></el-icon>
          </div>
          <span class="action-text">借阅记录</span>
        </router-link>
      </div>
    </div>
  </div>
</template>

<style lang="less" scoped>
/* 现代化仪表板样式 */
.modern-dashboard {
  padding: 24px;
  background: var(--bg-primary);
  min-height: 100vh;
}

/* 仪表板标题 */
.dashboard-header {
  margin-bottom: 32px;
  text-align: center;

  .dashboard-title {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    font-size: 32px;
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

  .dashboard-subtitle {
    font-size: 16px;
    color: var(--text-secondary);
    margin: 0;
  }
}

/* 统计卡片网格 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
  margin-bottom: 32px;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 24px;
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 3px;
    background: var(--gradient-accent);
    opacity: 0;
    transition: var(--transition-smooth);
  }

  &:hover::before {
    opacity: 1;
  }

  .stat-icon {
    width: 64px;
    height: 64px;
    border-radius: var(--radius-lg);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    box-shadow: var(--shadow-glass);
  }

  .stat-content {
    flex: 1;

    .stat-value {
      font-size: 28px;
      font-weight: 700;
      color: var(--text-primary);
      margin: 0 0 4px 0;
    }

    .stat-title {
      font-size: 14px;
      color: var(--text-secondary);
      margin: 0 0 8px 0;
    }

    .stat-trend {
      display: flex;
      align-items: center;
      gap: 4px;
      font-size: 12px;
      font-weight: 600;

      &.up {
        color: #43e97b;
      }

      &.down {
        color: #fa709a;
      }
    }
  }
}

/* 图表网格 */
.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
  gap: 24px;
  margin-bottom: 32px;
}

.chart-container {
  padding: 0;
  overflow: hidden;

  .chart-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 24px;
    border-bottom: var(--border-glass);

    .chart-title {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 16px;
      font-weight: 600;
      color: var(--text-primary);
      margin: 0;
    }

    .chart-controls,
    .chart-actions {
      display: flex;
      gap: 8px;
    }
  }

  .chart-content {
    padding: 16px;
    height: 350px;

    .chart-canvas {
      width: 100%;
      height: 100%;
    }
  }
}

/* 排行榜网格 */
.ranking-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
  gap: 24px;
  margin-bottom: 32px;
}

.ranking-container {
  padding: 0;
  overflow: hidden;

  .ranking-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 24px;
    border-bottom: var(--border-glass);

    .ranking-title {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 16px;
      font-weight: 600;
      color: var(--text-primary);
      margin: 0;
    }

    .ranking-controls {
      display: flex;
      gap: 8px;
    }
  }

  .ranking-content {
    padding: 16px;
    height: 350px;

    .chart-canvas {
      width: 100%;
      height: 100%;
    }
  }
}

/* 快速操作区域 */
.quick-actions {
  padding: 24px;

  .actions-title {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 18px;
    font-weight: 600;
    color: var(--text-primary);
    margin: 0 0 20px 0;
  }

  .actions-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 16px;
  }

  .action-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
    padding: 20px;
    background: var(--bg-glass);
    border: var(--border-glass);
    border-radius: var(--radius-md);
    text-decoration: none;
    color: var(--text-secondary);
    transition: var(--transition-smooth);

    &:hover {
      background: var(--bg-glass-hover);
      color: var(--text-primary);
      transform: translateY(-2px);
      box-shadow: var(--shadow-hover);
    }

    .action-icon {
      width: 48px;
      height: 48px;
      background: var(--gradient-primary);
      border-radius: var(--radius-md);
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-size: 20px;
    }

    .action-text {
      font-size: 14px;
      font-weight: 500;
    }
  }
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .charts-grid,
  .ranking-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .modern-dashboard {
    padding: 16px;
  }

  .stats-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .stat-card {
    padding: 16px;

    .stat-icon {
      width: 48px;
      height: 48px;
    }

    .stat-content .stat-value {
      font-size: 24px;
    }
  }

  .chart-container,
  .ranking-container {
    .chart-content,
    .ranking-content {
      height: 280px;
    }
  }

  .dashboard-header .dashboard-title {
    font-size: 24px;
  }

  .actions-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>