Effect of Diet on the Early Growth of Chicks
========================================================
author: Lawrence A. Tomaziefski
date: 20 February 2019
autosize: true

Background
========================================================

The body weights of the chicks were measured at birth and every second day thereafter until day 20. They were also measured on day 21. There were four groups on chicks on different protein diets. 

- The "ChickWeight"" data set has 578 rows and 4 columns from an experiment on the effect of diet on early growth of chicks.
- The body weights of the chicks were measured at birth and every second day thereafter until day 20. They were also measured on day 21. There were four groups on chicks on different protein diets.
- More information about this data set is found at: <https://www.rdocumentation.org/packages/datasets/versions/3.5.2/topics/ChickWeight>.

Exploring the "ChickWeight"" Data Set Further
========================================================
The "ChickWeight" dataset contains the following information:
- weight: Body weight of the chick in grams.
- Time: Day sinc birth the measurement was made (0-21).
- Chick: ID number of the chick measured (1-50). 
- Diet: A factor with levels 1 to 4 indicating which experimental diet the chick received.
![plot of chunk unnamed-chunk-1](Chick_Weights-figure/unnamed-chunk-1-1.png)

The Chick Weight Shiny App 
========================================================
The Chick Weight Shiny App is a simple app that helps analyst to conduct see the effects of the experimental diets over time and conduct pair-wise comparisons of the experimental diets effects.

- The app asks the user to select two experimental diets to compare and produces a plot comparing the chick weights over time.
- Use the following link to try the app: <https://www.rdocumentation.org/packages/datasets/versions/3.5.2/topics/ChickWeight>

The Chick Weight Shiny App Code
========================================================
The code to generate the app is found at:
<https://www.rdocumentation.org/packages/datasets/versions/3.5.2/topics/ChickWeight>


