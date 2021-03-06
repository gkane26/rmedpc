#' Import data from MedPC file to an R list
#'
#' Parses MedPC data file and returns variables in a named list.
#' Uses 'filename' if filename is a path to a file, otherwise, opens a GUI to select a file.
#'
#' @param filename full path to MedPC data file
#' @return list containing each variable in MedPC data file, referenced by variable name
#' @export
#' @examples
#' example_file = system.file("extdata", "example_data", package = "rmedpc")
#' import_medpc(example_file)
import_medpc <- function(filename=""){

  if(!file.exists(filename)){
    filename = svDialogs::dlgOpen()$res
  }

  #initialize list of variables
  varList = list()

  #Read file line by line, split line by labels
  line = scan(file=filename, character(0), sep="\n", strip.white=TRUE)
  line = gsub("\\s+", " ", line)
  spl = strsplit(line, ": ")

  #Pull out general info
  for(i in 1:10) varList[[spl[[i]][1]]] = spl[[i]][2]

  #remove general info, split rest into label & values
  line=line[-(1:10)]
  spl = strsplit(line, " ")

  ############################################################
  #Identify variables and arrays, assign values
  #Loop through every line
  #if character followed by one number, assign variable letter to number
  #if character alone, assign array to all following variables until next character
  ############################################################

  getLabels = function(x) strsplit(x[[1]][1], ":")[[1]][1] #takes list, returns label at beginning of line
  labels = sapply(spl, getLabels)

  cnt=1
  while(cnt<=length(spl)){

    if(is.na(strtoi(labels[cnt]))){ #if label is a letter (start of variable or array)

      if(length(spl[[cnt]]) == 2){ #if variable
        varList[[labels[cnt]]] = as.numeric(spl[[cnt]][2])
      }else if(length(spl[[cnt]]) == 1){ #if start of array
        current = labels[[cnt]]
        varList[[current]] = NULL
        totalRay = NULL
      }

    }else{ #if label is number (continuation of array)
      totalRay = c(totalRay, as.numeric(spl[[cnt]][2:length(spl[[cnt]])]))
      varList[[current]] = totalRay
    }

    cnt = cnt +1
  }

  return(varList)

}
