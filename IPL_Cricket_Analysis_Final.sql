/* ============================================================
   IPL CRICKET ANALYSIS — 2007/08–2024
   PostgreSQL Portfolio Project

   Dataset:
   - matches.csv
   - deliveries.csv

   Objective:
   Analyze IPL team performance, batting, bowling,
   season trends, toss decisions and match strategy.

   Database:
   PostgreSQL
   ============================================================ */


/* ============================================================
   1. PROJECT OVERVIEW
   ============================================================ */

-- Overall dataset scale
SELECT
    COUNT(DISTINCT match_id) AS total_matches,
    COUNT(*) AS total_deliveries,
    COUNT(DISTINCT batting_team) AS batting_teams,
    COUNT(DISTINCT bowler) AS bowlers,
    COUNT(DISTINCT batter) AS batters,
    SUM(CAST(total_runs AS INTEGER)) AS total_runs
FROM deliveries;


/* ============================================================
   2. DATA QUALITY CHECK
   ============================================================ */

-- Check for missing values in the core delivery-level fields.
SELECT
    COUNT(*) AS total_deliveries,

    COUNT(*) FILTER (
        WHERE match_id IS NULL
    ) AS missing_match_id,

    COUNT(*) FILTER (
        WHERE batting_team IS NULL
    ) AS missing_batting_team,

    COUNT(*) FILTER (
        WHERE bowling_team IS NULL
    ) AS missing_bowling_team,

    COUNT(*) FILTER (
        WHERE batter IS NULL
    ) AS missing_batter,

    COUNT(*) FILTER (
        WHERE bowler IS NULL
    ) AS missing_bowler,

    COUNT(*) FILTER (
        WHERE batsman_runs IS NULL
    ) AS missing_batsman_runs,

    COUNT(*) FILTER (
        WHERE total_runs IS NULL
    ) AS missing_total_runs
FROM deliveries;


/* ============================================================
   3. TEAM PERFORMANCE & WINNING PATTERNS
   ============================================================ */

