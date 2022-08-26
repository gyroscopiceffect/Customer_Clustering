# The package for MySql Connection 
# install.packages("RMySQL")
library(RMySQL)

# Lets connect the Database
mydb = dbConnect(MySQL(), user='root', password='serdar27', dbname='transaction_database', host='127.0.0.1')
class(mydb)
# We can list the tables
dbListTables(mydb)
# Result looks as below comments 
# [1] "clusters"        "customer_survey" "customers"       "discounts"       "items"          
# [6] "sales"           "stores"          "transactions"    "zipdata"

# We can list the fields of any table 
dbListFields(mydb, 'stores')

# Lets create a table, call it try_table
dbSendQuery(mydb," CREATE TABLE try_table(try_id INT, try_title VARCHAR(50) );")

#Lets drop that table, It was only try 
dbSendQuery(mydb, 'drop table if exists try_table')

# We can fetch any table to R Environment, we can define how much rows to extract
# we can also use dbGetQuery() 
result<- dbSendQuery(mydb, "select * from sales")

# Store the result in a R data frame object. n = 5 is used to fetch first 5 rows.
# if you write n=-1, then you would get all table 
data.frame<- fetch(result, n = 5)
print(data.frame)
#We need to close resultSet before continuing
dbClearResult(result)
dbClearResult()

#Lets count the number of stores from stores table, and save it as an integer
# Sql Query counts rows of store table (counts store ids which is primary key)
# And its dataframe which has 1 column 1 row 
nb_store<-fetch(dbSendQuery(mydb, "select count(*) from stores;"))[1,1]

# Class of nb_store is dataframe, You can check it
class(nb_store)
print(nb_store)
#Other way to count stores, extract the store table and count in R
stores<-fetch(dbSendQuery(mydb, "select * from stores;"))
nrow(stores)


#lets count cities , those have the stores. Dont forget One city may have more 
#than one store and a city name may belong to different state.

nb_cities<-fetch(dbSendQuery(mydb, "select count(distinct store_city,store_state) from stores;"))[1,1]
print(nb_cities)



colnames(stores)
unique(stores[c("Store_City","Store_State")])
nrow(unique(stores[c("Store_City","Store_State")]))

con<-"Select distinct store_city, store_state, count(*) from stores 
group by store_city, 
store_state order by count(*) desc;"

fetch(dbSendQuery(mydb, con))





stores %>%
  distinct(Store_City,Store_State,Store_ID) %>%
  group_by(Store_City,Store_State) %>%
  summarize("Store Number"=n())

sales<-fetch(dbSendQuery(mydb, "select * from sales;"),n=Inf)
total_sales<-nrow(sales)

head(sales,5)

fetch(dbSendQuery(mydb, "Select count(distinct sale_week) from sales;"))

nb_weeks<-n_distinct(sales$Sale_Week)


sapply(sales, function(Sale_Week) n_distinct(Sale_Week))['Sale_Week']

sales_per_week<-total_sales/nb_weeks

(fetch(dbSendQuery(mydb,"select count(*) sales_per_week from sales where store_id=1")))/52

class(sales)
sales$Sale_ID
rm<-sales[sales$Store_ID==1,]
nrow(rm)/52
 
nrow(sales[sales$Store_ID==1,])/52

sales[sales$Store_ID==1,]

stores[stores$Store_ID==1,]$Store_Name


stores[stores$Store_ID==1,]$Store_City


sum(sales$Store_ID == 1, na.rm=TRUE)/52



df<-sales %>% 
  #distinct(Store_ID) %>%
  group_by(Store_ID) %>%
  summarize("Sales_per_Week"=n()/52)


class(df)
Aver_sales_per_week = as.data.frame(df)
class(Aver_sales_per_week)
Aver_sales_per_week

rm(df)
df<-stores[c('Store_ID','Store_Name','Store_City','Store_State')]
df

merge(Aver_sales_per_week,df,by='Store_ID')


Aver_sales_per_week
class(stores)



head(sales)

