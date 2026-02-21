FROM node:18
WORKDIR /app

COPY Expense_with_healthcheck/backend/package*.json ./
RUN npm install

COPY Expense_with_healthcheck/backend/ .

EXPOSE 5000

ENV MONGO_URI=mongodb://db:27017/expense_db
ENV JWT_SECRET=e581372412881a8a196c46b1d9d13f45a42be030085c4ba2baad205a8bd822c3

CMD ["npm", "start"]
