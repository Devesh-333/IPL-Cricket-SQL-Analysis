IPL Cricket Analysis - SQL Portfolio Project

Project Overview

This project analyzes IPL match and ball-by-ball data from the
2007/08--2024 seasons using PostgreSQL.

The analysis focuses on:

-   Team performance and winning patterns
-   Top run scorers
-   Batting efficiency and strike rate
-   Bowling effectiveness and wickets
-   Season trends
-   Toss decisions and match outcomes
-   Batting first vs chasing
-   Team run-scoring performance
-   Boundary hitters
-   Player of the Match awards
-   Venue activity
-   Season-level batting leaders
-   Year-over-year run trends

Dataset

The project uses the IPL Complete Dataset containing:

-   `matches.csv` --- match-level information
-   `deliveries.csv` --- ball-by-ball information

Dataset scale

  Metric              Value
  --------------- ---------
  Matches             1,095
  Deliveries        260,920
  Batting teams          19
  Batters               673
  Bowlers               530
  Seasons                17
  Total runs        347,756

Tools & Skills

**Tools** - PostgreSQL - SQL - Terminal / psql

**SQL concepts demonstrated** - SELECT - WHERE - GROUP BY - ORDER BY -
Aggregate functions - FILTER - CASE statements - CTEs - JOINs -
Subqueries - Window functions - RANK() - LAG() - Data-quality checks

Project Structure

``` text
IPL_Cricket_Analysis/
│
├── IPL_Cricket_Analysis_Final.sql
├── README.md
└── insights.md
```

Analysis Sections

The SQL project contains 22 analysis sections covering:

1.  Project overview
2.  Data-quality checks
3.  Team performance
4.  Batting leaders
5.  Batting efficiency / strike rate
6.  Bowling effectiveness
7.  Season trends
8.  Winning team by season
9.  Toss decision vs match result
10. Batting first vs chasing
11. Team run-scoring performance
12. Top six-hitters
13. Top four-hitters
14. Wicket-taking leaders
15. Team runs by season
16. Player of the Match leaders
17. Venue analysis
18. Project summary
19. Top batter per season using `RANK()`
20. Year-over-year run trend using `LAG()`
21. Batters above the overall run average using a subquery
22. Teams above the average match-win count using a subquery

Key Findings

Team Performance

The team-match analysis shows the following teams among the highest in
total wins:

  Team                            Matches Played   Wins
  ----------------------------- ---------------- ------
  Mumbai Indians                             261    144
  Chennai Super Kings                        238    138
  Kolkata Knight Riders                      251    131
  Royal Challengers Bangalore                240    116
  Rajasthan Royals                           221    112

Batting Leaders

The leading run scorers in the dataset include:

  Player         Runs
  ----------- -------
  V Kohli       8,014
  S Dhawan      6,769
  DA Warner     6,567
  RG Sharma     6,360
  SK Raina      5,636

Wicket Leaders

The leading wicket-takers include:

  Bowler        Wickets
  ----------- ---------
  YS Chahal         205
  PP Chawla         192
  DJ Bravo          183
  B Kumar           181
  R Ashwin          180

Toss Analysis

Among matches where a result was recorded:

-   Teams choosing to **field** after winning the toss: 700 matches
-   Toss winner won the match after choosing to field: **53.86%**
-   Teams choosing to **bat** after winning the toss: 390 matches
-   Toss winner won the match after choosing to bat: **45.38%**

These figures describe the historical dataset; they do not establish
that the toss decision causes the result.

Venue Activity

The most frequently used venues in the dataset include:

-   Eden Gardens --- 77 matches
-   Wankhede Stadium --- 73
-   M Chinnaswamy Stadium --- 65
-   Feroz Shah Kotla --- 60
-   Rajiv Gandhi International Stadium, Uppal --- 49

Data Quality

A delivery-level data-quality check was included before the analysis.

The executed project returned **0 missing values** for the core fields
checked:

-   `match_id`
-   `batting_team`
-   `bowling_team`
-   `batter`
-   `bowler`
-   `batsman_runs`
-   `total_runs`

Why This Project Matters

This project demonstrates how SQL can be used to turn raw sports data
into structured performance analysis.

It goes beyond simple `GROUP BY` queries by using:

-   CTEs to structure multi-step analysis
-   JOINs to combine match and delivery-level data
-   Window functions to rank players by season and compare seasons
-   Subqueries to compare players and teams against overall averages
-   Conditional aggregation to calculate wins, wickets and toss outcomes

How to Run

1.  Install PostgreSQL.
2.  Create a database named `ipl analysis`.
3.  Import `matches.csv` into the `matches` table.
4.  Import `deliveries.csv` into the `deliveries` table.
5.  Open the SQL file in pgAdmin or run it through `psql`.
6.  Execute the queries section by section or run the complete file.

Author

Devesh Singh Panwar**

B.Com (Hons) - Doon University

Interested in SQL, data analytics, finance, AI and business strategy.
