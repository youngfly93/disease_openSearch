# 快速启动指南

## 🚀 立即运行应用

### 方法1: 使用启动脚本（推荐）
```r
source("run_app.R")
```

### 方法2: 直接运行
```r
shiny::runApp("app.R")
```

## 🔧 如果遇到错误

### 错误: `could not find function "ul"`
**解决方案**: 已修复，确保使用最新的 `app.R` 文件

### 错误: renv相关问题
**解决方案**: 使用 `run_app.R` 脚本，它会自动处理依赖

### 错误: 包缺失
**解决方案**: 运行以下命令安装依赖
```r
install.packages(c("shiny", "DT", "shinymanager", "data.table"))
```

## 🎯 应用特点

### PDC风格设计
- **左侧**: 交互式人体图（12个器官区域）
- **右侧**: 实时柱状图（显示病例数量）
- **配色**: 专业的蓝色渐变背景
- **效果**: 毛玻璃和发光动画

### 交互方式
1. **单击器官** → 选中高亮（黄色边框）
2. **双击器官** → 进入详细数据页面
3. **悬停器官** → 蓝色高亮效果
4. **同步显示** → 人体图和柱状图双向同步

### 数据页面
- 三种数据类型：Modification Counts, Scale Modifications, Site Counts
- 交互式表格：搜索、排序、筛选
- 专业统计面板

## 🔐 登录信息

```
用户名: user01  密码: password01
用户名: user02  密码: password02
```

## 📊 器官数据分布

| 器官 | 病例数 | 柱状图宽度 |
|------|--------|-----------|
| Lung | 620 | 100% |
| Brain | 580 | 95% |
| Bone Marrow and Blood | 520 | 85% |
| Pancreas | 490 | 80% |
| Breast | 460 | 75% |
| Ovary | 430 | 70% |
| Colorectal | 370 | 60% |
| Head and Neck | 340 | 55% |
| Kidney | 310 | 50% |
| Liver | 280 | 45% |
| Uterus | 250 | 40% |
| Stomach | 150 | 25% |

## 🌐 访问地址

启动后在浏览器中访问：
```
http://localhost:3838
```

## 📱 响应式支持

- **桌面端**: 左右双面板布局
- **移动端**: 垂直单列布局
- **平板端**: 自适应调整

## 🎨 设计参考

本应用参考了 [PDC (Proteomic Data Commons)](https://proteomic.datacommons.cancer.gov/pdc/) 的专业医学数据库设计风格，提供了直观、现代化的数据可视化体验。

## 📝 技术栈

- **后端**: R Shiny
- **前端**: HTML5, CSS3, JavaScript
- **数据**: DataTables, data.table
- **认证**: shinymanager
- **样式**: 自定义CSS + Bootstrap

---

**享受您的PDC风格医学数据可视化体验！** 🏥📊