-- Treat each appearance of a team as one team-match record.
WITH team_matches AS (
    SELECT team1 AS team, id, winner
    FROM matches

    UNION ALL

    SELECT team2 AS team, id, winner
    FROM matches
)
SELECT
    team,
    COUNT(*) AS matches_played,

    COUNT(*) FILTER (
        WHERE winner = team
    ) AS wins,

    ROUND(
        COUNT(*) FILTER (WHERE winner = team)::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS win_percentage

FROM team_matches
WHERE team IS NOT NULL
GROUP BY team
ORDER BY wins DESC;


/* ============================================================
   4. BATTING LEADERS
   ============================================================ */

SELECT
    batter,
    COUNT(DISTINCT match_id) AS matches,
    SUM(CAST(batsman_runs AS INTEGER)) AS runs,

    COUNT(*) FILTER (
        WHERE batsman_runs = '4'
    ) AS fours,

    COUNT(*) FILTER (
        WHERE batsman_runs = '6'
    ) AS sixes

FROM deliveries
GROUP BY batter
ORDER BY runs DESC
LIMIT 15;


/* ============================================================
   5. BATTING EFFICIENCY — STRIKE RATE
   Minimum 1,000 legal balls faced
   ============================================================ */

SELECT
    batter,

    COUNT(*) FILTER (
        WHERE extras_type IS DISTINCT FROM 'wides'
    ) AS balls_faced,

    SUM(CAST(batsman_runs AS INTEGER)) AS runs,

    COUNT(*) FILTER (
        WHERE batsman_runs = '4'
    ) AS fours,

    COUNT(*) FILTER (
        WHERE batsman_runs = '6'
    ) AS sixes,

    ROUND(
        SUM(CAST(batsman_runs AS INTEGER))::NUMERIC
        / NULLIF(
            COUNT(*) FILTER (
                WHERE extras_type IS DISTINCT FROM 'wides'
            ),
            0
        ) * 100,
        2
    ) AS strike_rate

FROM deliveries
GROUP BY batter

HAVING COUNT(*) FILTER (
    WHERE extras_type IS DISTINCT FROM 'wides'
) >= 1000

ORDER BY strike_rate DESC;


/* ============================================================
   6. BOWLING EFFECTIVENESS
   Genuine wickets + economy
   Minimum 500 legal deliveries
   ============================================================ */

SELECT
    bowler,
    COUNT(DISTINCT match_id) AS matches,

    COUNT(*) FILTER (
        WHERE is_wicket = '1'
        AND dismissal_kind NOT IN
            ('run out', 'retired hurt', 'obstructing the field')
    ) AS wickets,

    ROUND(
        SUM(
            CASE
                WHEN extras_type IS DISTINCT FROM 'wides'
                AND extras_type IS DISTINCT FROM 'noballs'
                THEN CAST(total_runs AS INTEGER)
                ELSE 0
            END
        )::NUMERIC
        /
        NULLIF(
            COUNT(*) FILTER (
                WHERE extras_type IS DISTINCT FROM 'wides'
                AND extras_type IS DISTINCT FROM 'noballs'
            ),
            0
        ) * 6,
        2
    ) AS economy

FROM deliveries
GROUP BY bowler

HAVING COUNT(*) FILTER (
    WHERE extras_type IS DISTINCT FROM 'wides'
    AND extras_type IS DISTINCT FROM 'noballs'
) >= 500

ORDER BY wickets DESC;


/* ============================================================
   7. SEASON TRENDS
   ============================================================ */

SELECT
    season,
    COUNT(*) AS total_matches,

    COUNT(*) FILTER (
        WHERE winner IS NOT NULL
    ) AS decided_matches,

    COUNT(*) FILTER (
        WHERE winner IS NULL
    ) AS no_result_matches

FROM matches
GROUP BY season
ORDER BY season;


/* ============================================================
   8. WINNING TEAM BY SEASON
   ============================================================ */

SELECT
    season,
    winner AS winning_team,
    COUNT(*) AS wins

FROM matches
WHERE winner IS NOT NULL
GROUP BY season, winner
ORDER BY season, wins DESC;


/* ============================================================
   9. TOSS DECISION VS MATCH RESULT
   ============================================================ */

SELECT
    toss_decision,
    COUNT(*) AS total_matches,

    COUNT(*) FILTER (
        WHERE toss_winner = winner
    ) AS toss_winner_wins,

    ROUND(
        COUNT(*) FILTER (
            WHERE toss_winner = winner
        )::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS toss_to_match_win_percentage

FROM matches
WHERE toss_winner IS NOT NULL
  AND winner IS NOT NULL
GROUP BY toss_decision
ORDER BY toss_to_match_win_percentage DESC;


/* ============================================================
   10. BATTING FIRST VS CHASING
   Actual first-innings strategy derived from the toss outcome
   ============================================================ */

WITH innings_strategy AS (
    SELECT
        id,
        winner,
        CASE
            WHEN toss_decision = 'bat' THEN toss_winner
            WHEN toss_decision = 'field' THEN
                CASE
                    WHEN toss_winner = team1 THEN team2
                    WHEN toss_winner = team2 THEN team1
                END
        END AS first_batting_team
    FROM matches
    WHERE toss_decision IS NOT NULL
      AND toss_winner IS NOT NULL
      AND winner IS NOT NULL
),
strategy_summary AS (
    SELECT
        COUNT(*) AS decided_matches,
        COUNT(*) FILTER (WHERE winner = first_batting_team) AS bat_first_wins,
        COUNT(*) FILTER (WHERE winner <> first_batting_team) AS chasing_wins
    FROM innings_strategy
)
SELECT
    'Bat First' AS strategy,
    decided_matches AS matches,
    bat_first_wins AS wins,
    ROUND(bat_first_wins::NUMERIC / NULLIF(decided_matches, 0) * 100, 2) AS win_percentage
FROM strategy_summary

UNION ALL

SELECT
    'Chase' AS strategy,
    decided_matches AS matches,
    chasing_wins AS wins,
    ROUND(chasing_wins::NUMERIC / NULLIF(decided_matches, 0) * 100, 2) AS win_percentage
FROM strategy_summary

ORDER BY win_percentage DESC;


/* ============================================================
   11. TEAM RUN-SCORING PERFORMANCE
   ============================================================ */

SELECT
    batting_team,
    COUNT(DISTINCT match_id) AS matches,
    SUM(CAST(total_runs AS INTEGER)) AS total_runs,

    ROUND(
        SUM(CAST(total_runs AS INTEGER))::NUMERIC
        / COUNT(DISTINCT match_id),
        2
    ) AS runs_per_match

FROM deliveries
GROUP BY batting_team
ORDER BY total_runs DESC;


/* ============================================================
   12. TOP SIX-HITTERS
   ============================================================ */

SELECT
    batter,

    COUNT(*) FILTER (
        WHERE batsman_runs = '6'
    ) AS sixes,

    SUM(CAST(batsman_runs AS INTEGER)) AS runs

FROM deliveries
GROUP BY batter
ORDER BY sixes DESC
LIMIT 15;


/* ============================================================
   13. TOP FOUR-HITTERS
   ============================================================ */

SELECT
    batter,

    COUNT(*) FILTER (
        WHERE batsman_runs = '4'
    ) AS fours,

    SUM(CAST(batsman_runs AS INTEGER)) AS runs

FROM deliveries
GROUP BY batter
ORDER BY fours DESC
LIMIT 15;


/* ============================================================
   14. WICKET-TAKING LEADERS
   Genuine wickets only
   ============================================================ */

SELECT
    bowler,
    COUNT(DISTINCT match_id) AS matches,

    COUNT(*) FILTER (
        WHERE is_wicket = '1'
        AND dismissal_kind NOT IN
            ('run out', 'retired hurt', 'obstructing the field')
    ) AS wickets

FROM deliveries
GROUP BY bowler
ORDER BY wickets DESC
LIMIT 15;


/* ============================================================
   15. TEAM RUNS BY SEASON
   ============================================================ */

SELECT
    m.season,
    d.batting_team,
    SUM(CAST(d.total_runs AS INTEGER)) AS total_runs

FROM matches m
JOIN deliveries d
    ON m.id::TEXT = d.match_id

GROUP BY m.season, d.batting_team
ORDER BY m.season, total_runs DESC;


/* ============================================================
   16. PLAYER OF THE MATCH LEADERS
   ============================================================ */

SELECT
    player_of_match,
    COUNT(*) AS awards

FROM matches
WHERE player_of_match IS NOT NULL
GROUP BY player_of_match
ORDER BY awards DESC
LIMIT 15;


/* ============================================================
   17. VENUE ANALYSIS
   ============================================================ */

SELECT
    venue,
    COUNT(*) AS matches

FROM matches
WHERE venue IS NOT NULL
GROUP BY venue
ORDER BY matches DESC
LIMIT 15;


/* ============================================================
   18. PROJECT SUMMARY
   ============================================================ */

SELECT
    COUNT(DISTINCT id) AS total_matches,
    COUNT(DISTINCT season) AS seasons,
    COUNT(DISTINCT venue) AS venues,
    COUNT(DISTINCT player_of_match) AS unique_player_of_match_players
FROM matches;


/* ============================================================
   19. WINDOW FUNCTION — TOP BATTER PER SEASON
   Rank each batter within every IPL season
   ============================================================ */

WITH batter_season_runs AS (
    SELECT
        m.season,
        d.batter,
        SUM(CAST(d.batsman_runs AS INTEGER)) AS runs
    FROM matches m
    JOIN deliveries d
        ON m.id::TEXT = d.match_id
    GROUP BY m.season, d.batter
),
ranked_batters AS (
    SELECT
        season,
        batter,
        runs,
        RANK() OVER (
            PARTITION BY season
            ORDER BY runs DESC
        ) AS season_rank
    FROM batter_season_runs
)
SELECT
    season,
    batter,
    runs
FROM ranked_batters
WHERE season_rank = 1
ORDER BY season;


/* ============================================================
   20. WINDOW FUNCTION — YEAR-OVER-YEAR RUN TREND
   Compare each season's total runs with the previous season
   ============================================================ */

WITH season_runs AS (
    SELECT
        m.season,
        SUM(CAST(d.total_runs AS INTEGER)) AS total_runs
    FROM matches m
    JOIN deliveries d
        ON m.id::TEXT = d.match_id
    GROUP BY m.season
),
season_comparison AS (
    SELECT
        season,
        total_runs,
        LAG(total_runs) OVER (ORDER BY season) AS previous_season_runs
    FROM season_runs
)
SELECT
    season,
    total_runs,
    previous_season_runs,
    total_runs - previous_season_runs AS run_change
FROM season_comparison
ORDER BY season;


/* ============================================================
   21. SUBQUERY — BATTERS ABOVE THE OVERALL RUN AVERAGE
   Find batters whose career runs exceed the average batter total
   ============================================================ */

SELECT
    batter,
    SUM(CAST(batsman_runs AS INTEGER)) AS runs
FROM deliveries
GROUP BY batter
HAVING SUM(CAST(batsman_runs AS INTEGER)) > (
    SELECT AVG(player_runs)
    FROM (
        SELECT
            SUM(CAST(batsman_runs AS INTEGER)) AS player_runs
        FROM deliveries
        GROUP BY batter
    ) AS batter_totals
)
ORDER BY runs DESC;


/* ============================================================
   22. SUBQUERY — TEAMS ABOVE THE AVERAGE MATCH WIN COUNT
   Compare each team's wins against the league-wide average
   ============================================================ */

SELECT
    winner AS team,
    COUNT(*) AS wins
FROM matches
WHERE winner IS NOT NULL
GROUP BY winner
HAVING COUNT(*) > (
    SELECT AVG(team_wins)
    FROM (
        SELECT
            winner,
            COUNT(*) AS team_wins
        FROM matches
        WHERE winner IS NOT NULL
        GROUP BY winner
    ) AS win_totals
)
ORDER BY wins DESC;


/* ============================================================
   END OF PROJECT
   ============================================================ */
