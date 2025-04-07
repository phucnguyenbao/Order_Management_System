# The Delivery Management System

The Delivery Management System is a comprehensive technological solution that helps
businesses optimize their shipping process, from order receipt to final delivery.

## Technology Stack
- Front-end: ReactJS and other additional libraries provided by npm.
- Back-end: JavaScript, PHP, HTML/CSS
- Database: SQL.

## Architecture
Frontend: When the user performs actions such as adding, editing, or deleting an order, React sends a request (POST, GET, DELETE) to the PHP APIs.

Backend: The PHP APIs receive the request, process the data, and perform actions with the database.

Database: The database performs actions like querying, updating, or deleting data.

Frontend: The backend returns the result (success or error), and React updates the user interface based on that result.

## Prerequisites

  1. [Node.js](https://nodejs.org/)
  2. [npm](https://www.npmjs.com/)
  3. [React]( https://reactjs.org/)
  4. [PHP](https://www.php.net/downloads.php)
  5. [SQl](https://learn.microsoft.com/en-us/ssms/download-sql-server-management-studio-ssms)

## Instructions
  1. Open your SQL client and run the database.sql script located in the database folder to create the database schema and tables
  2. Open your terminal
  3. Change directory to this repository: `cd \Order_Management_System\Order_Management_System-main\client\src`
  4. Run ' npm install '
  5. Open db_connection.php in folder server change server name, database name,... and  run ' npm start ' 
  6. Navigate to client web: http://localhost:3000
  7. Change directory to this repository: `cd \Order_Management_System\Order_Management_System-main\server`
  8. Run ' php -S localhost:8000'
