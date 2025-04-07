# The Delivery Management System

The Delivery Management System is a comprehensive technological solution that helps
businesses optimize their shipping process, from order receipt to final delivery. W

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

  1. Open your terminal
  2. Change directory to this repository: `cd eshop`
  3. Export environment variables:
     1. `export AWS_REGION=your-aws-credentials`
     2. `export AWS_ACCESS_KEY_ID=your-aws-credentials`
     3. `export AWS_SECRET_ACCESS_KEY=your-aws-credentials`
     4. `export AWS_BUCKET=your-aws-credentials`
     5. `export STRIPE_PUBLISHABLE_KEY=your-stripe-credentials`
     6. `export STRIPE_SECRET_KEY=your-stripe-credentials`
     7. `export EXCHANGE_RATE_API_KEY=your-exchange-api-key`
     8. `export AUTH0_CLIENT_ID=your-auth0-credentials`
     9. `export AUTH0_DOMAIN=your-auth0-credentials`
     10. `export AUTH0_SCOPE=your-auth0-credentials`
  4. **This step is just required for the first run**, build projects:
     1. `docker compose build catalog-service basket-service review-service`
     2. `docker compose build storage-service vendor-service currency-service`
     3. `docker compose build discount-service coupon-service`
  5. **This step is just required for the first run**, initialize databases: `chmod +x ./bootstrap.sh && ./bootstrap.sh`
  6. Start application: `chmod +x ./start.sh && ./start.sh`
  7. Navigate to:
     1. [Customer web client](http://localhost:3000)
     2. [Vendor web client](http://localhost:3001)
     3. [Administration web client](http://localhost:3002)
