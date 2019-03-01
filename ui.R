## ui file for the sankey diagram of cluster methods

## date created 01/03/19

pageWithSidebar(
  headerPanel('Cluster analysis methods used for subtyping asthma'),
  sidebarPanel(
    #### text
    includeText("intro.txt"),
    hr(),
    selectInput('data_type', 
                'Data type', 
                levels(sankey_data$Variable_types_clean)
                )
  ),
  mainPanel(
    sankeyNetworkOutput('plot1')
  )
)