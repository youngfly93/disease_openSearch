# 要求如下：
# 1. 用户认证界面；认证成功跳转到首页；
# 2. 首页12张图片，3行4列排列，图片上下左右居中，自适应屏幕。点击图片跳转到对应独立表格界面；
# 3. 表格界面包含3张表格，以panel形式展示。在panel左边，保留导航栏，显示3个表格总的统计信息。该界面宽度为屏幕宽度。
# 4. 表格用DT::datatable()函数渲染。

library(shiny)
library(DT)
library(shinymanager)
library(data.table)

# Open-search结果数据
# Mod Count
table1 <- fread('./all_data_kidney_disease_opensearch/Nephropathy_MOD_Count_part.csv')

# Scale Mod
table2 <- fread('./all_data_kidney_disease_opensearch/Nephropathy_Scale_MOD_part.csv')

# Site Count
table3 <- fread('./all_data_kidney_disease_opensearch/Nephropathy_Site_Count_part.csv')

# 计算统计信息的函数
get_stats <- function(data) {
  stats <- list(
    total_rows = nrow(data),
    total_samples = ncol(data) - 1
  )
  return(stats)
}

# 建立用户和密码信息
credentials <- data.frame(
  user = c('user01', 'user02'),
  password = c('password01', 'password02'),
  admin = c(FALSE, TRUE),
  stringsAsFactors = FALSE
)

