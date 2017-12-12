

Build_EM_Fn = function(RootFile, Species = "SM", parmgrid){
  # inputs
  # if(!exists("verbose")) verbose <- FALSE
  # attach( inputlist, warn.conflicts = verbose )
  # on.exit( detach(inputlist) )
  
  SpeciesOM = paste0(RootFile,Species,"_OM/") ## where OM is dumped
  
  for(EMI in 1:nrow(parmgrid)){
    ## make a new folder for this em
    EM.folder = paste0(RootFile,Species,"_EM_",EMI,"/")
    cat("generating estimation model",EMI,"\n")
    dir.create(EM.folder, recursive = T) 
    
    ## copy control & other files into this EM
    # file.copy( from=paste0(SpeciesOM,
    #                        sort(list.files(SpeciesOM))[c(20,21,11,33,39, 27,17)]),
    #            to=paste0(EM.folder,list.files(EM.folder)), overwrite=TRUE)

    file.copy( from=paste0(SpeciesOM,
                           list.files(SpeciesOM)),
               to=paste0(EM.folder,list.files(EM.folder)), overwrite=TRUE)
    # 
    # Change starter file so it reads from par
    Starter = SS_readstarter( file=paste0(EM.folder,"starter.ss"), verbose = F)
    Starter[['init_values_src']] = 1
    Starter[['N_bootstraps']] = 0
    SS_writestarter( mylist=Starter, dir = EM.folder, overwrite=TRUE, verbose = F, warn = F)
    
    # Modify if necessary
    # if(Type=="DM"){
    # Modify DAT file - We don't need to do this (data is consistent)
    # Lines = readLines( paste0(folder,"SM_data.ss") )
    # findageline <- grep("#_N_age_bins", Lines)
    # dmdatlines <- grep("#_Nfleet", Lines)
    # dmdatlines <- dmdatlines[dmdatlines > findageline] ## this was just to coerce to later one
    # Lines[dmdatlines] = apply(DM_data_matrix, MARGIN=1, FUN=paste, collapse=" ")
    # writeLines(text=Lines, con=paste0(folder,"SM_data.ss"))

    # Modify CTL file in this EM (matches designation in EMS file) - test - change steepness to 0.6
    Lines = readLines( paste0(EM.folder,"SM_control.ss") )
    LOI <- grep(paste(parmgrid$pName[EMI:nrow(parmgrid)],collapse = "|"),Lines) ## get line(s) of interest - fewer and fewer for latter EMS
    NewLine = strsplit(Lines[LOI]," ") ## grab all lines that match EMs
    
    for(a in 1:length(NewLine)){
      pName = gdata::last(NewLine[[a]]) ## get parameter name to ensure match
      NewLine[[a]][4] = parmgrid[parmgrid$pName == pName,][,'nVal'] ## reassign parameter name
      cat("replacing ",pName,"\n")
      Lines[LOI][a] = paste0(NewLine[[a]], collapse = " ")
    }
    
    # Lines[LOI] = paste0(NewLine, collapse = " ")
    # Lines[LOI] = paste0( NewLine[-grep("#",NewLine)[1]], collapse=" ") ## overwrite
    writeLines(text=Lines, con=paste0(EM.folder,"SM_control.ss"))
    

    # shellout = shell( "ss3.exe -maxfn 0 -nohess")
    # print(shellout); flush.console()
  } # end EM loop
  
}



## name the ems after the line to be modified
