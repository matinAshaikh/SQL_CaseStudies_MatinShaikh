/*Title: Employee Performance Analysis for Enhanced Productivity

Aim:
The aim of this case study is to utilize SQL for a comprehensive analysis of employee performance metrics, enabling informed decisions to enhance overall productivity and efficiency within the organization.

Objectives:
Analyze employee performance trends to understand productivity patterns.
Identify top-performing employees and areas of improvement.
Measure performance metrics such as efficiency, output, and attendance.
Implement strategies to boost employee productivity and job satisfaction.


SQL Tasks:

Performance Metrics Analysis:
Evaluate overall employee performance metrics (productivity, attendance, etc.).
Identify top-performing employees based on specified criteria.


Department-wise Performance Comparison:
Compare performance metrics among different departments.
Analyze the variance in productivity and efficiency across departments.


Employee Attendance Tracking:
Calculate and analyze attendance rates and trends.
Identify patterns related to absenteeism and punctuality.


Productivity Trends Over Time:
Analyze productivity trends over quarters or months.
Identify periods of high and low productivity.


Performance Review Scores Analysis:
Analyze and compare performance review scores among employees.
Identify correlations between review scores and other performance metrics.


Employee Engagement Analysis:
Measure and analyze employee engagement levels.
Evaluate factors impacting engagement and satisfaction.


Top Performer Recognition:
Identify employees consistently exceeding performance benchmarks.
Recognize and reward top performers based on key performance indicators (KPIs).

***************************************************************************************************/

--Performance Metrics Analysis:
SELECT employee_id, ROUND(AVG(productivity_score),2) AS avg_productivity
FROM performance_metrics
GROUP BY employee_id
ORDER BY 1;
/*
Justification: Measures the average productivity score for each employee to evaluate individual performance.
Purpose: Identifies employees with the highest average productivity scores.
Findings: Presents the average productivity score achieved by each employee.*/



--Department-wise Performance Comparison:
SELECT e.department_id, AVG(pm.productivity_score) AS avg_productivity
FROM employees e
JOIN performance_metrics pm ON e.employee_id = pm.employee_id
GROUP BY e.department_id;

/*
Justification: Compares the average productivity scores across different departments.
Purpose: Highlights performance disparities among various departments.
Findings: Reveals the average productivity score for each department.
*/


--Employee Attendance Tracking:
SELECT employee_id, COUNT(*) AS attendance_days
FROM attendance
GROUP BY employee_id;
/*
Justification: Counts the number of days each employee was present.
Purpose: Evaluates attendance patterns and identifies absenteeism rates.
Findings: Indicates the total days of attendance for each employee.
*/


--Productivity Trends Over Time:
SELECT EXTRACT(MONTH FROM performance_date) AS month, AVG(productivity_score) AS avg_productivity
FROM performance_metrics
GROUP BY EXTRACT(MONTH FROM performance_date)
ORDER BY EXTRACT(MONTH FROM performance_date);
/*
Justification: Calculates the average productivity score per month to analyze trends over time.
Purpose: Identifies monthly variations in productivity levels.
Findings: Indicates the average productivity score achieved each month.
*/


--Performance Review Scores Analysis:
SELECT employee_id, ROUND(AVG(review_score),2) AS avg_review_score
FROM performance_reviews
GROUP BY employee_id
ORDER BY 1;
/*
Justification: Computes the average performance review score for each employee.
Purpose: Evaluates the overall performance based on review scores.
Findings: Displays the average review score for each employee.
*/


--Employee Engagement Analysis:
SELECT employee_id, ROUND(AVG(employee_engagement_score),2) AS avg_engagement_score
FROM employee_engagement
GROUP BY employee_id
ORDER BY 1;

/*
Justification: Calculates the average engagement score for each employee.
Purpose: Assesses the level of employee engagement within the organization.
Findings: Shows the average engagement score per employee.
*/


