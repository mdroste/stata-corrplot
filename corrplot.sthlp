{smcl}
{* *! version 1.01  25jul2016}{...}
{viewerjumpto "Syntax" "corrplot##syntax"}{...}
{viewerjumpto "Description" "corrplot##description"}{...}
{viewerjumpto "Options" "corrplot##options"}{...}
{viewerjumpto "Examples" "corrplot##examples"}{...}
{viewerjumpto "Author" "corrplot##author"}{...}
{viewerjumpto "Acknowledgements" "corrplot##acknowledgements"}{...}
{title:Title}
 
{p2colset 5 19 21 2}{...}
{p2col :{hi:corrplot} {hline 2}}Aesthetically pleasing correlation plots{p_end}
{p2colreset}{...}
 
 
 
{marker syntax}{title:Syntax}
 
{p 8 15 2}
{cmd:corrplot}
{varlist} {ifin}
{weight}
[{cmd:,} {it:options}]
 
{pstd}
where {it:varlist} begins with an outcome variable and is followed by at least one covariate:
{p_end}
                                {it:y} {it:x_1} [... {it:x_n}]
                               
 
{synoptset 30 tabbed}{...}
{synopthdr :options}
{synoptline}
 
{syntab :Main}
{synopt :{opth ci(string)}}Choose a method for calculating confidence intervals.{p_end}
{synopt :{opt alpha(#)}}Choose a significance level for confidence intervals (default: 0.05){p_end}
{synopt :{opt noprint}}Do not display correlations and confidence intervals in output window.{p_end}
 
 
{syntab :Controls}
{synopt :{opth controls(varlist)}}Residualize the outcome variable and covariates on a list of controls{p_end}
 
 
{syntab :Graph Style}
{synopt :{opt gonegative}}Plot correlations from -1 to 1.{p_end}
{synopt :{opth labels(string)}}Define labels for each covariate (default: covariate names){p_end}
{synopt :{opth groupcovs(numlist)}}Insert spacing after specified covariates {p_end}
{synopt :{opth mcolor_p(colorstyle)}}Define marker color for positive correlations (default: green) {p_end}
{synopt :{opth mcolor_n(colorstyle)}}Specify a marker color for negative correlations (default: red) {p_end}
{synopt :{opth msymbol_p(symbolstyle)}}Specify a marker symbol for positive correlations (default: small square) {p_end}
{synopt :{opth msymbol_n(symbolstyle)}}Specify a marker symbol for negative correlations (default: small square) {p_end}
{synopt :{it:{help twoway_options}}}{help title options:titles}, {help legend option:legends}, {help axis options:axes}, added {help added line options:lines} and {help added text options:text},
                {help region options:regions}, {help name option:name}, {help aspect option:aspect ratio}, etc.{p_end}
 
               
{syntab :Save Output}
{synopt :{opt savegraph(filename)}}Save graph in format given by filename extension{p_end}
{synopt :{opt replace}}Overwrite existing file{p_end}
 
{synoptline}
{p 4 6 2}
{opt aweight}s and {opt fweight}s are allowed;
see {help weight}.
{p_end}
 
 
 
{marker description}{...}
{title:Description}
 
{pstd}
{opt corrplot} generates a graph plotting the correlations between an outcome variable of interest (y) and a set of covariates (x_1, ..., x_n).
 
{pstd}
Corrplot allows the user to quickly visualize the relationships between a key variable and a set of covariates.
It incorporates the information provided by the pairwise correlation matrix (pwcorr) and plots the correlation coefficients and confidence intervals in a publication-quality chart.
 
 
 
{marker options}{...}
{title:Options}
 
{dlgtab:Main}
 
{phang}
{opth ci(string)} Choose a method for calculating confidence intervals. The default method applies a Fisher transformation to the correlation coefficient. Alternatively, ci(bootstrap) will bootstrap the confidence intervals.
 
{phang}
{opt alpha(#)} Choose a significance level for confidence intervals. The default setting is 95% confidence, or alpha(0.05).
 
 
{dlgtab:Controls}
 
{phang}
{opth controls(varlist)} Residualizes outcome variable and covariates on a list of specified controls before computing and plotting correlations and confidence intervals.
 
 
{dlgtab:Graph Style}
 
{phang}
{opt gonegative} Plots correlations along the entire interval [-1,1]. This option overrides the default setting of plotting absolute correlations on the interval [0,1] and using color to distinguish positive and negative correlations.
 
{phang}
{opth labels(string)} allows the user to specify custom labels for each covariate in the output graph.
 
{phang}
{opth groupcovs(numlist)} allows the user to provide spacing between groups of covariates.
 
{phang}
{opth mcolor_p(colorstyle)} specifies a marker color for covariates that are positively related to the outcome.
 
{phang}
{opth mcolor_n(colorstyle)} specifies a marker color for covariates that are negatively related to the outcome.
 
{phang}
{opth msymbol_p(symbolstyle)} specifies a marker symbolf for covariates that are positively related to the outcome.
 
{phang}
{opth msymbol_n(symbolstyle)} specifies a marker symbolf for covariates that are negatively related to the outcome.
 
{phang}
{it:{help twoway_options}}: Any unrecognized options added to {cmd:corrplot} are appended to the end of the twoway command which generates the correlation plot.
 
 
{dlgtab:Save Output}
 
{phang}
{opt savegraph(filename)} saves the graph to a file.  The format is automatically detected from the extension specified [ex: {bf:.gph .jpg .png}],
and either {cmd:graph save} or {cmd:graph export} is run.  If no file extension is specified {bf:.gph} is assumed.
 
{phang}
{opt replace} specifies that files be overwritten if they already exist.
 
 
 
{marker examples}{...}
{title:Examples}
 
{pstd}Load the 1988 extract of the National Longitudinal Survey of Young Women and Mature Women.{p_end}
{phang2}. {stata sysuse nlsw88}{p_end}
 
{pstd}Let's look at the relationship between wages and a handful covariates in our dataset.{p_end}
{phang2}. {stata corrplot wage tenure ttl_exp hours grade age}{p_end}
 
 
 
{marker author}{...}
{title:Author}
 
{pstd}Michael Droste{p_end}
{pstd}thedroste@gmail.com{p_end}
 
 
 
{marker acknowledgements}{...}
{title:Acknowledgements}
 
{pstd}The present version of {cmd:corrplot} is based on a program first written by LEAP predoctoral fellows at Harvard University and maintained by SIEPR predoctoral fellows at Stanford University.
 
{pstd}This program was developed under the direction of Raj Chetty, John Friedman, and Nathan Hendren.
