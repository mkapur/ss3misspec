recDev_Fn = function(  ){
  # inputs
  # if(!exists("verbose")) verbose <- FALSE
  # attach( inputlist, warn.conflicts=verbose )
  # on.exit( detach(inputlist) )
  
  # Move files to new directory
  file.copy( from=paste0(SpeciesEM,list.files(SpeciesEM)), 
             to=RepFile, 
             overwrite=TRUE)
  

  # # Generate and write new F trajectory
  # if( "Framp" %in% names(inputlist)){
  #   Which = grep("F_rate",names(Par))
  #   Par[Which] = seq( from=Framp['min'], to=Framp['max'], length=length(Which))
  # }
  
  
  # Change starter file to init_values_src == 1
  Starter = SS_readstarter( file=paste0(RepFile,"starter.ss"), verbose=F)
  Starter[['init_values_src']] = 1
  Starter[['N_bootstraps']] = 1
  SS_writestarter( mylist=Starter, dir=RepFile, overwrite=TRUE, verbose=F, warn=F)

  random_recruit_dev = matrix(sample(recruit_dev,replace=TRUE),nrow=1)
  # Modify par file of boot at hand
  Par = scan_admb_par( paste0(RepFile,"ss3.par"))
  Par[grep("recdev",names(Par))] <- random_recruit_dev
  write.table( Par, file=paste0(RepFile,"ss3.par"), row.names=FALSE, col.names=FALSE) ## dumps to line 26
  
  # Run first time
  # setwd( RepFile )
  # shellout = shell( "ss3.exe -maxfn 0 -nohess")
  # print(shellout); flush.console()
  
  # Write bootstrap simulation to data file
  Lines = readLines( paste0(RepFile,"SM_data.ss") )
  # Lines = Lines[(grep("#_bootstrap file: 1",Lines)+1):grep("ENDDATA",Lines)] ## THIS ASSUMES THERE IS >1 BOOTSTRAP
  writeLines(text=Lines, con=paste0(RepFile,Starter[['datfile']]))
  
  # Return stuff
  # Return = list( "Success"=1, "TruePar"=Par )
  # invisible(Return)
}