library(sqldf)
require(sqldf)
detach("package:RMySQL", unload=TRUE)

Aver_sales_per_week

df9 = sqldf('select df1.*, df2.* from df1 left join df2 on df1.ID = df2.ID')

sqldf('select Aver_sales_per_week.Store_ID,Sales_per_Week,
      Store_Name,Store_City,Store_State
      from Aver_sales_per_week left join stores on 
      Aver_sales_per_week.Store_ID=stores.Store_ID
      ')

sqldf("SELECT * from stores")



head(stores)
Aver_sales_per_week


qry<-dbSendQuery(mydb," CREATE TABLE SalesData AS (SELECT s.Customer_ID, s.Sale_ID, s.Store_ID,
SUM(t.Amount_Purchased) CountItems,
SUM(t.Amount_Purchased*i.Price_Per_Item*(1 -d.Item_Discount)) SalePrice
FROM Sales s
RIGHT JOIN Transactions t
ON t.Sale_ID= s.Sale_ID
LEFT JOIN Discounts d
ON d.Sale_Week= s.Sale_Week AND d.Item_ID= t.Item_ID
LEFT JOIN Items i
ON i.Item_ID= t.Item_ID
GROUP BY s.Sale_ID, s.Customer_ID, s.Store_ID);")

dbClearResult(qry)

qry<-dbSendQuery(mydb,"DROP TABLE SalesData ")
dbClearResult(qry)

detach("package:sqldf", unload=TRUE)


qrry<-dbSendQuery(mydb,"
  CREATE TABLE SalesData AS (SELECT s.Customer_ID, s.Sale_ID, s.Store_ID,
  SUM(t.Amount_Purchased) CountItems,
  SUM(t.Amount_Purchased*i.Price_Per_Item*(1-d.Item_Discount)) SalePrice
  FROM Sales s
  RIGHT JOIN Transactions t
  ON t.Sale_ID = s.Sale_ID
  LEFT JOIN Discounts d
  ON d.Sale_Week= s.Sale_Week AND d.Item_ID= t.Item_ID
  LEFT JOIN Items i
  ON i.Item_ID= t.Item_ID
  GROUP BY s.Sale_ID, s.Customer_ID, s.Store_ID);")
dbClearResult(qrry)

b<-fetch(dbSendQuery(mydb,"select * from SalesData"),n=10)
dbClearResult()
a

ser<-dbSendQuery(mydb,"create table serdar ( ss INT)")
dbClearResult(ser)


qry<-dbSendQuery(mydb,"select * from SalesData")
dtf<- fetch(qry, n = 5)
print(dtf)

result<-dbSendQuery(mydb,"select sales.sale_id, 
                    sum(transactions.amount_purchased) as Num_Items
                    from sales left join transactions on 
                    sales.sale_id=transactions.sale_id
                    where sales.store_id='1' 
                    group by sales.sale_id order by Num_items desc;")
Chris<-fetch(result,n=-1)
dbClearResult(result)


head(Chris,5)
nrow(Chris)

library(ggplot2)




ggplot(Chris, aes(x=Num_Items)) + scale_x_continuous(breaks=seq(0,120,10))+
    geom_histogram(binwidth=0.1, colour="black", fill="white")


ggplot(Chris, aes(x=Num_Items)) +
  geom_density() + scale_x_continuous(breaks=seq(0,120,10))+
  geom_vline(aes(xintercept=mean(Num_Items, na.rm=T)), 
            color="red", linetype="dashed", size=1)

mean(Chris$Num_Items,na.rm=T)

con<-('SELECT I.Item_Name, SUM(T.Amount_Purchased) TotalPurchased
FROM Transactions T LEFT JOIN Items I
ON T.Item_ID=I.Item_ID LEFT JOIN Sales S
ON S.Sale_ID=T.Sale_ID
WHERE S.Store_ID=1
GROUP BY I.Item_ID
ORDER BY TotalPurchased DESC;')


rm(qrry,qry,result)

result<-dbSendQuery(mydb,con)
Chris_items<-fetch(result,n=-1)
dbClearResult(result)

head(Chris_items,5)
nrow(Chris_items)




con<-"select s.sale_week,  SUM(T.Amount_Purchased) TotalPurchased
FROM sales s left join Transactions T 
ON T.Sale_ID=S.Sale_ID left join Items I 
ON T.Item_ID=I.Item_ID
WHERE S.Store_ID=1 and I.Item_name='Meatloaf Mix'
group by s.sale_week
order by s.sale_week asc;"

result<-dbSendQuery(mydb,con)
Chris_Meatloaf<-fetch(result,n=-1)
dbClearResult(result)

head(Chris_Meatloaf,5)

ggplot(Chris_Meatloaf, aes(x=sale_week,y=TotalPurchased ))+ 
  scale_x_continuous(breaks=seq(0,55,2))+
  scale_y_continuous(breaks=seq(0,80,5))+
  geom_point()+geom_smooth()

ggplot(Chris_Meatloaf, aes(x=TotalPurchased)) +
  geom_density() + scale_x_continuous(breaks=seq(0,80,10))+
  geom_vline(aes(xintercept=mean(TotalPurchased, na.rm=T)), 
             color="red", linetype="dashed", size=1)

mean(Chris_Meatloaf$TotalPurchased)
sd(Chris_Meatloaf$TotalPurchased)

pnorm(40,28.86538,12.2523)


head(fetch(dbSendQuery(mydb, "select * from salesdata"),n=10),5)

con<-"CREATE TABLE CustomerData AS(
  SELECT Customer_ID, AVG(CountItems) AvgCountItems,
  SUM(SalePrice)/SUM(CountItems) AvgItemPrice,
  AVG(SalePrice) AvgSalePrice,
  COUNT(*) Trips,
  SUM(SalePrice) TotalRevenue
  FROM SalesData
  GROUP BY Customer_ID);"

result<-dbSendQuery(mydb,con)
Chris_Meatloaf<-fetch(result,n=-1)
dbClearResult(result)


result<-dbSendQuery(mydb, "select * from CustomerData")
head(fetch(result,n=10),5)
dbClearResult(result)


result<-dbSendQuery(mydb, "select * from CustDataSurvey")
head(fetch(result,n=10),5)
dbClearResult(result)


con<-"CREATE TABLE CustDataSurvey AS(SELECT cd.TotalRevenue, cd.Customer_ID,
cs.Cust_Sex, cs.Cust_Income, cs.Cust_Race, cs.Cust_Age,cs.Cust_Children,cs.Cust_Rel_Status
FROM CustomerData cd
LEFT JOIN Customer_Survey cs
ON cd.Customer_ID = cs.Customer_ID);"

result<-dbSendQuery(mydb,con)
Chris_Meatloaf<-fetch(result,n=-1)
dbClearResult(result)

result<-dbSendQuery(mydb,"select * from customerdata order by Customer_ID")
customerdata<-fetch(result,n=-1)
dbClearResult(result)

result<-dbSendQuery(mydb,"select * from CustDataSurvey order by Customer_ID")
CustDataSurvey<-fetch(result,n=-1)
dbClearResult(result)


head(CustDataSurvey,5)
head(customerdata,5)

a<-c(CustDataSurvey[CustDataSurvey$Cust_Sex=='Male',]$Cust_Income)
ab<-as.data.frame(a)

Male_Customer_ID<-CustDataSurvey[CustDataSurvey$Cust_Sex=='Male',]$Customer_ID
Male_Customer_ID<-as.data.frame(Male_Customer_ID)
Avg_Count_Items_Male<-customerdata[customerdata$Customer_ID==Male_Customer_ID,]$AvgCountItems

Customer<-merge(customerdata,CustDataSurvey,by='Customer_ID')
head(Customer,5)



a<-c(Customer[Customer$Cust_Sex=='Male',]$AvgCountItems)
aa<-as.data.frame(a)
b<-c(Customer[Customer$Cust_Sex=='Female',]$AvgCountItems)
bb<-as.data.frame(b)

#######################################################################
a<-c(Customer[Customer$Cust_Sex=='Male',]$AvgCountItems)
b<-c(Customer[Customer$Cust_Sex=='Female',]$AvgCountItems)


dat_male <- data.frame(Gender = factor(rep(c("Male"))), 
                       AvgCountItems = c(a))
dat_female<-data.frame(Gender = factor(rep(c("Female"))), 
                       AvgCountItems = c(b))

dat<-rbind(dat_female,dat_male)

ggplot(dat, aes(x=AvgCountItems, fill=cond)) + geom_density(alpha=.3)

ggplot(dat, aes(x=AvgCountItems, fill=Gender)) +
  geom_density(aes(y = ..count..), stat="density", alpha=0.3)
#################################################################3


ggplot(a aes(x=a))  + geom_density()+scale_x_continuous(breaks=seq(0,80,10))
  

ggplot(Customer, aes(x=AvgCountItems)) +
  geom_density() #+ scale_x_continuous(breaks=seq(0,120,10))

list_data <- list("Red", "Green", c(21,32,11), TRUE, 51.23, 119.1)
class(list_data)

dat2 <- data.frame(cond = factor(rep(c("A","B"), each=200)), 
                  rating = c(rnorm(200),rnorm(200, mean=.8)))

head(dat2,10)
ggplot(dat, aes(x=rating, fill=cond)) + geom_density(alpha=.3)

head(Customer,10)

con<-"SELECT s.Store_ID,s.Customer_ID, s.Sale_ID, SUM(t.Amount_Purchased)
CountItems,
SUM(t.Amount_Purchased*i.Price_Per_Item*(1 -d.Item_Discount)) Revenue
FROM Sales s
RIGHT JOIN Transactions t
ON t.Sale_ID= s.Sale_ID
LEFT JOIN Discounts d
ON d.Sale_Week= s.Sale_Week AND d.Item_ID=t.Item_ID
LEFT JOIN Items i
ON i.Item_ID= t.Item_ID
GROUP BY s.Store_ID;"

result<-dbSendQuery(mydb,con)
Store_Revenue<-fetch(result,n=-1)
dbClearResult(result)


head(Store_Revenue,5)
ggplot(Store_Revenue, aes(x=Store_ID, y=Revenue)) + 
  geom_bar(stat = "identity", width=0.5)+
  scale_x_continuous(labels = as.character(Store_Revenue$Store_ID),breaks =Store_Revenue$Store_ID)

con<-"SELECT i.Item_ID, i.item_name, SUM(t.Amount_Purchased) TotalItems,
SUM(t.Amount_Purchased*i.Price_Per_Item*(1 -d.Item_Discount)) TotalRevitems,
ROUND((SUM(t.Amount_Purchased*i.Price_Per_Item*
(1-d.Item_Discount))/SUM(t.Amount_Purchased)),2) AvgPrice
FROM Sales s
RIGHT JOIN Transactions t
ON t.Sale_ID= s.Sale_ID
LEFT JOIN Discounts d
ON d.Sale_Week= s.Sale_Week AND d.Item_ID= t.Item_ID
LEFT JOIN Items i
ON i.Item_ID= t.Item_ID
where s.store_id=9 or s.store_id=10 or s.store_id=11 or s.store_id=12
GROUP BY i.item_id
order by TotalRevitems desc;"

result<-dbSendQuery(mydb,con)
Items<-fetch(result,n=-1)
dbClearResult(result)

head(Items,10)



con<-"SELECT Customer_ID, any_value(Store_ID), max(StoreCount) FROM (
  SELECT Customer_ID, Store_ID,
  COUNT(*) AS StoreCount
  FROM SalesData
  GROUP BY Customer_ID, Store_ID
  ORDER BY StoreCount DESC) StoreCounts
  GROUP BY Customer_ID;"

  result<-dbSendQuery(mydb,con)
  visits<-fetch(result,n=-1)
  dbClearResult(result)
   head(visits,5)

# Disconnect from MySql
dbDisconnect(mydb)
