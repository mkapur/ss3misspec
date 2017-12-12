## MisSpec Testing Script (Beta)
## Jim Thorson mod. M Kapur maia.kapur@noaa.gov
## Dec 2017

require(r4ss)
rm(list = ls())
set.seed(731)
#devtools::install_github("james-thorson/utilities")
library(ThorsonUtilities)
library(r4ss)
RootFile = "G:/SSBOOT/" ## all data is housed.
source("G:/SSBOOT/Build_EM_Fn.R")
source("G:/SSBOOT/recDev_Fn.R")
Species = "SM" ##

## BUILD EMs (only need to do this first time). First column are params to change, nVal are new values
## NOTE: These have init_src == 1 and copies of the same rec as original [gets changed later]
# parmgrid = data.frame(pName = c("SR_BH_steep","SR_sigmaR", "SR_envlink"),
#                       nVal =c(0.6,0.45,1))
# Build_EM_Fn( RootFile, Species, parmgrid )

setwd(RootFile)
SpeciesOM = paste0(RootFile,Species,"_OM/") ## where OM is dumped

## generate a new recdev vector by sampling from original OM
fit <- SS_output(SpeciesOM,ncols=500,covar=FALSE) ## get original outputs
recruit_dev = na.omit(fit$recruit$dev) ## use this to resample rec devs in each bootstrap

n_replicates = 5 ## not the same as number of bootstraps. This determines how many individual folders you get.

# Run simulations

for(RepE in 1:3){  ## loop into EMs
  # Set working directory and folder structure
  SpeciesEM = paste0(RootFile,Species,"_EM_",RepE,"/") 
  DateFile = paste0(SpeciesEM, Sys.Date(),"/")
  for( RepI in 1:n_replicates ){    ## loop into n_replicates

    RepFile = paste0(DateFile,"Rep",RepI,"/")  ## pseudo boot
    dir.create(RepFile, recursive=TRUE) ## nests rep I into specific misspec file
    message("Starting replicate ",RepI," at ",Sys.time())
    
    if( !file.exists(paste0(DateFile,"/Results_",RepI,".RData")) ){
      # Generate bootstrap replicate(s)
      recDev_Fn(  )

      # Run SS on Rep
      setwd( RepFile )
      shell( "ss3.exe  -nohess -nomcmc" )
      
      ## gen test plots
      model_1 <- SS_output(RepFile, covar=FALSE,ncols = 500)
      SS_plots(model_1, datplot=TRUE,pdf=TRUE,png=FALSE,  uncertainty= FALSE,pwidth=9, pheight=9, rows=2, cols=2)
      
      # if( file.exists(paste0(RepFile,"ss3.std")) ){
      #   # Read MLE
      #   MLE = scan_admb_par( paste0(RepFile,"ss3.par"))
      #   
      #   # Run MCMC
        # shellout = shell( "ss3 -nohess -nomcmc")       # 50000/100000 -> 30 minutes on work machine
      #   shellout = shell( "ss3 -mceval"  )       # 50000/100000 -> 30 minutes on work machine
      #   # Read MCMC myself
      #   Posterior = read.table( paste0(RepFile,"posteriors.sso"), header=TRUE)
      #   Posterior = Posterior[ceiling(nrow(Posterior)/2):nrow(Posterior),]
      #   
      #   # Get estimates (saves single value in overall EM folder)
      #   Results = list( "MLE"=MLE, "Posterior"=Posterior, "Result"=list("MLE"=MLE['# SR_parm[1]:'], "Mean"=mean(Posterior[,'SR_LN.R0.'])))
      #   save(Results, file=paste0(DateFile,"/Results_",RepI,".RData"))
      # }else{
      #   Results = list( "Result"=list("MLE"=NA, "Mean"=NA) )
        # save(Results, file=paste0(DateFile,"/Results_",RepI,".RData"))
      }
  } # end replicate loop
} ## end EM loop