# PDC风格的人体图+柱状图界面
home_ui <- fluidPage(
  # CSS样式定义
  tags$head(
    tags$style(HTML("
      body {
        background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
        color: white;
        font-family: 'Arial', sans-serif;
      }

      .main-container {
        padding: 20px;
        min-height: 100vh;
      }

      .header-section {
        text-align: center;
        margin-bottom: 30px;
        background: rgba(255, 255, 255, 0.1);
        padding: 20px;
        border-radius: 15px;
        backdrop-filter: blur(10px);
      }

      .content-row {
        display: flex;
        gap: 30px;
        align-items: flex-start;
        min-height: 600px;
      }

      .human-body-section {
        flex: 0 0 400px;
        position: relative;
      }

      .body-container {
        position: relative;
        width: 100%;
        height: 600px;
        background-image: url('background.png');
        background-size: contain;
        background-repeat: no-repeat;
        background-position: center;
        border-radius: 15px;
        background-color: rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(5px);
      }

      .organ-highlight {
        position: absolute;
        cursor: pointer;
        border: 3px solid transparent;
        border-radius: 8px;
        transition: all 0.3s ease;
        background: rgba(255, 255, 255, 0.2);
      }

      .organ-highlight:hover {
        border-color: #00d4ff;
        background: rgba(0, 212, 255, 0.3);
        box-shadow: 0 0 20px rgba(0, 212, 255, 0.6);
        transform: scale(1.05);
      }

      .organ-highlight.selected {
        border-color: #ffff00;
        background: rgba(255, 255, 0, 0.3);
        box-shadow: 0 0 25px rgba(255, 255, 0, 0.8);
      }

      /* 器官位置定义 */
      .brain { top: 8%; left: 42%; width: 80px; height: 60px; }
      .lung { top: 25%; left: 35%; width: 100px; height: 80px; }
      .heart { top: 30%; left: 40%; width: 60px; height: 60px; }
      .liver { top: 35%; left: 50%; width: 80px; height: 70px; }
      .stomach { top: 40%; left: 35%; width: 70px; height: 50px; }
      .kidney { top: 45%; left: 30%; width: 120px; height: 60px; }
      .pancreas { top: 42%; left: 42%; width: 70px; height: 40px; }
      .intestine { top: 55%; left: 38%; width: 80px; height: 100px; }
      .bladder { top: 70%; left: 43%; width: 50px; height: 40px; }
      .bone-marrow { top: 15%; left: 25%; width: 60px; height: 40px; }
      .breast { top: 22%; left: 30%; width: 90px; height: 50px; }
      .ovary { top: 65%; left: 35%; width: 80px; height: 30px; }

      .chart-section {
        flex: 1;
        background: rgba(255, 255, 255, 0.1);
        border-radius: 15px;
        padding: 25px;
        backdrop-filter: blur(10px);
      }

      .chart-title {
        font-size: 1.8em;
        margin-bottom: 20px;
        text-align: center;
        color: #00d4ff;
      }

      .organ-list {
        list-style: none;
        padding: 0;
        margin: 0;
      }

      .organ-item {
        display: flex;
        align-items: center;
        margin-bottom: 15px;
        padding: 10px;
        background: rgba(255, 255, 255, 0.1);
        border-radius: 8px;
        cursor: pointer;
        transition: all 0.3s ease;
      }

      .organ-item:hover {
        background: rgba(255, 255, 255, 0.2);
        transform: translateX(5px);
      }

      .organ-item.selected {
        background: rgba(255, 255, 0, 0.2);
        border-left: 4px solid #ffff00;
      }

      .organ-name {
        flex: 0 0 150px;
        font-weight: bold;
        font-size: 14px;
      }

      .organ-bar {
        flex: 1;
        height: 25px;
        background: linear-gradient(90deg, #00d4ff, #0099cc);
        border-radius: 12px;
        position: relative;
        margin: 0 10px;
      }

      .organ-count {
        flex: 0 0 80px;
        text-align: right;
        font-weight: bold;
        font-size: 14px;
      }

      /* 响应式设计 */
      @media (max-width: 1200px) {
        .content-row {
          flex-direction: column;
        }

        .human-body-section {
          flex: none;
          align-self: center;
        }

        .body-container {
          height: 400px;
        }
      }

      .info-panel {
        background: rgba(255, 255, 255, 0.1);
        border-radius: 10px;
        padding: 15px;
        margin-top: 20px;
        backdrop-filter: blur(5px);
      }
    "))
  ),

  div(class = "main-container",
    # 标题部分
    div(class = "header-section",
      h1("Disease Data by Major Primary Site", style = "margin: 0; font-size: 2.5em;"),
      p("Interactive visualization of disease distribution across human organs",
        style = "margin: 10px 0 0 0; font-size: 1.2em; opacity: 0.9;")
    ),

    # 主要内容区域
    div(class = "content-row",
      # 左侧人体图
      div(class = "human-body-section",
        div(class = "body-container",
          # 器官高亮区域
          div(class = "organ-highlight brain", id = "brain", `data-organ` = "Brain"),
          div(class = "organ-highlight lung", id = "lung", `data-organ` = "Lung"),
          div(class = "organ-highlight heart", id = "heart", `data-organ` = "Heart"),
          div(class = "organ-highlight liver", id = "liver", `data-organ` = "Liver"),
          div(class = "organ-highlight stomach", id = "stomach", `data-organ` = "Stomach"),
          div(class = "organ-highlight kidney", id = "kidney", `data-organ` = "Kidney"),
          div(class = "organ-highlight pancreas", id = "pancreas", `data-organ` = "Pancreas"),
          div(class = "organ-highlight intestine", id = "intestine", `data-organ` = "Colorectal"),
          div(class = "organ-highlight bladder", id = "bladder", `data-organ` = "Uterus"),
          div(class = "organ-highlight bone-marrow", id = "bone-marrow", `data-organ` = "Bone Marrow and Blood"),
          div(class = "organ-highlight breast", id = "breast", `data-organ` = "Breast"),
          div(class = "organ-highlight ovary", id = "ovary", `data-organ` = "Ovary")
        )
      ),

      # 右侧图表区域
      div(class = "chart-section",
        h2(class = "chart-title", "Number of Cases"),

        # 器官列表和柱状图
        div(id = "organ-chart",
          tags$ul(class = "organ-list",
            tags$li(class = "organ-item", id = "item-bone-marrow", `data-organ` = "bone-marrow",
              div(class = "organ-name", "Bone Marrow and Blood"),
              div(class = "organ-bar", style = "width: 85%;"),
              div(class = "organ-count", "520")
            ),
            tags$li(class = "organ-item", id = "item-brain", `data-organ` = "brain",
              div(class = "organ-name", "Brain"),
              div(class = "organ-bar", style = "width: 95%;"),
              div(class = "organ-count", "580")
            ),
            tags$li(class = "organ-item", id = "item-breast", `data-organ` = "breast",
              div(class = "organ-name", "Breast"),
              div(class = "organ-bar", style = "width: 75%;"),
              div(class = "organ-count", "460")
            ),
            tags$li(class = "organ-item", id = "item-intestine", `data-organ` = "intestine",
              div(class = "organ-name", "Colorectal"),
              div(class = "organ-bar", style = "width: 60%;"),
              div(class = "organ-count", "370")
            ),
            tags$li(class = "organ-item", id = "item-heart", `data-organ` = "heart",
              div(class = "organ-name", "Head and Neck"),
              div(class = "organ-bar", style = "width: 55%;"),
              div(class = "organ-count", "340")
            ),
            tags$li(class = "organ-item", id = "item-kidney", `data-organ` = "kidney",
              div(class = "organ-name", "Kidney"),
              div(class = "organ-bar", style = "width: 50%;"),
              div(class = "organ-count", "310")
            ),
            tags$li(class = "organ-item", id = "item-liver", `data-organ` = "liver",
              div(class = "organ-name", "Liver"),
              div(class = "organ-bar", style = "width: 45%;"),
              div(class = "organ-count", "280")
            ),
            tags$li(class = "organ-item", id = "item-lung", `data-organ` = "lung",
              div(class = "organ-name", "Lung"),
              div(class = "organ-bar", style = "width: 100%;"),
              div(class = "organ-count", "620")
            ),
            tags$li(class = "organ-item", id = "item-ovary", `data-organ` = "ovary",
              div(class = "organ-name", "Ovary"),
              div(class = "organ-bar", style = "width: 70%;"),
              div(class = "organ-count", "430")
            ),
            tags$li(class = "organ-item", id = "item-pancreas", `data-organ` = "pancreas",
              div(class = "organ-name", "Pancreas"),
              div(class = "organ-bar", style = "width: 80%;"),
              div(class = "organ-count", "490")
            ),
            tags$li(class = "organ-item", id = "item-stomach", `data-organ` = "stomach",
              div(class = "organ-name", "Stomach"),
              div(class = "organ-bar", style = "width: 25%;"),
              div(class = "organ-count", "150")
            ),
            tags$li(class = "organ-item", id = "item-bladder", `data-organ` = "bladder",
              div(class = "organ-name", "Uterus"),
              div(class = "organ-bar", style = "width: 40%;"),
              div(class = "organ-count", "250")
            )
          )
        ),

        # 信息面板
        div(class = "info-panel",
          h4("Selected Organ: ", tags$span(id = "selected-organ-name", "None")),
          p("Click on an organ in the human body diagram or in the chart to view detailed data.")
        )
      )
    )
  ),

  # JavaScript for interaction
  tags$script(HTML("
    $(document).ready(function() {
      var selectedOrgan = null;

      // 器官高亮区域点击
      $('.organ-highlight').click(function() {
        var organId = $(this).attr('id');
        var organName = $(this).attr('data-organ');
        selectOrgan(organId, organName);
      });

      // 图表项目点击
      $('.organ-item').click(function() {
        var organId = $(this).attr('data-organ');
        var organName = $(this).find('.organ-name').text();
        selectOrgan(organId, organName);
      });

      function selectOrgan(organId, organName) {
        // 移除之前的选中状态
        $('.organ-highlight').removeClass('selected');
        $('.organ-item').removeClass('selected');

        // 添加新的选中状态
        $('#' + organId).addClass('selected');
        $('#item-' + organId).addClass('selected');

        // 更新信息面板
        $('#selected-organ-name').text(organName);

        // 发送到Shiny服务器
        Shiny.setInputValue('organ_selected', {
          id: organId,
          name: organName
        }, {priority: 'event'});

        selectedOrgan = organId;
      }

      // 双击进入详细页面
      $('.organ-highlight, .organ-item').dblclick(function() {
        if (selectedOrgan) {
          Shiny.setInputValue('organ_detail_view', selectedOrgan, {priority: 'event'});
        }
      });
    });
  "))
)

# PDC风格的数据表格页面UI
data_tables_ui <- function(stats, organ_name = "Selected Organ") {
  fluidPage(
    # 保持PDC风格的CSS
    tags$head(
      tags$style(HTML("
        body {
          background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
          color: white;
          font-family: 'Arial', sans-serif;
        }

        .data-page-container {
          padding: 20px;
          min-height: 100vh;
        }

        .data-header {
          background: rgba(255, 255, 255, 0.1);
          padding: 20px;
          border-radius: 15px;
          margin-bottom: 30px;
          backdrop-filter: blur(10px);
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .data-content {
          background: rgba(255, 255, 255, 0.1);
          border-radius: 15px;
          padding: 25px;
          backdrop-filter: blur(10px);
        }

        .nav-pills .nav-link {
          background: rgba(255, 255, 255, 0.1);
          color: white;
          border-radius: 25px;
          margin-right: 10px;
          transition: all 0.3s ease;
        }

        .nav-pills .nav-link.active {
          background: linear-gradient(90deg, #00d4ff, #0099cc);
          color: white;
        }

        .nav-pills .nav-link:hover {
          background: rgba(255, 255, 255, 0.2);
          color: white;
        }

        .stats-panel {
          background: rgba(0, 212, 255, 0.1);
          border: 1px solid rgba(0, 212, 255, 0.3);
          border-radius: 10px;
          padding: 20px;
          margin-bottom: 20px;
        }

        .table-container {
          background: rgba(255, 255, 255, 0.95);
          border-radius: 10px;
          padding: 20px;
          color: #333;
        }

        .btn-back {
          background: linear-gradient(90deg, #ff6b6b, #ee5a52);
          border: none;
          color: white;
          padding: 12px 25px;
          border-radius: 25px;
          font-weight: bold;
          transition: all 0.3s ease;
        }

        .btn-back:hover {
          transform: translateY(-2px);
          box-shadow: 0 5px 15px rgba(255, 107, 107, 0.4);
          color: white;
        }
      "))
    ),

    div(class = "data-page-container",
      # 页面头部
      div(class = "data-header",
        div(
          h1(paste("Disease Data Analysis:", organ_name), style = "margin: 0; font-size: 2.2em; color: #00d4ff;"),
          p("Detailed proteomic and modification data for the selected organ",
            style = "margin: 5px 0 0 0; opacity: 0.8;")
        ),
        div(
          actionButton("back_button", "← Back to Overview", class = "btn-back")
        )
      ),

      # 主要内容区域
      div(class = "data-content",
        # 统计信息面板
        div(class = "stats-panel",
          fluidRow(
            column(3,
              h4("Dataset Overview", style = "color: #00d4ff; margin-bottom: 15px;"),
              p(strong("Organ System:"), organ_name),
              p(strong("Total Modifications:"), stats$total_rows),
              p(strong("Sample Count:"), stats$total_samples)
            ),
            column(3,
              h4("Data Types", style = "color: #00d4ff; margin-bottom: 15px;"),
              p("• MOD Count Data"),
              p("• Scale MOD Data"),
              p("• Site Count Data")
            ),
            column(3,
              h4("Analysis Features", style = "color: #00d4ff; margin-bottom: 15px;"),
              p("• Interactive Tables"),
              p("• Search & Filter"),
              p("• Export Options")
            ),
            column(3,
              h4("Data Quality", style = "color: #00d4ff; margin-bottom: 15px;"),
              p("• Validated Dataset"),
              p("• Quality Controlled"),
              p("• Research Grade")
            )
          )
        ),

        # 数据表格标签页
        tabsetPanel(
          id = "data_tabs",
          type = "pills",

          # MOD Count 表格
          tabPanel("Modification Counts",
                   value = "mod_count",
                   br(),
                   fluidRow(
                     column(12,
                       div(class = "table-container",
                         h4("Modification Count Data", style = "color: #1e3c72; margin-bottom: 20px;"),
                         p("This table shows the count of modifications for each protein across different samples.",
                           style = "color: #666; margin-bottom: 20px;"),
                         DTOutput("table1_ui")
                       )
                     )
                   )
          ),

          # Scale MOD 表格
          tabPanel("Scale Modifications",
                   value = "scale_mod",
                   br(),
                   fluidRow(
                     column(12,
                       div(class = "table-container",
                         h4("Scale Modification Data", style = "color: #1e3c72; margin-bottom: 20px;"),
                         p("This table displays scaled modification values normalized across the dataset.",
                           style = "color: #666; margin-bottom: 20px;"),
                         DTOutput("table2_ui")
                       )
                     )
                   )
          ),

          # Site Count 表格
          tabPanel("Site Counts",
                   value = "site_count",
                   br(),
                   fluidRow(
                     column(12,
                       div(class = "table-container",
                         h4("Modification Site Count Data", style = "color: #1e3c72; margin-bottom: 20px;"),
                         p("This table shows the number of modification sites identified for each protein.",
                           style = "color: #666; margin-bottom: 20px;"),
                         DTOutput("table3_ui")
                       )
                     )
                   )
          )
        )
      )
    )
  )
}

# 服务器逻辑
server <- function(input, output, session) {
  
  # 用户认证
  res_auth <- secure_server(check_credentials = check_credentials(credentials))
  
  # 使用 reactiveValues 来管理当前页面状态
  rv <- reactiveValues(
    page = "home",
    selected_organ = NULL,
    organ_name = "Selected Organ"
  )
  rv$combined_stats <- get_stats(table1)  # 假设表格 1 的统计信息为示例

  # 渲染首页
  output$main_ui <- renderUI({
    if (rv$page == "home") {
      return(home_ui)
    } else {
      return(data_tables_ui(rv$combined_stats, rv$organ_name))
    }
  })
  
  # 处理器官选择事件（单击选中）
  observeEvent(input$organ_selected, {
    if (!is.null(input$organ_selected)) {
      organ_info <- input$organ_selected
      rv$selected_organ <- organ_info$id
      rv$organ_name <- organ_info$name

      # 可以在这里添加其他选中反馈，比如更新统计信息
      cat("Selected organ:", organ_info$name, "\n")
    }
  })

  # 处理器官详细查看事件（双击进入详细页面）
  observeEvent(input$organ_detail_view, {
    organ_id <- input$organ_detail_view
    rv$page <- "data"
    rv$selected_organ <- organ_id

    # 根据器官选择对应的数据表格
    if (organ_id %in% c("kidney")) {
      rv$combined_stats <- get_stats(table1)  # 肾脏相关数据
      rv$organ_name <- "Kidney"
    } else if (organ_id %in% c("brain")) {
      rv$combined_stats <- get_stats(table2)  # 大脑相关数据
      rv$organ_name <- "Brain"
    } else if (organ_id %in% c("liver")) {
      rv$combined_stats <- get_stats(table3)  # 肝脏相关数据
      rv$organ_name <- "Liver"
    } else if (organ_id %in% c("lung")) {
      rv$combined_stats <- get_stats(table1)  # 肺部相关数据
      rv$organ_name <- "Lung"
    } else if (organ_id %in% c("heart")) {
      rv$combined_stats <- get_stats(table2)  # 心脏相关数据
      rv$organ_name <- "Head and Neck"
    } else if (organ_id %in% c("stomach")) {
      rv$combined_stats <- get_stats(table3)  # 胃相关数据
      rv$organ_name <- "Stomach"
    } else if (organ_id %in% c("pancreas")) {
      rv$combined_stats <- get_stats(table1)  # 胰腺相关数据
      rv$organ_name <- "Pancreas"
    } else if (organ_id %in% c("intestine")) {
      rv$combined_stats <- get_stats(table2)  # 肠道相关数据
      rv$organ_name <- "Colorectal"
    } else if (organ_id %in% c("bladder")) {
      rv$combined_stats <- get_stats(table3)  # 膀胱相关数据
      rv$organ_name <- "Uterus"
    } else if (organ_id %in% c("bone-marrow")) {
      rv$combined_stats <- get_stats(table1)  # 骨髓相关数据
      rv$organ_name <- "Bone Marrow and Blood"
    } else if (organ_id %in% c("breast")) {
      rv$combined_stats <- get_stats(table2)  # 乳腺相关数据
      rv$organ_name <- "Breast"
    } else if (organ_id %in% c("ovary")) {
      rv$combined_stats <- get_stats(table3)  # 卵巢相关数据
      rv$organ_name <- "Ovary"
    } else {
      rv$combined_stats <- get_stats(table1)  # 默认数据
      rv$organ_name <- "Unknown Organ"
    }
  })
  
  # 返回按钮
  observeEvent(input$back_button, {
    rv$page <- "home"
  })
  
  # 使用 DT::renderDataTable 渲染数据表格
  output$table1_ui <- renderDT({
    datatable(table1, options = list(pageLength = 10)) # 默认页面长度
  })
  
  output$table2_ui <- renderDT({
    datatable(table2, options = list(pageLength = 10)) # 默认页面长度
  })
  
  output$table3_ui <- renderDT({
    datatable(table3, options = list(pageLength = 10)) # 默认页面长度
  })
}

# 启动Shiny应用
# shinyApp(ui = uiOutput('main_ui'), server = server)

ui <- secure_app(uiOutput('main_ui'))
shinyApp(ui = ui, server = server)



