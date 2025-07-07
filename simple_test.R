# 简单的语法检查测试
cat("=== 应用语法检查 ===\n")

# 检查app.R文件是否存在
if (file.exists("app.R")) {
  cat("✓ app.R 文件存在\n")
} else {
  cat("✗ app.R 文件不存在\n")
  stop("app.R文件缺失")
}

# 尝试解析R代码
tryCatch({
  parse("app.R")
  cat("✓ app.R 语法检查通过\n")
}, error = function(e) {
  cat("✗ app.R 语法错误:", e$message, "\n")
})

# 检查数据文件
data_files <- c(
  "all_data_kidney_disease_opensearch/Nephropathy_MOD_Count_part.csv",
  "all_data_kidney_disease_opensearch/Nephropathy_Scale_MOD_part.csv", 
  "all_data_kidney_disease_opensearch/Nephropathy_Site_Count_part.csv"
)

for (file in data_files) {
  if (file.exists(file)) {
    cat("✓", basename(file), "存在\n")
  } else {
    cat("✗", basename(file), "缺失\n")
  }
}

# 检查背景图片
if (file.exists("www/background.png")) {
  cat("✓ 背景图片存在\n")
} else {
  cat("✗ 背景图片缺失\n")
}

cat("\n=== 测试完成 ===\n")
cat("如果所有检查都通过，可以尝试运行: shiny::runApp('app.R')\n")
