`r require(dplyr)`
This repository contains code to execute a misspecification simulation using a Stock Synthesis (SS3, Methot & Wetzel 2013) model of Striped Marlin. The entire procedure *after construction of the operating model* (see below) can be executed using the `master.R` script.

# Steps to replicate study
## Generate Operating Model (OM)
The user must have the following Striped Marlin  operating model files `forecast.SS`,`SM_Control.ss`,`ss3.par`,`SM_data.ss`,`starter.ss` and `ss3.exe` saved in a root directory. The user must first run the OM **without** the hessian matrix and ensuring that `init_src` in the `starter.ss` file is set to `0` so that the all parameters are estimated. From this point, the `master.R` script can be used exclusively.

## Generate Estimation Model(s) (EM)
Lines 18-20 of `master.R` will generate a unique directory for each mis-specified estimation model and copy the OM into those folders. Unique changes to the `ss3.par` files are implemented in the `parmgrid` object, which is a 2xN table specifying the name of paramter to change and the new value to be used in the mis-specified model. **Beta** Our simulation setup is iterative, meaning that each subsequent EM has N-1 mis-specified paramters (e.g. `EM_1` has all three mis-specified, where as `EM_3` has only the last one). *This will likely change to include a crosswise mis-specification matrix.*
```{r, echo = F}
parmgrid = data.frame(pName = c("SR_BH_steep","SR_sigmaR", "SR_envlink"),
                      nVal =c(0.6,0.45,1))
print(parmgrid)
```

## Execute "bootstrap" simulations
To mirror approaches used in previous studies (Carvalho citation), the simulation approach will generate `n_replicates` folders, each with a single SS3 instance. These folders match their respective source EM in structure & parameter mis-specification, with the exception that the vector of initial recruitment deviations is uniquely sampled from the OM via `sample()`: `matrix(sample(recruit_dev,replace=TRUE),nrow=1)`). This procedure occurs in the `recDev_Fn.R`.

After each `Rep`, the simulation compiles a PDF of summary plots for the individual assessment which can be inspected.
