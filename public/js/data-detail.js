// 全局变量
let currentOrgan = '';
let currentDataType = 'modCount';
let allData = {};
let filteredData = [];
let currentPage = 1;
const rowsPerPage = 50;

// DOM元素
const loadingOverlay = document.getElementById('loading-overlay');
const organNameEl = document.getElementById('organ-name');
const organCasesEl = document.getElementById('organ-cases');
const tableTitle = document.getElementById('table-title');
const tableHead = document.getElementById('table-head');
const tableBody = document.getElementById('table-body');
const searchInput = document.getElementById('search-input');
const prevPageBtn = document.getElementById('prev-page');
const nextPageBtn = document.getElementById('next-page');
const pageInfo = document.getElementById('page-info');
const totalRowsEl = document.getElementById('total-rows');

// 器官名称映射
const organNames = {
    'lung': 'Lung',
    'brain': 'Brain',
    'bone-marrow': 'Bone Marrow and Blood',
    'pancreas': 'Pancreas',
    'breast': 'Breast',
    'ovary': 'Ovary',
    'colorectal': 'Colorectal',
    'head-neck': 'Head and Neck',
    'kidney': 'Kidney',
    'liver': 'Liver',
    'uterus': 'Uterus',
    'stomach': 'Stomach'
};

// 数据类型标题映射
const dataTypeTitles = {
    'modCount': 'MOD Count Data',
    'scaleMod': 'Scale MOD Data',
    'siteCount': 'Site Count Data'
};

// 初始化
document.addEventListener('DOMContentLoaded', async () => {
    // 从URL参数获取器官信息
    const urlParams = new URLSearchParams(window.location.search);
    currentOrgan = urlParams.get('organ') || 'kidney';
    
    // 更新页面标题和器官信息
    updatePageInfo();
    
    try {
        // 加载数据
        await loadAllData();

        // 检查是否有数据加载成功
        const hasData = Object.values(allData).some(data => data && data.length > 0);
        if (!hasData) {
            throw new Error('No data was loaded successfully');
        }

        // 设置事件监听器
        setupEventListeners();

        // 显示初始数据
        displayData();

        // 隐藏加载覆盖层
        hideLoading();
    } catch (error) {
        console.error('Error loading data:', error);
        hideLoading();
        showError(`Failed to load medical data: ${error.message}. Please try again later.`);
    }
});

// 更新页面信息
function updatePageInfo() {
    const organDisplayName = organNames[currentOrgan] || currentOrgan;
    organNameEl.textContent = organDisplayName;
    document.getElementById('page-title').textContent = `${organDisplayName} - Medical Data`;
}

// 加载所有数据
async function loadAllData() {
    const dataTypes = ['modCount', 'scaleMod', 'siteCount'];

    console.log(`Loading data for organ: ${currentOrgan}`);

    for (const dataType of dataTypes) {
        try {
            const url = `/api/data/${currentOrgan}?type=${dataType}`;
            console.log(`Fetching: ${url}`);

            const response = await fetch(url);
            console.log(`Response status for ${dataType}:`, response.status);

            if (response.ok) {
                const result = await response.json();
                console.log(`API response for ${dataType}:`, result);

                allData[dataType] = result.data || [];
                console.log(`Loaded ${dataType}:`, allData[dataType].length, 'records');
            } else {
                const errorText = await response.text();
                console.error(`Failed to load ${dataType} data. Status: ${response.status}, Error: ${errorText}`);
                allData[dataType] = [];
            }
        } catch (error) {
            console.error(`Error loading ${dataType}:`, error);
            allData[dataType] = [];
        }
    }

    // 更新案例数量（使用modCount数据的长度）
    const totalCases = allData.modCount ? allData.modCount.length : 0;
    organCasesEl.textContent = `${totalCases} cases`;

    console.log('All data loaded:', allData);
}

