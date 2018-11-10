
header <- dashboardHeader(title = "Datos INEI")

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Mapa", tabName = "mapa", icon = icon("map")),
    menuItem("Cuadros", icon = icon("table"), tabName = "cuadros",
             badgeLabel = "nuevo", badgeColor = "green")
  )
)

body <- dashboardBody(
  tabItems(
    tabItem(tabName = "mapa",
            tags$style(type = "text/css", "#mapa {height: calc(100vh - 80px) !important;}"),
            leafletOutput("mapa")
    ),

    tabItem(tabName = "cuadros",
      h2("Datos en el Mapa"),
      dataTableOutput("cuadro")
    )
  )
)


dashboardPage(
  header,
  sidebar,
  body
)
