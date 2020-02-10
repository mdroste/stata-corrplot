
corrplot
=================================

[Overview](#overview)
| [Installation](#installation)
| [Usage](#usage)
| [Benchmarks](#benchmarks)
| [To-Do](#todo)
| [Acknowledgements](#acknowledgements)
| [License](#license)

Pretty plots of pairwise correlations in Stata

`version 0.5 10feb2020`


Overview
---------------------------------

Corrplot produces nice plots of pairwise correlations between a dependent variable of interest and a set of covariates.

For an example, consider Figure 8 from [Chetty et al. 2014, "Where is the Land of Opportunity? Intergenerational Mobility in the United States"](https://opportunityinsights.org/paper/land-of-opportunity/). This figure plots correlations across commuting zones (CZs) between the authors' preferred measure of intergenerational mobility and a set of commuting zone characteristics, i.e. mean household income, violent crime rate, etc.

![corrplot demo](figs/chetty2014_fig8.png "corrplot demo")

These plots can be a little cumbersome to produce in Stata. Corrplot makes it a lot easier.



Prequisites
---------------------------------

Corrplot requires Stata version 13 or greater.


Installation
---------------------------------

There are two options for installing corrplot.

1. The most recent version can be installed from Github with the following Stata command:

```stata
net install corrplot, from(https://raw.githubusercontent.com/mdroste/stata-corrplot/master/) replace force
```

2. A ZIP containing corrplot.ado and corrplot.sthlp can be downloaded from Github and manually placed on the user's adopath.


Usage
---------------------------------

Corrplot is really easy to use.

Here is a basic example using the 'auto' dataset of car characteristics.

```stata
* Load built-in dataset of car chracteristics
clear all
sysuse auto

* Plot the correlations between price and (mpg, trunk, weight, turn)
corrplot price mpg trunk weight turn
```

Internal documentation can be found within Stata:
```stata
help corrplot
```



Usage notes
---------------------------------

- This program plots confidence intervals by by normalizing all variables to have unit standard deviation, returning normal asymptotic standard errors from a regression of y on each x, and taking the +/- 1.96*se interval around the point estimate. In finite samples, when the point estimate for our sample correlation coefficient is near -1 or 1, this method known to [sometimes behave badly](http://faculty.washington.edu/gloftus/P317-318/Useful_Information/r_to_z/PearsonrCIs.pdf), since the sampling distribution can be skewed (and is therefore not well-approximated by a normal distribution). Using the option ci(fisher) produces confidence intervals using Fisher's z-transformation. Here's an example:

```stata
* Load built-in dataset of car chracteristics
clear all
sysuse auto

* Plot the correlations, with confidence intervals calculated using Fisher's z transform
corrplot price mpg trunk weight turn, ci(fisher)
```


  
Todo
---------------------------------

There are a few things I would like to add before submitting this to the SSC. In particular:
- [ ] Default Fisher transform CI's
- [ ] Finish off the internal documentation
- [ ] Pass additional options to twoway


Acknowledgements
---------------------------------

This program automates code that was used by Raj Chetty's awesome pre-doctoral fellows, now based at [Opportunity Insights](http://www.opportunityinsights.org), in 2016.


License
---------------------------------

corrplot is [MIT-licensed](https://github.com/mdroste/stata-corrplot/blob/master/LICENSE).