--Top Performer Recognition:
SELECT employee_id, productivity_score, RANK() OVER (ORDER BY productivity_score DESC) AS performance_rank
FROM performance_metrics;

/*
Justification: Ranks employees based on their productivity scores.
Purpose: Identifies top-performing employees in terms of productivity.
Findings: Ranks employees according to their productivity scores.
*/


--Training Impact Assessment:
SELECT t.training_name, COUNT(*) AS employees_attended
FROM training_records tr
JOIN trainings t ON tr.training_id = t.training_id
GROUP BY t.training_name;
/*
Justification: Counts the number of employees attending each training session.
Purpose: Evaluates training effectiveness and participation rates.
Findings: Indicates the count of employees attending each training session.
*/
============================================================================================================================

--Employee Performance Metrics Joining Multiple Tables:
SELECT e.employee_id, e.employee_name, pm.productivity_score, pr.review_score
FROM employees e
JOIN performance_metrics pm ON e.employee_id = pm.employee_id
JOIN performance_reviews pr ON e.employee_id = pr.employee_id;

/*
Justification: Combines employee details with their performance metrics and review scores.
Purpose: Provides a comprehensive view of employee performance metrics.
Findings: Presents employee details along with their productivity and review scores.
*/


--Employee Performance Over Time with Window Function:
SELECT DISTINCT
    employee_id, 
    EXTRACT(YEAR FROM performance_date) AS year, 
    AVG(productivity_score) OVER (PARTITION BY employee_id, EXTRACT(YEAR FROM performance_date)) AS avg_prod_score
FROM performance_metrics
ORDER BY 1, 2;

/*
Justification: Uses a window function to calculate the average productivity score over time for each employee.
Purpose: Analyzes the trend of productivity scores for individual employees.
Findings: Indicates the average productivity score progression for each employee across different years.
*/


--Employee Engagement Trend Using CTE:
WITH monthly_engagement AS (
    SELECT employee_id, EXTRACT(MONTH FROM engagement_date) AS month, 
           AVG(employee_engagement_score) AS avg_engagement
    FROM employee_engagement
    GROUP BY employee_id, EXTRACT(MONTH FROM engagement_date)
)
SELECT employee_id, month, avg_engagement,
       DENSE_RANK() OVER (PARTITION BY employee_id ORDER BY avg_engagement DESC) AS engagement_rank
FROM monthly_engagement;

/*
Justification: Utilizes a Common Table Expression (CTE) to calculate monthly employee engagement scores.
Purpose: Tracks the trend in employee engagement scores and ranks employees based on monthly engagement.
Findings: Shows the monthly average engagement scores and ranks employees accordingly.
*/


--Training Impact Assessment with Joins:
SELECT t.training_id, t.training_name, COUNT(*) AS employees_attended
FROM trainings t
LEFT JOIN training_records tr ON t.training_id = tr.training_id
GROUP BY t.training_id, t.training_name
ORDER BY 1;

/*
Justification: Uses a LEFT JOIN to list all training sessions and the count of employees attending each.
Purpose: Evaluates the attendance and effectiveness of training sessions.
Findings: Displays the count of employees attending each training session along with training details.
*/



--Average Performance Review Scores by Department:
SELECT e.department_id, AVG(pr.review_score) AS avg_review_score
FROM employees e
JOIN performance_reviews pr ON e.employee_id = pr.employee_id
GROUP BY e.department_id
ORDER BY 1;

/*
Justification: Joins employee and performance review tables to calculate average review scores per department.
Purpose: Assesses the performance of different departments based on review scores.
Findings: Shows the average review score for each department.
*/


--Top Performing Departments Using Subquery:
SELECT e.department_id, AVG(pm.productivity_score) AS avg_prod_score
FROM employees e
JOIN performance_metrics pm ON e.employee_id = pm.employee_id
GROUP BY e.department_id
HAVING AVG(pm.productivity_score) > (
    SELECT AVG(productivity_score) FROM performance_metrics
);

