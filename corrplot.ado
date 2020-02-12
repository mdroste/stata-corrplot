*===============================================================================
* PROGRAM: corrplot.ado
* PURPOSE: Produces pretty plots of correlations between y and x
* Feb 2020
*===============================================================================
 
program define corrplot
	version 12.1
               
	syntax varlist(min=2 numeric) [if] [in] [aweight fweight], ///
		[labels(string asis) groupcovs(numlist ascending) ///
		savegraph(string) replace gonegative noprint ci(string) alpha(real 0.05) ///
		msymbol_p(string) msymbol_n(string) mcolor_p(string) mcolor_n(string) ///
		controls(varlist numeric) absorb(varname) ///
		twopt(string asis)]
               
	*---------------------------------------------------------------------------
	* Setup
	*---------------------------------------------------------------------------
               
	set more off
	preserve
	
	* Restrict sample with if/in conditions
	marksample touse, strok novarlist
	qui drop if `touse'==0
	 
	* Define more convenient names
	local outcome = word("`varlist'",1)
	local list_covs = regexr("`varlist'","`outcome' ","")
	local list_labels "`labels'"
	local list_breaks `groupcovs'
	if ("`weight'"!="") local wt [`weight'`exp']
               
	* Check list of labels
	local num_covs: word count `list_covs'
	local num_labs: word count "`list_labels'"
	local num_colors_p: word count `mcolor_p'
	local num_colors_n: word count `mcolor_n'
	local num_symbols_p: word count `msymbol_p'
	local num_symbols_n: word count `msymbol_n'
    
	*---------------------------------------------------------------------------
	* Catch exceptions and handle errors related to arguments
	*---------------------------------------------------------------------------
               
	* If labels are specified, there should be one for each covariate
	if `"`list_labels'"'!= "" {
		if `num_covs' != `num_labs' {
			disp as error "Error: Number of covariates (`num_covs') not equal to number of labels (`num_labs')."
			exit 1
		}
	}
               
	* Make sure no variable in control list appears in covariate list
	foreach c in `controls' {
		foreach x in `list_covs' {
			if "`c'"=="`x'" {
				disp as error "Error: Control variable (`c') cannot appear in list of covariates."
				exit 1
			}
		}
		if "`c'"=="`outcome'" {
			disp as error "Error: Control variable (`c') cannot also be outcome variable."
			exit 1
		}
	}
               
	* If graph is being saved, check to make sure name is valid
	if "`replace'"=="" & `"`savegraph'"'!="" {
		if regexm(`"`savegraph'"',"\.[a-zA-Z0-9]+$") confirm new file `"`savegraph'"'
		else confirm new file `"`savegraph'.gph"'
	}

	* If marker colors / shapes are specified, check to see if there is more than one specified
	if `num_colors_p' > 1 {
		disp as error "Warning: More than one color specified for positive correlations. Only the first will be used."
		local mcolor_p = word("`mcolor_p'",1)
	}
	if `num_symbols_p' > 1 {
		disp as error "Warning: More than one marker pattern specified for positive correlations. Only the first will be used."
		local msymbol_p = word("`msymbol_p'",1)
	}
	if `num_colors_n' > 1 {
		disp as error "Warning: More than one color specified for negative correlations. Only the first will be used."
		local mcolor_n = word("`mcolor_n'",1)
	}
	if `num_symbols_n' > 1 {
		disp as error "Warning: More than one marker pattern specified for negative correlations. Only the first will be used."
		local msymbol_n = word("`msymbol_n'",1)
	}
 
	* Set marker symbols
	local marker_pos s
	local marker_neg s
	if "`msymbol_p'"!="" {
		local marker_pos = "`msymbol_p'"
	}
	if "`msymbol_n'"!="" {
		local marker_neg = "`msymbol_n'"
	}
               
	* Set marker colors
	local color_pos green
	local color_neg red
	if "`mcolor_p'"!="" {
		local color_pos = "`mcolor_p'"
	}
	if "`mcolor_n'"!="" {
		local color_neg = "`mcolor_n'"
	}
               
	* Check alpha in range 0 to 1
	if `alpha'>1 | `alpha'<0 {
		disp "Warning: alpha (=`alpha') specified outside permitted range (0 to 1). Choosing alpha=0.05 instead."
		local alpha = 0.05
	}
	
	*---------------------------------------------------------------------------
	* Residualize outcome and covariates with respect to controls, if applicable
	*---------------------------------------------------------------------------
               
	if "`controls'"!="" {
		* Residualize outcome variable
		qui reg `outcome' `controls' `wt'
		qui predict `outcome'_res, residual
		qui replace `outcome' = `outcome'_res
		* Residualize each covariate
		foreach v in `list_covs' {
			qui reg `v' `controls' `wt'
			qui predict `v'_res, residual
			qui replace `v' = `v'_res
		}
		drop *_res
	}          
               
	*---------------------------------------------------------------------------
	* Calculate correlations and obtain confidence intervals
	*---------------------------------------------------------------------------
 
	global num_x: word count `list_covs'
	local v = 1

	mat pairwise_correlations = J($num_x,3,.)
	mat rownames pairwise_correlations = `list_covs'
	mat colnames pairwise_correlations = "Correlation" "CI lower" "CI upper"
               
	foreach var in `list_covs' {
               
		qui su `outcome' `wt' if ~missing(`outcome') & ~missing(`var')
		qui gen eb = (`outcome' - r(mean))/r(sd)
		qui su `var' `wt' if ~missing(`outcome') & ~missing(`var')
		qui gen vb = (`var' - r(mean))/r(sd)
		qui reg eb vb `wt', robust
		scalar rb = _b[vb]
		scalar rse = _se[vb]
		qui drop eb vb
		qui gen rcoef_true_`v' = rb
		qui gen rcoef_`v' = abs(rb)
	    
		* Do Fisher's transformation to compute ci's
		if "`ci'"=="fisher" {
			scalar rt = .5*ln((1+rb)/(1-rb))
			scalar se =  (e(N)-3)^-.5
			scalar lb = rt - se*invnormal(1-`alpha'/2)
			scalar ub = rt + se*invnormal(1-`alpha'/2)
			scalar lb = (exp(2*lb)-1)/(exp(2*lb)+1)
			scalar ub = (exp(2*ub)-1)/(exp(2*ub)+1)
			qui gen rcih_`v' = ub
			qui gen rcil_`v' = lb
		}
	               
		* Bootstrapped standard errors
		else if "`ci'"=="bootstrap" {
			qui bootstrap correlation = r(rho), nodots nowarn reps(10000) seed(1921): correlate `outcome' `var' `wt'
			mat t = e(ci_bc)
			scalar ub = t[2,1]
			scalar lb = t[1,1]
			qui gen rcih_`v' = ub
			qui gen rcil_`v' = lb
		}
	               
		* Normal vanilla way
		else {
			local bd = rse
			scalar ub = rb + rse*invnormal(1-`alpha'/2)
			scalar lb = rb - rse*invnormal(1-`alpha'/2)
			qui gen rcih_`v' = ub
			qui gen rcil_`v' = lb
		}
		
	               
		* Set up matrix of correlation coefs and CIs
		mat pairwise_correlations[`v',1] = rb
		mat pairwise_correlations[`v',2] = lb
		mat pairwise_correlations[`v',3] = ub
	               
		local v = `v' + 1
	}
	
	*---------------------------------------------------------------------------
	* Print pairwise corr matrix unless noprint is specified as an option
	*---------------------------------------------------------------------------
               
	if "`noprint'"=="" {
		noisily disp ""
		noisily disp "Pairwise correlation with `outcome'"
		mat l pairwise_correlations, noheader
	}
 
	*---------------------------------------------------------------------------
	* Censor confidence intervals for negative correlations
	*---------------------------------------------------------------------------
			   
	
	local v = 1
	foreach var in `list_covs' {
		
		if rcoef_true_`v' < 0 {
			local t1 = rcil_`v'
			local t2 = rcih_`v'
			if "`gonegative'"=="" {
				qui replace rcil_`v' = 0 if rcil_`v' < 0
				qui replace rcih_`v' = 0 if rcih_`v' < 0
				qui replace rcih_`v' = abs(`t1') if `t1'<0 & `t2'>0
				qui replace rcil_`v' = abs(`t2') if `t1'<0 & `t2'<0
				qui replace rcih_`v' = abs(`t1') if `t1'<0 & `t2'<0
			}
		}
		
		if rcoef_true_`v' > 0 {
			if "`gonegative'"=="" {
				qui replace rcil_`v' = 0 if rcil_`v' < 0
			}
		}
		
		qui replace rcil_`v' = -1 if rcil_`v' < -1
		qui replace rcil_`v' = 1  if rcil_`v' > 1
		qui replace rcih_`v' = -1 if rcih_`v' < -1
		qui replace rcih_`v' = 1  if rcih_`v' > 1
		
		local v = `v' + 1
	}
	*---------------------------------------------------------------------------
	* Reshape
	*---------------------------------------------------------------------------
               
	keep rcoef_* rcil* rcih*
	qui duplicates drop
	qui gen i = 1
	qui reshape long rcoef_ rcoef_true_ rcih_ rcil_, i(i) j(vnum)
	label drop _all
               
	*---------------------------------------------------------------------------
	* Generate CI / corr variables
	*---------------------------------------------------------------------------
               
	qui expand 2
	qui gen p = _n > $num_x
	forval v = 1/$num_x {
		qui gen ci`v' = rcil_     if p==0 & vnum==`v'
		qui replace ci`v' = rcih_ if p==1 & vnum==`v'
		qui replace rcoef_ = .    if p==1 & vnum==`v'
	}
               
	*---------------------------------------------------------------------------
	* Create breaks
	*---------------------------------------------------------------------------
               
	qui gen vlist = .
	local breaks = 0
	foreach x in `list_breaks' {
		qui replace vnum = vnum+1 if inrange(vnum,`x'+1+`breaks',$num_x+`breaks')
		local breaks = `breaks' + 1
		local break_indices `break_indices' `x'+`breaks'
	}
	forval v = 1/$num_x {
		local vlist `vlist' vnum[`v']
	}
 
	*---------------------------------------------------------------------------
	* Create labels
	*---------------------------------------------------------------------------
	if `"`list_labels'"'!="" {
		local current = 1
		foreach x in "`list_labels'" {
			local cu = vnum[`current']
			label define varname `cu' "`x'", add
			local ylabs `ylabs' `cu'
			local current = `current' + 1
		}
		label values vnum varname
	}
	else {
		local current = 1
		foreach x in `list_covs' {
			local cu = vnum[`current']
			label define varname `cu' "`x'", add
			local ylabs `ylabs' `cu'
			local current = `current' + 1
		}
		label values vnum varname        
	}
               
	*---------------------------------------------------------------------------
	* Create macro with scatter commands for correlations and CIs
	*---------------------------------------------------------------------------
 
	forval j = 1/$num_x {
		local z = vnum[`j']
	               
		* CIs
		local call `call' (scatter vnum ci`j', c(l) mcolor(gs0) lcolor(gs7) lwidth(thin) m(i))
               
		* Corrs
		if "`gonegative'"=="" {
			if rcoef_true_[`j']>=0 {
				local call `call' (scatter vnum rcoef_ if vnum==`z', mcolor(`color_pos') msymbol(`marker_pos'))
			}
			if rcoef_true_[`j']<0 {
				local call `call' (scatter vnum rcoef_ if vnum==`z', mcolor(`color_neg') msymbol(`marker_neg'))
			}
		}
		else {
			local call `call' (scatter vnum rcoef_true_ if vnum==`z', mcolor(`color_pos') msymbol(`marker_pos'))
		}
	}
               
	*---------------------------------------------------------------------------
	* Make call command for break lines
	*---------------------------------------------------------------------------
               
	foreach x in `break_indices' {
		local z = `x'
		local call2 `call2' yline(`z', lc(gs12) lp(dash))
	}
               
	if "`gonegative'"=="" {
		local macro_xlabel xlabel(0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1 "1.0")
	}
	else {
		local macro_xlabel xlabel(-1.0 "-1.0" -0.8 "-0.8" -0.6 "-0.6" -0.4 "-0.4" -0.2 "-0.2" 0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1 "1.0")
		local zero_line xline(0, lc(gs12) lwidth(medthin))
	}
               
	*---------------------------------------------------------------------------
	* Create graph
	*---------------------------------------------------------------------------
               
	gr tw `call', `call2' ///
		title(" ", size(medsmall)) ytitle("") xtitle("Magnitude of Correlation") ///
		xlabel(, grid) ylab(`ylabs', valuelabel angle(0) labsize(vsmall) nogrid) ///
		graphregion(color(white)) legend(off) ///
		`macro_xlabel' `zero_line' `twopt'
	               
	* Save graph, if requested
	if `"`savegraph'"'!="" {
		if regexm(`"`savegraph'"',"\.[a-zA-Z0-9]+$") local graphextension=regexs(0)
		if inlist(`"`graphextension'"',".gph","") graph save `"`savegraph'"', `replace'
		else graph export `"`savegraph'"', `replace'
	}
               
	restore
	               
end
