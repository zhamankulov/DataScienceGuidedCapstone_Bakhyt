/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

select * 
from Facilities
where membercost = 0

/* Q2: How many facilities do not charge a fee to members? */

select count(*)
from Facilities
where membercost = 0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost > 0 AND membercost < (0.20 * monthlymaintenance);

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid in (1, 5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
	   case when monthlymaintenance > 100 then 'expensive'
		    else 'cheap' end as label
FROM Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT surname, firstname
FROM Members
where joindate = (select max(joindate) from Members)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT f.name AS facility_name, concat_ws(' ', m.firstname, m.surname) as name
FROM Bookings b
LEFT JOIN Facilities f ON b.facid = f.facid
LEFT JOIN Members m ON b.memid = m.memid
WHERE b.facid IN (0, 1) 
order by name 

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT F.name, concat_ws(' ', M.firstname, M.Surname),
	   case when B.memid = 0 then (B.slots * guestcost)*2
			else (B.slots * membercost)*2 end as cost
		
FROM Bookings B
left join Facilities F
on B.facid = F.facid
left join Members M 
on B.memid = M.memid
where Date(starttime) = '2012-09-14' and

(
    (B.memid = 0 AND B.slots * F.guestcost * 2 > 30) OR
    (B.memid != 0 AND B.slots * F.membercost * 2 > 30)
  )
order by cost desc


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT
    sub.facility_name,
    sub.name,
    sub.cost
FROM
    (
        SELECT 
            F.name as facility_name, 
            concat_ws(' ', M.firstname, M.surname) as name,
            CASE 
                WHEN B.memid = 0 THEN B.slots * F.guestcost * 2
                ELSE B.slots * F.membercost * 2
            END AS cost
        FROM 
            Bookings B
            LEFT JOIN Facilities F ON B.facid = F.facid
            LEFT JOIN Members M ON B.memid = M.memid
        WHERE 
            DATE(B.starttime) = '2012-09-14'
    ) AS sub
WHERE 
    sub.cost > 30
ORDER BY 
    sub.cost DESC;


/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

query1 = """
        select F.name, sum(case when B.memid = 0 then B.slots * F.guestcost 
                   else B.slots * F.membercost end) as total_revenue
        from Bookings B
        left join Facilities F
        on B.facid = F.facid
        group by F.name
        HAVING total_revenue < 1000
        order by total_revenue
        """

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

query1 = """
        SELECT 
            m1.surname as Surname,
            m1.firstname as Firstname, 
            case when m2.firstname = 'GUEST' then '- - -'
            else m2.firstname || ' ' || m2.surname end as Recomendation
        FROM 
            Members m1
        LEFT JOIN 
            Members m2 ON m1.recommendedby = m2.memid
        WHERE 
            m1.surname != 'GUEST' AND m1.firstname != 'GUEST'
        order by Surname, Firstname
        """

/* Q12: Find the facilities with their usage by member, but not guests */

query1 = """
        SELECT  
            F.name AS Facility,
            (M.firstname || ' ' || M.surname) AS Member,
            SUM(B.slots) AS Member_usage
        FROM 
            Bookings B
        JOIN 
            Facilities F ON B.facid = F.facid
        JOIN
            Members M ON B.memid = M.memid
        WHERE 
            B.memid != 0
        GROUP BY 
            Facility, Member
        ORDER BY 
            Member_usage DESC;
        """

/* Q13: Find the facilities usage by month, but not guests */

query1 = """
        SELECT  F.name AS Facility,
            strftime('%m', B.starttime) as Month,
            sum(B.slots) AS Monthly_usage
        FROM 
            Bookings B
        JOIN 
            Facilities F ON B.facid = F.facid
        WHERE 
            B.memid != 0
        GROUP BY Facility, Month
       
        """
