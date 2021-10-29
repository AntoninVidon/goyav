#' Display visualization product'
#' @import shiny
#' @importFrom shinyjs useShinyjs enable disable
#' @importFrom shinyWidgets pickerInput updatePickerInput
#' @importFrom shinycssloaders withSpinner
#' @importFrom fresh use_theme create_theme bs_vars_navbar
#' @import miniUI
#' @import ggplot2
#' @import gganimate
#' @import ggthemes
#' @import gifski

#' @export

# We'll wrap our Shiny Gadget in an addin.
goyav <- function(data) {
  # acquire relevant variables
  numericvars <- colnames(data)[unlist(lapply(data, is.numeric))]
  factorvars <- colnames(data)[unlist(lapply(data, is.factor))]

  # test if the data set fulfills the right conditions
  if (length(numericvars) < 4) {
    stop("Your dataframe should have at least 4 numeric variables.")
  }

  ui <- fluidPage(
    useShinyjs(),
    navbarPage(
      "Goyav",
      header = use_theme(
        create_theme(
          theme = "default",
          bs_vars_navbar(
            default_bg = "#3379b7",
            default_color = "#FFFFFF",
            default_link_color = "#FFFFFF",
            default_link_active_color = "#FFFFFF",
            default_link_active_bg = "#fa8d4c",
            default_link_hover_color = "firebrick"

          ),
          output_file = NULL
        )
      ),
      tabPanel("Animate", icon = icon("play"),
               fluidRow(
                 column(
                   4,
                   selectInput("xvar", "X variable",
                               choices = numericvars, width = "100%"),
                   selectInput("yvar", "Y variable",
                               choices = numericvars, width = "100%"),
                   selectInput(
                     "sizevar",
                     "Size variable",
                     choices = numericvars,
                     width = "100%"
                   ),
                   selectInput(
                     "colorvar",
                     "Color variable",
                     choices = c("None", factorvars),
                     width = "100%"
                   ),
                   selectInput(
                     "tempvar",
                     "Temporal variable",
                     choices = numericvars,
                     width = "100%"
                   ),
                   selectInput(
                     "logscale",
                     "Apply log-scale to",
                     choices = c("None", "X", "Y", "X and Y"),
                     selected = "None",
                     multiple = FALSE,
                     width = "100%"
                   ),
                   actionButton(
                     inputId = "reset",
                     label = "Reset graph",
                     style = "material-flat;",
                     icon = icon("eraser"),
                     width = "54%"
                   ),
                   actionButton(
                     inputId = "animate",
                     label = "Animate",
                     style = "color: #fff; background-color: #337ab7; border-color: #2e6da4;",
                     icon = icon("photo-video"),
                     width = "44%"
                   )

                   ,
                   align = "center"
                 ),
                 column(8,
                        withSpinner(imageOutput("plot"))),
                 align = "center"
               )),
      tabPanel(
        "Advanced animate", icon = icon("sliders-h"),
        fluidRow(
          column(
            2,
            selectInput(
              "xvaradv",
              "X variable",
              choices = numericvars,
              width = "100%"
            ),
            selectInput(
              "yvaradv",
              "Y variable",
              choices = numericvars,
              width = "100%"
            ),
            selectInput(
              "sizevaradv",
              "Size variable",
              choices = numericvars,
              width = "100%"
            ),
            selectInput(
              "colorvaradv",
              "Color variable",
              choices = c("None", factorvars),
              width = "100%"
            ),
            selectInput(
              "tempvaradv",
              "Temporal variable",
              choices = numericvars,
              width = "100%"
            ),
            selectInput(
              "logscaleadv",
              "Apply log-scale to",
              choices = c("None", "X", "Y", "X and Y"),
              selected = "None",
              multiple = FALSE,
              width = "100%"
            ),
            actionButton(
              inputId = "resetadv",
              label = "Reset graph",
              style = "material-flat;",
              icon = icon("eraser"),
              width = "100%"
            ),

            align = "center"
          ),
          column(
            3,
            sliderInput(
              inputId = "xrangeadv",
              label = "X range",
              min = 0,
              max = 1,
              value = c(0, 1),
              width = "100%"
            )
            ,
            sliderInput(
              inputId = "yrangeadv",
              label = "Y range",
              min = 0,
              max = 1,
              value = c(0, 1),
              width = "100%"
            )
            ,
            sliderInput(
              inputId = "temprangeadv",
              label = "Temporal range",
              min = 0,
              max = 1,
              value = c(0, 1),
              width = "100%"
            )
            ,
            sliderInput(
              inputId = "durationadv",
              label = "Animation duration (s)",
              min = 1,
              max = 20,
              value = 1,
              width = "100%"
            )
            ,
            pickerInput(
              "factorsadv",
              "Choose factor levels",
              multiple = T,
              choices = c(""),
              width = "100%"
            ),

            actionButton(
              inputId = "animateadv",
              label = "Animate",
              style = "color: #fff; background-color: #337ab7; border-color: #2e6da4;",
              icon = icon("photo-video"),
              width = "100%"
            )
            ,
            align = "center"
          ),
          column(7,
                 withSpinner(imageOutput("plotadv"))),
          align = "center"
        )
      )
    ),
  )


  server <- function(input, output, session) {
    # ADVANCED ANIMATE

    disable("resetadv")
    output$plotadv <- renderImage({
      outfile <- tempfile(fileext = '.png')
      png(outfile, width = 400, height = 400)
      dev.off()

      # Return a list containing the filename
      list(
        src = outfile,
        contentType = 'image/png',
        width = 400,
        height = 400
      )

    }, deleteFile = TRUE)  # end of render image

    observeEvent(input$xvaradv, {
      updateSelectInput(session, "yvaradv",
                        choices = numericvars[!numericvars %in% input$xvaradv])
      updateSelectInput(session, "sizevaradv",
                        choices = numericvars[!numericvars %in% c(input$xvaradv, input$yvaradv)])
      updateSelectInput(session, "tempvaradv",
                        choices = numericvars[!numericvars %in% c(input$xvaradv, input$yvaradv, input$sizevaradv)])
      updateSliderInput(
        session,
        "xrangeadv",
        min = min(data[, input$xvaradv]),
        max = max(data[, input$xvaradv]),
        value = c(min(data[, input$xvaradv]), max(data[, input$xvaradv]))
      )
    })
    observeEvent(input$yvaradv, {
      updateSelectInput(session, "sizevaradv",
                        choices = numericvars[!numericvars %in% c(input$xvaradv, input$yvaradv)])
      updateSelectInput(session, "tempvaradv",
                        choices = numericvars[!numericvars %in% c(input$xvaradv, input$yvaradv, input$sizevaradv)])
      updateSliderInput(
        session,
        "yrangeadv",
        min = min(data[, input$yvaradv]),
        max = max(data[, input$yvaradv]),
        value = c(min(data[, input$yvaradv]), max(data[, input$yvaradv]))
      )

    })
    observeEvent(input$sizevaradv, {
      updateSelectInput(session, "tempvaradv",
                        choices = numericvars[!numericvars %in% c(input$xvaradv, input$yvaradv, input$sizevaradv)])
    })
    observeEvent(input$colorvaradv, {
      if (input$colorvaradv == "None") {
        updatePickerInput(session, "factorsadv",
                          choices = c(""))
      }
      else{
        updatePickerInput(
          session,
          "factorsadv",
          choices = levels(data[[input$colorvaradv]]),
          selected = unique(data[[input$colorvaradv]])
        )
      }
    })
    observe({
      if (input$xvaradv == "" ||
          input$yvaradv == "" ||
          is.na(input$yvaradv) || is.na(input$xvaradv)) {
        disable("animateadv")
      }
      else{
        enable("animateadv")
      }
    })
    observeEvent(input$tempvaradv, {
      updateSliderInput(
        session,
        "temprangeadv",
        min = min(data[, input$tempvaradv]),
        max = max(data[, input$tempvaradv]),
        value = c(min(data[, input$tempvaradv]), max(data[, input$tempvaradv]))
      )
    })
    # Handle the plot button being pressed.
    observeEvent(input$animateadv, {
      disable("animateadv")
      disable("resetadv")
      disable("xvaradv")
      disable("yvaradv")
      disable("sizevaradv")
      disable("colorvaradv")
      disable("tempvaradv")
      disable("xrangeadv")
      disable("yrangeadv")
      disable("temprangeadv")
      disable("durationadv")
      disable("factorsadv")
      disable("logscaleadv")

      output$plotadv <- renderImage({
        # A temp file to save the output.
        # This file will be removed later by renderImage
        outfile <- tempfile(fileext = '.gif')

        dataplot <-
          data[data[, input$tempvaradv] >= input$temprangeadv[1] &
                 data[, input$tempvaradv] <= input$temprangeadv[2] ,]

        if (input$colorvaradv != "None") {
          dataplot <-
            dataplot[dataplot[[input$colorvaradv]] %in% input$factorsadv,]
        }

        # now make the animation
        padv = ggplot(
          dataplot,
          aes_string(
            x = input$xvaradv,
            y = input$yvaradv,
            size = input$sizevaradv,
            colour = ifelse(input$colorvaradv == "None", "NULL", input$colorvaradv)
          )
        ) + geom_point() +
          gganimate::transition_time(dataplot[[input$tempvaradv]]) +
          labs(title = paste(c(
            input$tempvaradv, ": {frame_time}"
          ), collapse = " ")) +
          geom_point(alpha = 0.8, stroke = 0) +
          coord_cartesian(xlim = input$xrangeadv,
                          ylim = input$yrangeadv) +
          scale_size(range = c(2, 12)) +
          ggthemes::theme_gdocs() +
          theme(
            axis.title = element_text(),
            legend.text = element_text(size = 12),
            plot.background = element_blank()
          ) +
          scale_color_brewer(palette = "Set2")

        if (input$logscaleadv == "X") {
          padv <- padv + scale_x_log10()
        }
        else if (input$logscaleadv == "Y") {
          padv <- padv + scale_y_log10()
        }
        else if (input$logscaleadv == "X and Y") {
          padv <- padv + scale_x_log10() + scale_y_log10()
        }

        gganimate::anim_save(
          "outfile.gif",
          gganimate::animate(
            padv,
            renderer = gganimate::gifski_renderer(),
            duration = input$durationadv
          )
        )


        # Return a list containing the filename
        list(src = "outfile.gif",
             contentType = 'image/gif',
             height = 500)
      }, deleteFile = TRUE)

      enable("resetadv")

    })

    observeEvent(input$resetadv, {
      disable("resetadv")
      enable("xvaradv")
      enable("yvaradv")
      enable("sizevaradv")
      enable("colorvaradv")
      enable("tempvaradv")
      enable("xrangeadv")
      enable("yrangeadv")
      enable("temprangeadv")
      enable("durationadv")
      enable("factorsadv")
      enable("logscaleadv")
      enable("animateadv")

      output$plotadv <- renderImage({
        outfile <- tempfile(fileext = '.png')
        png(outfile, width = 400, height = 400)
        dev.off()


        # Return a list containing the filename
        list(
          src = outfile,
          contentType = 'image/png',
          width = 400,
          height = 400
        )

      }, deleteFile = TRUE)  # end of render image
    })





    # ANIMATE


    disable("reset")
    output$plot <- renderImage({
      outfile <- tempfile(fileext = '.png')
      png(outfile, width = 400, height = 400)
      dev.off()

      # Return a list containing the filename
      list(
        src = outfile,
        contentType = 'image/png',
        width = 400,
        height = 400
      )

    }, deleteFile = TRUE)  # end of render image

    observeEvent(input$xvar, {
      updateSelectInput(session, "yvar",
                        choices = numericvars[!numericvars %in% input$xvar])
      updateSelectInput(session, "sizevar",
                        choices = numericvars[!numericvars %in% c(input$xvar, input$yvar)])
      updateSelectInput(session, "tempvar",
                        choices = numericvars[!numericvars %in% c(input$xvar, input$yvar, input$sizevar)])
    })
    observeEvent(input$yvar, {
      updateSelectInput(session, "sizevar",
                        choices = numericvars[!numericvars %in% c(input$xvar, input$yvar)])
      updateSelectInput(session, "tempvar",
                        choices = numericvars[!numericvars %in% c(input$xvar, input$yvar, input$sizevar)])
    })
    observeEvent(input$sizevar, {
      updateSelectInput(session, "tempvar",
                        choices = numericvars[!numericvars %in% c(input$xvar, input$yvar, input$sizevar)])
    })
    observe({
      if (input$xvar == "" ||
          input$yvar == "" ||
          is.na(input$yvar) || is.na(input$xvar)) {
        disable("animate")
      }
      else{
        enable("animate")
      }
    })

    # Handle the plot button being pressed.
    observeEvent(input$animate, {
      disable("animate")
      disable("reset")
      disable("xvar")
      disable("yvar")
      disable("sizevar")
      disable("colorvar")
      disable("tempvar")
      disable("logscale")

      output$plot <- renderImage({
        # A temp file to save the output.
        # This file will be removed later by renderImage
        outfile <- tempfile(fileext = '.gif')

        # now make the animation
        p = ggplot(
          data,
          aes_string(
            x = input$xvar,
            y = input$yvar,
            size = input$sizevar,
            colour = ifelse(input$colorvar == "None", "NULL", input$colorvar)
          )
        ) + geom_point() +
          gganimate::transition_time(data[[input$tempvar]]) +
          labs(title = paste(c(input$tempvar, ": {frame_time}"), collapse = " ")) +
          geom_point(alpha = 0.8, stroke = 0) +
          scale_size(range = c(2, 12)) +
          ggthemes::theme_gdocs() +
          theme(
            axis.title = element_text(),
            legend.text = element_text(size = 12),
            plot.background = element_blank()
          ) +
          scale_color_brewer(palette = "Set2")

        if (input$logscale == "X") {
          p <- p + scale_x_log10()
        }
        else if (input$logscale == "Y") {
          p <- p + scale_y_log10()
        }
        else if (input$logscale == "X and Y") {
          p <- p + scale_x_log10() + scale_y_log10()
        }

        gganimate::anim_save(
          "outfile.gif",
          gganimate::animate(p, renderer = gganimate::gifski_renderer())
        )


        # Return a list containing the filename
        list(src = "outfile.gif",
             contentType = 'image/gif',
             height = 500)
      }, deleteFile = TRUE)

      enable("reset")

    })

    observeEvent(input$reset, {
      disable("reset")
      enable("xvar")
      enable("yvar")
      enable("sizevar")
      enable("colorvar")
      enable("tempvar")
      enable("logscale")
      enable("animate")

      output$plot <- renderImage({
        outfile <- tempfile(fileext = '.png')
        png(outfile, width = 400, height = 400)
        dev.off()


        # Return a list containing the filename
        list(
          src = outfile,
          contentType = 'image/png',
          width = 400,
          height = 400
        )

      }, deleteFile = TRUE)  # end of render image
    })



  }

  shinyApp(ui, server)
}
