# =============================================================================
# HTML report generation
# =============================================================================

generate_html_report <- function(nutr_table,
                                 output_result,
                                 language_output) {

  log_step("n09 [report_html]", "Making report..")
  
  # start report
  dirRepor <- HTMLInitFile(
    output_result,
    filename = "reporte",
    extension = "html",
    HTMLframe = FALSE,
    BackGroundColor = "",
    BackGroundImg = "",
    Title = "Output report",
    CSSFile = "https://www.diversityforrestoration.org/wp-content/themes/d4r/css/reporte_r.css",
    useLaTeX = F,
    useGrid = F
  )
  
  # Agregar los scripts y estilos necesarios
  HTML(paste(
    '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css">',
    '<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>',
    '<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>',
    sep = "\n"
  ), file = dirRepor, append = TRUE)
  
  # Agregar la estructura del modal
  HTML(paste(
    '<div class="modal fade" id="imageModal" tabindex="-1" aria-labelledby="imageModalLabel" aria-hidden="true">',
    '  <div class="modal-dialog modal-dialog-centered">',
    '    <div class="modal-content">',
    '      <div class="modal-header">',
    '        <h5 class="modal-title" id="imageModalLabel"></h5>',
    '        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>',
    "      </div>",
    '      <div class="modal-body">',
    '        <img src="" class="img-fluid" alt="">',
    "      </div>",
    "    </div>",
    "  </div>",
    "</div>",
    sep = "\n"
  ), file = dirRepor, append = TRUE)
  
  # report content wrapper
  HTML('<div class="report-container">', file = dirRepor, append = TRUE)
  
  # title of the report
  HTML(paste0("<h3><b> Diversity for Nutrition </b></h3>"), file = dirRepor, align = "left", row.names = FALSE)
  
  # description of the tool
  captionLab <- "test"
  HTML(captionLab, file = dirRepor, align = "left", row.names = FALSE)
  
  # add filtered table
  HTML(nutr_table, file = dirRepor, align = "left")
  
  # write report
  html_file <- file.path(output_result, "reporte.html")
  
  # read the content of the file
  html_content <- readLines(html_file, encoding = "UTF-8", warn = FALSE)
  html_content <- iconv(html_content, from = "UTF-8", to = "UTF-8", sub = "")
  html_content[is.na(html_content)] <- ""
  
  # insert necessary meta tags after <head>
  meta_tags <- c(
    '<meta charset="UTF-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1">'
  )
  
  # look for the <head> position and add meta tags
  head_pos <- grep("<head>", html_content, fixed = TRUE)
  if (length(head_pos) > 0) {
    html_content <- c(
      html_content[1:head_pos],
      paste0("  ", meta_tags),
      html_content[(head_pos + 1):length(html_content)]
    )
  }
  
  # write the file with the new content
  writeLines(html_content, html_file, useBytes = TRUE)
}