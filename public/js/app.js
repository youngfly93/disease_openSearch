// 全局变量
let organStats = {};
let selectedOrgan = null;
let currentDataType = 'modCount';

// 器官颜色配置
const organColors = {
    'lung': '#8B5CF6',
    'brain': '#3B82F6', 
    'bone-marrow': '#F59E0B',
    'pancreas': '#EC4899',
    'breast': '#EF4444',
    'ovary': '#10B981',
    'colorectal': '#F97316',
    'head-neck': '#84CC16',
    'kidney': '#06B6D4',
    'liver': '#8B5CF6',
    'uterus': '#EF4444',
    'stomach': '#FBBF24'
};

// DOM元素
const loadingOverlay = document.getElementById('loading-overlay');
const chartContainer = document.getElementById('chart-container');
const selectedOrganName = document.getElementById('selected-organ-name');
const selectedOrganInfo = document.getElementById('selected-organ-info');
const viewDetailsBtn = document.getElementById('view-details-btn');
const dataModal = document.getElementById('data-modal');
const modalTitle = document.getElementById('modal-title');
const dataContent = document.getElementById('data-content');


// 初始化应用
document.addEventListener('DOMContentLoaded', async () => {
    console.log('🚀 PDC-Style Medical Visualization Loading...');
    
    try {
        // 加载器官统计数据
        await loadOrganStats();
        
        // 渲染图表
        renderChart();
        
        // 设置事件监听器
        setupEventListeners();
        
        // 隐藏加载覆盖层
        hideLoading();
        
        console.log('✅ Application loaded successfully');
    } catch (error) {
        console.error('❌ Error loading application:', error);
        hideLoading();
    }
});

// 加载器官统计数据
async function loadOrganStats() {
    try {
        const response = await fetch('/api/organ-stats');
        organStats = await response.json();
        console.log('📊 Organ stats loaded:', Object.keys(organStats).length, 'organs');
    } catch (error) {
        console.error('Error loading organ stats:', error);
        // 使用默认数据
        organStats = getDefaultOrganStats();
    }
}

// 默认器官数据
function getDefaultOrganStats() {
    return {
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
}

// 渲染图表
function renderChart(sortBy = 'cases') {
    const sortedOrgans = Object.entries(organStats).sort((a, b) => {
        if (sortBy === 'cases') {
            return b[1].cases - a[1].cases;
        } else {
            return a[1].name.localeCompare(b[1].name);
        }
    });
    
    const maxCases = Math.max(...Object.values(organStats).map(o => o.cases));
    
    chartContainer.innerHTML = '';
    
    sortedOrgans.forEach(([organId, data], index) => {
        const percentage = (data.cases / maxCases) * 100;
        const color = organColors[organId] || '#6B7280';
        
        const chartItem = document.createElement('div');
        chartItem.className = 'chart-item';
        chartItem.dataset.organ = organId;
        chartItem.style.animationDelay = `${index * 0.1}s`;
        chartItem.style.cursor = 'pointer';

        chartItem.innerHTML = `
            <div class="organ-name">${data.name}</div>
            <div class="chart-bar-container">
                <div class="chart-bar" style="
                    width: ${percentage}%;
                    --bar-color: ${color};
                    --bar-color-light: ${color}88;
                "></div>
            </div>
            <div class="organ-count">${data.cases}</div>
        `;

        // 添加直接的点击事件监听器
        chartItem.addEventListener('click', (e) => {
            e.stopPropagation();
            // 直接跳转到数据详情页面
            window.location.href = `/data-detail.html?organ=${organId}`;
        });

        chartContainer.appendChild(chartItem);
    });
}

// 设置事件监听器
function setupEventListeners() {
    // 器官区域点击事件
    document.querySelectorAll('.organ-area').forEach(area => {
        area.addEventListener('click', (e) => {
            const organId = e.target.dataset.organ;
            selectOrgan(organId);
        });
        

    });
    
    // 图表项点击事件
    chartContainer.addEventListener('click', (e) => {
        const chartItem = e.target.closest('.chart-item');
        if (chartItem) {
            const organId = chartItem.dataset.organ;
            // 跳转到数据详情页面
            window.location.href = `/data-detail.html?organ=${organId}`;
        }
    });
    
    // 排序按钮
    document.querySelectorAll('.control-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            document.querySelectorAll('.control-btn').forEach(b => b.classList.remove('active'));
            e.target.classList.add('active');
            
            const sortBy = e.target.dataset.sort;
            renderChart(sortBy);
        });
    });
    
    // 查看详情按钮
    viewDetailsBtn.addEventListener('click', () => {
        if (selectedOrgan) {
            // 跳转到数据详情页面
            window.location.href = `/data-detail.html?organ=${selectedOrgan}`;
        }
    });
    
    // 模态框关闭
    document.getElementById('close-modal').addEventListener('click', hideDataModal);
    dataModal.addEventListener('click', (e) => {
        if (e.target === dataModal) {
            hideDataModal();
        }
    });
    
    // 数据类型标签
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            e.target.classList.add('active');
            
            currentDataType = e.target.dataset.type;
            if (selectedOrgan) {
                loadOrganData(selectedOrgan, currentDataType);
            }
        });
    });
    
    // ESC键关闭模态框
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && dataModal.style.display === 'block') {
            hideDataModal();
        }
    });
}

