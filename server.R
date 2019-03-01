## server file for the sankey diagram of cluster methods

## date created 01/03/19

function(input, output) {
  ####
  ## create a dataset called tmp based on the data_type selection
data <- reactive({
  if (input$data_type == "Categorical") {
    tmp <- sankey_data %>%
      filter(Variable_types_clean == input$data_type) %>%
      select(-Standardisation_continuous) %>%
      rename(Stan = Standardisation_binary)
  } else if (input$data_type == "Continuous") {
    tmp <- sankey_data %>%
      filter(Variable_types_clean == input$data_type) %>%
      select(-Standardisation_binary) %>%
      rename(Stan = Standardisation_continuous)
  } else {
    tmp <- sankey_data %>%
      filter(Variable_types_clean == input$data_type) %>%
      mutate(
        Standardisation_binary = str_c("Cat: ", Standardisation_binary),
        Standardisation_continuous = str_c("Cont: ", Standardisation_continuous),
        Stan = str_c(Standardisation_binary, ", ", Standardisation_continuous)
      ) %>%
      select(-Standardisation_binary, -Standardisation_continuous)
  }
  
  tmp <- tmp %>%
    mutate(Stan = str_c("Rescale: ", Stan))
  ####
  
  ## create a dataset of nodes for the sankey diagram
  nodes <- tmp %>%
    select(Stan, Dissimilarity_clean, Method_clean) %>%
    gather() %>%
    select(value) %>%
    distinct() %>%
    rename(name = value)
  len <- nrow(nodes) - 1
  nodes <- data.frame(nodes, num = 0:len)

  ## create a dataset of links for the sankey diagram
  ## links_data function for transforming the data
  links_data <- function(.data, ...) {
    dots <- enquos(...)
    links <- data.frame(source = double(), target = double(), n = double())
    for (i in 2:length(dots)) {
      j <- i - 1
      V1 <- dots[[j]]
      V2 <- dots[[i]]
      links <- .data %>%
        group_by(!!! V1, !!! V2) %>%
        count()  %>%
        ungroup() %>%
        rename_at(vars(!!! V1), funs(paste("name"))) %>%
        left_join(nodes, by = "name") %>%
        select(source = num, -name, !!! V2, n) %>%
        rename_at(vars(!!! V2), funs(paste("name"))) %>%
        left_join(nodes, by = "name") %>%
        select(source, target = num, -name, n) %>%
        rbind(links)
    }
    return(links)
  }
## apply links_data function to the tmp data
  links <- tmp %>%
    links_data(
      Stan,
      Dissimilarity_clean,
      Method_clean)
  # return
  list(links, nodes)
})

## generate sankey network plot
output$plot1 <- renderSankeyNetwork({
  sankeyNetwork(Links = data()[[1]], Nodes = data()[[2]][1], Source = "source",
                Target = "target", Value = "n", NodeID = "name",
                fontSize = 12, nodeWidth = 30)
})
}
