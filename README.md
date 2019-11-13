# SQL-Example
These are examples of SQL queries I've written for work. I've updated them many times at work as needed. 

Two of the latest examples from work. I wrote a query for a view that I am using in an Informatica ETL process. The script used to take 375 seconds to return 50 rows, and two hours to process 50k rows.

Since my Informatica workflow was timing out because of this script, I did some research on subqueries compared to unions and after I understood the EXPLAIN PLAN feature of SQL Developer, I realized that if I broke up the two subqueries into separate queries with a UNION I could get improved performance. 

Once I tried the new SQL, it took 0.866 seconds to return 50 rows which was an almost 400x improvement in performance. I have this deployed in our Production environment now. 


I've also attached another sample of a "fallout" report I put together for work. This report goes out at the end of every day and tells the admin team what the errors were for all the records that failed to load throughout the day. The application we use (SAP Producer Pro) doesn't allow us to export error messages encountered within the application so I had to reverse engineer the logic behind the most common errors. 