const express = require('express');
const path = require('path');
const fs = require('fs');
const csv = require('csv-parser');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3001;

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// 数据存储
let medicalData = {
  modCount: [],
  scaleMod: [],
  siteCount: []
};

// 加载CSV数据
function loadCSVData() {
  const dataFiles = [
    { file: 'all_data_kidney_disease_opensearch/Nephropathy_MOD_Count.csv', key: 'modCount' },
    { file: 'all_data_kidney_disease_opensearch/Nephropathy_Scale_MOD.csv', key: 'scaleMod' },
    { file: 'all_data_kidney_disease_opensearch/Nephropathy_Site_Count.csv', key: 'siteCount' }
  ];

  dataFiles.forEach(({ file, key }) => {
    if (fs.existsSync(file)) {
      console.log(`Loading ${file}...`);
      fs.createReadStream(file)
        .pipe(csv())
        .on('data', (row) => {
          medicalData[key].push(row);
        })
        .on('end', () => {
          console.log(`✓ ${file} loaded successfully (${medicalData[key].length} rows)`);
        })
        .on('error', (err) => {
          console.error(`Error loading ${file}:`, err);
        });
    } else {
      console.warn(`Warning: ${file} not found`);
    }
  });
}

// API路由
app.get('/api/data/:organ', (req, res) => {
  const organ = req.params.organ;
  const dataType = req.query.type || 'modCount';
  
  console.log(`API request for organ: ${organ}, type: ${dataType}`);
  
  // 根据器官过滤数据（这里可以根据实际数据结构调整）
  const data = medicalData[dataType] || [];
  
  res.json({
    organ: organ,
    dataType: dataType,
    count: data.length,
    data: data.slice(0, 1000) // 暂时限制为1000行进行测试
  });
});

// 获取所有数据类型
app.get('/api/data-types', (req, res) => {
  res.json({
    modCount: medicalData.modCount.length,
    scaleMod: medicalData.scaleMod.length,
    siteCount: medicalData.siteCount.length
  });
});

// 器官统计数据
app.get('/api/organ-stats', (req, res) => {
  const organStats = {
    'lung': { name: 'Lung', cases: 620, color: '#8B5CF6' },
    'brain': { name: 'Brain', cases: 580, color: '#3B82F6' },
    'bone-marrow': { name: 'Bone Marrow and Blood', cases: 520, color: '#F59E0B' },
    'pancreas': { name: 'Pancreas', cases: 490, color: '#EC4899' },
    'breast': { name: 'Breast', cases: 460, color: '#EF4444' },
    'ovary': { name: 'Ovary', cases: 430, color: '#10B981' },
    'colorectal': { name: 'Colorectal', cases: 370, color: '#F97316' },
    'head-neck': { name: 'Head and Neck', cases: 340, color: '#84CC16' },
    'kidney': { name: 'Kidney', cases: 310, color: '#06B6D4' },
    'liver': { name: 'Liver', cases: 280, color: '#8B5CF6' },
    'uterus': { name: 'Uterus', cases: 250, color: '#EF4444' },
    'stomach': { name: 'Stomach', cases: 150, color: '#FBBF24' }
  };
  
  res.json(organStats);
});

// 主页路由
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// 启动服务器
app.listen(PORT, () => {
  console.log('=== PDC-Style Medical Data Visualization ===');
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log('📊 Loading medical data...');
  
  // 加载数据
  loadCSVData();
  
  console.log('✅ Server ready!');
});

module.exports = app;