// 选择器官
function selectOrgan(organId) {
    selectedOrgan = organId;
    const organData = organStats[organId];
    
    if (!organData) return;
    
    // 更新UI选中状态
    document.querySelectorAll('.organ-area').forEach(area => {
        area.classList.remove('selected');
    });
    document.querySelectorAll('.chart-item').forEach(item => {
        item.classList.remove('selected');
    });
    
    // 添加选中状态
    document.querySelector(`.organ-area[data-organ="${organId}"]`)?.classList.add('selected');
    document.querySelector(`.chart-item[data-organ="${organId}"]`)?.classList.add('selected');
    
    // 更新信息面板
    selectedOrganName.textContent = organData.name;
    selectedOrganInfo.textContent = `${organData.cases} cases recorded for ${organData.name}. Click "View Detailed Data" to explore the medical data.`;
    viewDetailsBtn.disabled = false;
    
    console.log(`🎯 Selected organ: ${organData.name} (${organData.cases} cases)`);
}



// 显示数据模态框
async function showDataModal(organId) {
    const organData = organStats[organId];
    modalTitle.textContent = `${organData.name} - Medical Data Analysis`;
    
    dataModal.style.display = 'block';
    document.body.style.overflow = 'hidden';
    
    // 加载数据
    await loadOrganData(organId, currentDataType);
}

// 隐藏数据模态框
function hideDataModal() {
    dataModal.style.display = 'none';
    document.body.style.overflow = 'auto';
}

// 加载器官数据
async function loadOrganData(organId, dataType) {
    dataContent.innerHTML = '<div class="loading">Loading data...</div>';
    
    try {
        const response = await fetch(`/api/data/${organId}?type=${dataType}`);
        const result = await response.json();
        
        displayOrganData(result);
    } catch (error) {
        console.error('Error loading organ data:', error);
        dataContent.innerHTML = '<div class="loading">Error loading data. Please try again.</div>';
    }
}

// 显示器官数据
function displayOrganData(result) {
    if (!result.data || result.data.length === 0) {
        dataContent.innerHTML = '<div class="loading">No data available for this organ.</div>';
        return;
    }
    
    const headers = Object.keys(result.data[0]);
    const rows = result.data.slice(0, 50); // 显示前50行
    
    let tableHTML = `
        <div style="margin-bottom: 15px;">
            <strong>Data Type:</strong> ${getDataTypeName(result.dataType)} | 
            <strong>Total Records:</strong> ${result.count} | 
            <strong>Showing:</strong> ${rows.length} records
        </div>
        <table class="data-table">
            <thead>
                <tr>${headers.map(h => `<th>${h}</th>`).join('')}</tr>
            </thead>
            <tbody>
                ${rows.map(row => 
                    `<tr>${headers.map(h => `<td>${row[h] || ''}</td>`).join('')}</tr>`
                ).join('')}
            </tbody>
        </table>
    `;
    
    dataContent.innerHTML = tableHTML;
}

// 获取数据类型名称
function getDataTypeName(type) {
    const names = {
        'modCount': 'Modification Counts',
        'scaleMod': 'Scale Modifications', 
        'siteCount': 'Site Counts'
    };
    return names[type] || type;
}

// 隐藏加载覆盖层
function hideLoading() {
    loadingOverlay.style.display = 'none';
}

// 显示加载覆盖层
function showLoading() {
    loadingOverlay.style.display = 'flex';
}
