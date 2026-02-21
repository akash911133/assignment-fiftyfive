FROM node:18 AS build
WORKDIR /app
COPY ExpenseTracker/frontend/expense-tracker/package*.json ./
RUN npm install
COPY ExpenseTracker/frontend/expense-tracker/ .
RUN npm run build


FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
