# 测试脚本 - 验证应用的基本功能
# 这个脚本可以用来检查应用是否能正常加载和运行

# 检查必要的包是否已安装
required_packages <- c("shiny", "DT", "shinymanager", "data.table")

check_packages <- function() {
  missing_packages <- c()
  
  for (pkg in required_packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      missing_packages <- c(missing_packages, pkg)
    }
  }
  
  if (length(missing_packages) > 0) {
    cat("缺少以下包，请先安装:\n")
    cat(paste(missing_packages, collapse = ", "), "\n")
    cat("安装命令: install.packages(c(", paste0("'", missing_packages, "'", collapse = ", "), "))\n")
    return(FALSE)
  } else {
    cat("所有必要的包都已安装 ✓\n")
    return(TRUE)
  }
}

# 检查数据文件是否存在
check_data_files <- function() {
  data_files <- c(
    "./all_data_kidney_disease_opensearch/Nephropathy_MOD_Count_part.csv",
    "./all_data_kidney_disease_opensearch/Nephropathy_Scale_MOD_part.csv",
    "./all_data_kidney_disease_opensearch/Nephropathy_Site_Count_part.csv"
  )
  
  missing_files <- c()
  
  for (file in data_files) {
    if (!file.exists(file)) {
      missing_files <- c(missing_files, file)
    }
  }
  
  if (length(missing_files) > 0) {
    cat("缺少以下数据文件:\n")
    cat(paste(missing_files, collapse = "\n"), "\n")
    return(FALSE)
  } else {
    cat("所有数据文件都存在 ✓\n")
    return(TRUE)
  }
}

# 检查静态文件
check_static_files <- function() {
  static_files <- c("www/background.png", "www/image.jpg")
  
  missing_files <- c()
  
  for (file in static_files) {
    if (!file.exists(file)) {
      missing_files <- c(missing_files, file)
    }
  }
  
  if (length(missing_files) > 0) {
    cat("缺少以下静态文件:\n")
    cat(paste(missing_files, collapse = "\n"), "\n")
    cat("注意: background.png 是必需的，image.jpg 是可选的\n")
    return(FALSE)
  } else {
    cat("所有静态文件都存在 ✓\n")
    return(TRUE)
  }
}

# 测试数据加载
test_data_loading <- function() {
  tryCatch({
    library(data.table)
    
    # 尝试加载数据
    table1 <- fread('./all_data_kidney_disease_opensearch/Nephropathy_MOD_Count_part.csv')
    table2 <- fread('./all_data_kidney_disease_opensearch/Nephropathy_Scale_MOD_part.csv')
    table3 <- fread('./all_data_kidney_disease_opensearch/Nephropathy_Site_Count_part.csv')
    
    cat("数据加载测试:\n")
    cat("Table 1 - 行数:", nrow(table1), "列数:", ncol(table1), "\n")
    cat("Table 2 - 行数:", nrow(table2), "列数:", ncol(table2), "\n")
    cat("Table 3 - 行数:", nrow(table3), "列数:", ncol(table3), "\n")
    cat("数据加载成功 ✓\n")
    return(TRUE)
  }, error = function(e) {
    cat("数据加载失败:", e$message, "\n")
    return(FALSE)
  })
}

# 运行所有测试
run_tests <- function() {
  cat("=== 应用测试开始 ===\n\n")
  
  tests_passed <- 0
  total_tests <- 4
  
  if (check_packages()) tests_passed <- tests_passed + 1
  cat("\n")
  
  if (check_data_files()) tests_passed <- tests_passed + 1
  cat("\n")
  
  if (check_static_files()) tests_passed <- tests_passed + 1
  cat("\n")
  
  if (test_data_loading()) tests_passed <- tests_passed + 1
  cat("\n")
  
  cat("=== 测试结果 ===\n")
  cat("通过测试:", tests_passed, "/", total_tests, "\n")
  
  if (tests_passed == total_tests) {
    cat("✓ 所有测试通过！应用应该可以正常运行。\n")
    cat("运行应用: shiny::runApp('app.R')\n")
  } else {
    cat("✗ 有测试失败，请检查上述问题后再运行应用。\n")
  }
}

# 测试新的PDC风格界面
test_pdc_interface <- function() {
  cat("=== PDC风格界面测试 ===\n")

  # 检查CSS样式是否正确定义
  app_content <- readLines("app.R", warn = FALSE)

  # 检查关键CSS类
  css_classes <- c(
    "main-container", "human-body-section", "chart-section",
    "organ-highlight", "organ-list", "organ-item"
  )

  missing_classes <- c()
  for (class_name in css_classes) {
    if (!any(grepl(class_name, app_content))) {
      missing_classes <- c(missing_classes, class_name)
    }
  }

  if (length(missing_classes) == 0) {
    cat("✓ 所有CSS类都已定义\n")
  } else {
    cat("✗ 缺少CSS类:", paste(missing_classes, collapse = ", "), "\n")
  }

  # 检查器官映射
  organ_ids <- c("brain", "lung", "heart", "liver", "kidney", "pancreas")
  missing_organs <- c()

  for (organ in organ_ids) {
    if (!any(grepl(paste0('id="', organ, '"'), app_content))) {
      missing_organs <- c(missing_organs, organ)
    }
  }

  if (length(missing_organs) == 0) {
    cat("✓ 所有器官区域都已定义\n")
  } else {
    cat("✗ 缺少器官定义:", paste(missing_organs, collapse = ", "), "\n")
  }

  # 检查JavaScript交互
  if (any(grepl("organ_selected", app_content)) && any(grepl("organ_detail_view", app_content))) {
    cat("✓ JavaScript交互事件已定义\n")
  } else {
    cat("✗ JavaScript交互事件缺失\n")
  }

  return(length(missing_classes) == 0 && length(missing_organs) == 0)
}

# 运行所有测试
run_tests()
cat("\n")
test_pdc_interface()
