# IPL Cricket Analysis --- Key Insights

## 1. Dataset Overview

The analysis covers **1,095 IPL matches** and **260,920 deliveries**
across **17 seasons**, from **2007/08 through 2024**.

The delivery dataset contains 19 batting teams, 673 batters and 530
bowlers.

## 2. Team Performance

Based on total match wins in the dataset:

-   Mumbai Indians --- 144 wins
-   Chennai Super Kings --- 138 wins
-   Kolkata Knight Riders --- 131 wins
-   Royal Challengers Bangalore --- 116 wins
-   Rajasthan Royals --- 112 wins

These are descriptive results from the dataset and are not adjusted for
differences in number of matches played.

## 3. Batting Leaders

The highest career run totals in the dataset include:

-   V Kohli --- 8,014 runs
-   S Dhawan --- 6,769 runs
-   DA Warner --- 6,567 runs
-   RG Sharma --- 6,360 runs
-   SK Raina --- 5,636 runs

The project also calculates strike rate for batters with at least 1,000
legal balls faced.

## 4. Bowling Leaders

The leading wicket-takers include:

-   YS Chahal --- 205 wickets
-   PP Chawla --- 192 wickets
-   DJ Bravo --- 183 wickets
-   B Kumar --- 181 wickets
-   R Ashwin --- 180 wickets

The bowling analysis excludes dismissals classified as run outs, retired
hurt and obstructing the field from the genuine-wicket count.

## 5. Toss Decision

The toss analysis separates matches according to whether the
toss-winning team chose to bat or field.

Historical results in the dataset show:

  Toss Decision     Matches   Toss Winner Match-Win %
  --------------- --------- -------------------------
  Field                 700                    53.86%
  Bat                   390                    45.38%

This is an observational comparison rather than a causal conclusion.

## 6. Venue Activity

The most frequently used venues include:

1.  Eden Gardens --- 77 matches
2.  Wankhede Stadium --- 73
3.  M Chinnaswamy Stadium --- 65
4.  Feroz Shah Kotla --- 60
5.  Rajiv Gandhi International Stadium, Uppal --- 49

## 7. Advanced SQL Analysis

The project includes three advanced analytical patterns.

### Window Functions

`RANK()` is used to identify the top batter within each season.

`LAG()` is used to compare a season's total runs with the previous
season.

### Subqueries

One query identifies batters whose career run totals are above the
average batter total.

Another identifies teams whose total wins are above the average team win
count.

### JOINs

Match-level and delivery-level data are joined using the match ID to
produce season-level team scoring analysis.

## 8. Data Quality

The delivery-level validation query returned zero missing values for the
core fields checked.

This validation is performed before the main analysis so that missing
identifiers or player/team fields do not silently affect the results.

## 9. Portfolio Takeaway

The main learning from this project is the progression from raw data to
analysis:

**Raw CSV → PostgreSQL tables → Data validation → SQL analysis →
Advanced SQL → Business-style insights**

The project demonstrates practical SQL rather than isolated syntax
exercises.
