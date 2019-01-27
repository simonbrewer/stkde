# stkde
Space-time kernels

Scripts for running and visualizing space-time kernels and modeling using log Cox Gaussian process models.

## Notes:

### Space-time kernel estimation
(Notes taken from the help):

Specifically, for n trivariate points in space-time (pp, tt, tlim), we have

\[
\hat{f}(x,t)=n^{-1}\sum_{i=1}^{n}h^{-2}\lambda^{-1}K((x-x_i)/h)L((t-t_i)/\lambda)/(q(x)q(t)),
\]

where:

- $x\in W\subset \mathbb{R}^2$ and $t\in T\subset \mathbb{R}$. $W$ is the study spatial window in 2D real space, and T is the study time window in 1D real space
- $K$ and $L$ are the $2D$ and $1D$ Gaussian kernels controlled by fixed bandwidths $h$ (h) and $\lambda$ (lambda) respectively. These are based on the standard Gaussian equation. 
- $q(x)=\int_W h^{-2}K((u-x)/h)du$ and $q(t)=\int_T \lambda^{-1}L((w-t)/\lambda)dw$ are optional edge-correction factors ($s_{edge}$ and $t_{edge}$).

The above equation provides the joint or unconditional density at a given space-time location ($x,t$). In addition to this, the function also yields the conditional density at each grid time, defined as

\[
\hat{f}(x|t)=\hat{f}(x,t)/\hat{f}(t),
\]

The choice of the joint or conditional density appears to be largely based on use. Conditional densities appear to be better for visualization, joint better for modeling ("We note that while use of the conditional relative risk function would have led to the same conclusion about spatial pattern of disease, inference about aggregate levels of disease is only possible through the generalized spatial relative risk function", Fernando and Hazelton,(2014)).

### Log Cox Gaussian Processes

TBD

"As a practical solution, we would recommend the user attempts model selection via other means before running the MCMC, for example with a simple call to glm, ignoring spatial correlation". Taylor et al. (2015).

Fernando, W.T.P.S. and Hazelton, M.L. (2014), Generalizing the spatial relative risk function, Spatial and Spatio-temporal Epidemiology, 8, 1-10.

Taylor et al. (2015) Bayesian Inference and Data Augmentation Schemes for Spatial, Spatiotemporal and Multivariate Log-Gaussian Cox Processes in R. JSS, 63:7