# PDC风格人体疾病数据可视化应用启动脚本

cat("=== PDC风格人体疾病数据可视化应用 ===\n")
cat("正在检查依赖包...\n")

# 检查并加载必要的包
required_packages <- c("shiny", "DT", "shinymanager", "data.table")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("正在安装包:", pkg, "\n")
    install.packages(pkg, repos = "https://cran.rstudio.com/")
    library(pkg, character.only = TRUE)
  } else {
    cat("✓", pkg, "已加载\n")
  }
}

cat("\n=== 应用信息 ===\n")
cat("• 设计风格: PDC (Proteomic Data Commons) 风格\n")
cat("• 布局: 左侧人体图 + 右侧柱状图\n")
cat("• 交互: 单击选择，双击查看详情\n")
cat("• 登录信息: user01/password01 或 user02/password02\n")

cat("\n启动Shiny应用...\n")
cat("应用将在浏览器中打开: http://localhost:3838\n")

# 启动应用
shiny::runApp("app.R", port = 3838, host = "127.0.0.1", launch.browser = TRUE)
