# PDC风格医学数据可视化系统

## 🎯 项目概述

这是一个基于Node.js和现代Web技术构建的交互式医学数据可视化系统，完美复现了PDC (Proteomic Data Commons) 的专业设计风格。

### ✨ 主要特性

- **🏥 PDC风格界面**: 专业的医学数据库设计风格
- **🖼️ 交互式人体图**: 使用background.png作为全屏背景的可点击器官区域
- **📊 实时柱状图**: 右侧覆盖显示器官病例数据，点击跳转详情页面
- **📋 数据详情页面**: 独立页面展示完整的医疗数据表格
- **🔍 多数据类型**: 支持MOD Count、Scale MOD、Site Count三种数据
- **🔎 搜索过滤**: 表格内容实时搜索和分页显示
- **💾 数据导出**: 支持CSV格式数据导出
- **🎨 现代化设计**: 蓝色渐变背景 + 毛玻璃效果
- **📱 响应式布局**: 支持桌面和移动设备
- **⚡ 高性能**: Node.js后端 + 原生JavaScript前端

## 🚀 快速开始

### 1. 安装依赖
```bash
npm install
```

### 2. 启动服务器
```bash
npm start
# 或者开发模式
npm run dev
```

### 3. 访问应用
打开浏览器访问: http://localhost:3000

## 🏗️ 项目结构

```
├── server.js              # Node.js服务器
├── package.json           # 项目配置
├── public/                # 前端静态文件
│   ├── index.html         # 主页面
│   ├── css/
│   │   └── style.css      # 样式文件
│   ├── js/
│   │   └── app.js         # 前端逻辑
│   └── images/
│       └── background.png # 人体背景图
└── all_data_kidney_disease_opensearch/  # 数据文件目录
    ├── Nephropathy_MOD_Count_part.csv
    ├── Nephropathy_Scale_MOD_part.csv
    └── Nephropathy_Site_Count_part.csv
```

## 🎮 使用指南

### 界面布局
```
┌─────────────────────────────────────────────────────────┐
│                    标题区域                              │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [全屏背景图片 - background.png]                        │
│                                    ┌─────────────────┐  │
│  [透明点击区域覆盖在器官位置]        │  Number of Cases │  │
│                                    │ ████████ Lung   │  │
│                                    │ ███████  Brain  │  │
│                                    │ ██████   Kidney │  │
│                                    │ █████    Liver  │  │
│                                    │ ...更多器官     │  │
│                                    │                 │  │
│                                    │ Selected Organ  │  │
│                                    │ [View Details]  │  │
│                                    └─────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 交互功能

1. **器官选择**
   - 点击左侧人体图上的器官区域
   - 或直接点击右侧柱状图中的器官条目
   - 点击后直接跳转到数据详情页面

2. **数据详情页面**
   - 显示选中器官的完整医疗数据表格
   - 三个数据类型标签：MOD Count、Scale MOD、Site Count
   - 实时搜索功能：在搜索框输入关键词过滤数据
   - 分页显示：每页显示50行数据
   - 数据导出：点击"Export CSV"下载当前筛选的数据
   - 返回主页：点击"Back to Overview"返回主界面

3. **排序功能**（主页面）
   - "Sort by Cases": 按病例数量排序
   - "Sort by Name": 按器官名称排序

4. **数据文件说明**
   - 当前所有器官都显示相同的肾脏疾病数据
   - 数据来源：`all_data_kidney_disease_opensearch/` 目录
   - 包含三个CSV文件：Nephropathy_MOD_Count.csv、Nephropathy_Scale_MOD.csv、Nephropathy_Site_Count.csv
   - 后续可为每个器官添加专属数据文件

## 📊 数据结构

### 器官统计数据
| 器官 | 病例数 | 颜色代码 |
|------|--------|----------|
| Lung | 620 | #8B5CF6 |
| Brain | 580 | #3B82F6 |
| Bone Marrow and Blood | 520 | #F59E0B |
| Pancreas | 490 | #EC4899 |
| Breast | 460 | #EF4444 |
| Ovary | 430 | #10B981 |
| Colorectal | 370 | #F97316 |
| Head and Neck | 340 | #84CC16 |
| Kidney | 310 | #06B6D4 |
| Liver | 280 | #8B5CF6 |
| Uterus | 250 | #EF4444 |
| Stomach | 150 | #FBBF24 |

### 数据类型
- **Modification Counts**: 修饰计数数据
- **Scale Modifications**: 规模修饰数据  
- **Site Counts**: 位点计数数据

## 🔧 API接口

### GET /api/organ-stats
获取所有器官的统计数据

### GET /api/data/:organ?type=dataType
获取特定器官的详细数据
- `organ`: 器官ID (如: lung, brain, kidney等)
- `type`: 数据类型 (modCount, scaleMod, siteCount)

### GET /api/data-types
获取可用的数据类型统计

## 🎨 设计特色

### 视觉效果
- **渐变背景**: 深蓝色渐变 (#1e3c72 → #2a5298)
- **毛玻璃效果**: backdrop-filter: blur()
- **发光动画**: 悬停和选中状态的光晕效果
- **平滑过渡**: 所有交互都有流畅的动画

### 响应式设计
- **桌面端**: 左右双面板布局
- **平板端**: 自适应调整
- **移动端**: 垂直单列布局

## 🔍 技术栈

### 后端
- **Node.js**: 服务器运行时
- **Express.js**: Web框架
- **csv-parser**: CSV文件解析
- **cors**: 跨域支持

### 前端
- **原生JavaScript**: 无框架依赖
- **CSS3**: 现代样式特性
- **HTML5**: 语义化标记
- **Inter字体**: 现代化字体

## 🚀 部署说明

### 开发环境
```bash
npm run dev  # 使用nodemon自动重启
```

### 生产环境
```bash
npm start    # 直接启动服务器
```

### 环境变量
- `PORT`: 服务器端口 (默认: 3000)

## 📝 更新日志

### v1.0.0 (2025-07-04)
- ✅ 完成PDC风格界面设计
- ✅ 实现交互式人体图
- ✅ 添加实时柱状图
- ✅ 集成CSV数据处理
- ✅ 响应式设计支持
- ✅ 模态框数据展示

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 📄 许可证

MIT License

---

**享受您的PDC风格医学数据可视化体验！** 🏥📊✨