/*
Justification: Uses a subquery to compare departmental productivity scores against the overall average.
Purpose: Identifies departments with productivity scores higher than the overall average.
Findings: Lists departments with above-average productivity scores.
*/


--Performance Improvement with Lag Function:
SELECT 
    employee_id,performance_date, 
    productivity_score, 
    LAG(productivity_score) OVER (PARTITION BY employee_id ORDER BY performance_date) AS prev_prod_score,
    CASE 
        WHEN productivity_score - LAG(productivity_score) OVER (PARTITION BY employee_id ORDER BY performance_date) > 0 THEN 'up'
        WHEN productivity_score - LAG(productivity_score) OVER (PARTITION BY employee_id ORDER BY performance_date) < 0 THEN 'down'
        ELSE 'constant'
    END AS remark
FROM performance_metrics;

/*
Justification: Utilizes the LAG window function to compare an employee's current productivity score with their previous score.
Purpose: Analyzes the improvement or decline in an employee's productivity over time.
Findings: Shows the previous productivity score for each employee.
*/


--Employee Performance Distribution Analysis:
SELECT NTILE(4) OVER (ORDER BY productivity_score) AS performance_group, COUNT(*) AS employees_count
FROM performance_metrics;

/*
Justification: Uses NTILE to distribute employees into quartiles based on their productivity scores.
Purpose: Segregates employees into performance groups to assess the distribution across quartiles.
Findings: Presents the count of employees within each quartile based on their productivity scores.
*/


--Employee Performance Comparison Between Departments:
SELECT e.department_id, e.employee_id, e.employee_name, pm.productivity_score,
       RANK() OVER (PARTITION BY e.department_id ORDER BY pm.productivity_score DESC) AS dept_rank
FROM employees e
JOIN performance_metrics pm ON e.employee_id = pm.employee_id;

/*
Justification: Compares employee productivity scores within their respective departments.
Purpose: Ranks employees in each department based on productivity scores.
Findings: Shows the ranking of employees within their departments based on productivity scores.
*/


--Employee Engagement Variation by Year:
SELECT employee_id, EXTRACT(YEAR FROM engagement_date) AS year, 
       MAX(employee_engagement_score) - MIN(employee_engagement_score) AS engagement_variation
FROM employee_engagement
GROUP BY employee_id, year
ORDER BY 1, 2;

/*
Justification: Determines the variation in employee engagement scores within each year.
Purpose: Identifies yearly changes in employee engagement levels.
Findings: Indicates the difference in engagement scores within each year for employees.
*/



=======================================================================================================
/*
Outcome:
Enhanced Employee Performance Metrics: The analysis provided an in-depth understanding of employee performance metrics, offering insights into individual and departmental productivity, engagement trends, and training effectiveness.
Identified Performance Trends: Analyzing performance scores over time revealed trends in employee productivity and engagement, aiding in recognizing patterns and areas for improvement.
Assessment of Training Impact: By evaluating training attendance and effectiveness, the study identified the impact of training sessions on employee performance.

Recommendations:
Targeted Training Programs: Based on the analysis of training effectiveness, implement more targeted and impactful training programs focusing on areas that directly impact performance metrics.
Employee Engagement Strategies: Develop strategies to improve engagement, leveraging insights gained from employee engagement trends, and identifying factors influencing engagement variations.
Performance Improvement Initiatives: Initiate programs that recognize and reward high-performing departments or individuals, fostering a culture of performance excellence.


Conclusion:
The Employee Performance Analysis Case Study allowed for a comprehensive evaluation of employee performance, engagement, and training impact. The findings unveiled patterns, trends, and areas of improvement crucial for fostering a more productive and engaged workforce. By leveraging data-driven insights, the study offers actionable recommendations aimed at enhancing training programs, improving engagement, and implementing performance-driven initiatives. Ultimately, this analysis sets the groundwork for an ongoing strategy to optimize employee performance and contribute to the company's success.
*/