// 设置事件监听器
function setupEventListeners() {
    // 标签切换
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            e.target.classList.add('active');
            
            currentDataType = e.target.dataset.type;
            tableTitle.textContent = dataTypeTitles[currentDataType];
            currentPage = 1;
            displayData();
        });
    });
    
    // 搜索功能
    searchInput.addEventListener('input', (e) => {
        filterData(e.target.value);
        currentPage = 1;
        displayData();
    });
    
    // 分页按钮
    prevPageBtn.addEventListener('click', () => {
        if (currentPage > 1) {
            currentPage--;
            displayData();
        }
    });
    
    nextPageBtn.addEventListener('click', () => {
        const totalPages = Math.ceil(filteredData.length / rowsPerPage);
        if (currentPage < totalPages) {
            currentPage++;
            displayData();
        }
    });
}

// 过滤数据
function filterData(searchTerm) {
    const data = allData[currentDataType] || [];
    
    if (!searchTerm.trim()) {
        filteredData = [...data];
        return;
    }
    
    const term = searchTerm.toLowerCase();
    filteredData = data.filter(row => {
        return Object.values(row).some(value => 
            String(value).toLowerCase().includes(term)
        );
    });
}

// 显示数据
function displayData() {
    const data = allData[currentDataType] || [];
    
    // 如果没有搜索，显示所有数据
    if (!searchInput.value.trim()) {
        filteredData = [...data];
    }
    
    // 生成表头
    generateTableHeader(data);
    
    // 生成表格内容
    generateTableBody();
    
    // 更新分页信息
    updatePagination();
}

// 生成表头
function generateTableHeader(data) {
    if (!data || data.length === 0) {
        tableHead.innerHTML = '<tr><th>No data available</th></tr>';
        return;
    }
    
    const headers = Object.keys(data[0]);
    const headerRow = headers.map(header => `<th>${header}</th>`).join('');
    tableHead.innerHTML = `<tr>${headerRow}</tr>`;
}

// 生成表格内容
function generateTableBody() {
    if (!filteredData || filteredData.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="100%" style="text-align: center; padding: 40px; color: #94a3b8;">No data found</td></tr>';
        return;
    }
    
    const startIndex = (currentPage - 1) * rowsPerPage;
    const endIndex = startIndex + rowsPerPage;
    const pageData = filteredData.slice(startIndex, endIndex);
    
    const rows = pageData.map(row => {
        const cells = Object.values(row).map(value => `<td>${value || '-'}</td>`).join('');
        return `<tr>${cells}</tr>`;
    }).join('');
    
    tableBody.innerHTML = rows;
}

// 更新分页信息
function updatePagination() {
    const totalPages = Math.ceil(filteredData.length / rowsPerPage);
    
    prevPageBtn.disabled = currentPage <= 1;
    nextPageBtn.disabled = currentPage >= totalPages;
    
    pageInfo.textContent = `Page ${currentPage} of ${totalPages}`;
    totalRowsEl.textContent = `${filteredData.length} rows total`;
}

// 导出数据
function exportData() {
    const data = filteredData;
    if (!data || data.length === 0) {
        alert('No data to export');
        return;
    }
    
    // 生成CSV内容
    const headers = Object.keys(data[0]);
    const csvContent = [
        headers.join(','),
        ...data.map(row => headers.map(header => `"${row[header] || ''}"`).join(','))
    ].join('\n');
    
    // 下载文件
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', `${currentOrgan}_${currentDataType}_data.csv`);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

// 返回主页
function goBack() {
    window.location.href = '/';
}

// 隐藏加载覆盖层
function hideLoading() {
    loadingOverlay.style.display = 'none';
}

// 显示错误信息
function showError(message) {
    const errorDiv = document.createElement('div');
    errorDiv.style.cssText = `
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: rgba(220, 38, 38, 0.9);
        color: white;
        padding: 20px 30px;
        border-radius: 10px;
        font-size: 16px;
        z-index: 10000;
        backdrop-filter: blur(10px);
    `;
    errorDiv.textContent = message;
    document.body.appendChild(errorDiv);
    
    setTimeout(() => {
        document.body.removeChild(errorDiv);
    }, 5000);
}
