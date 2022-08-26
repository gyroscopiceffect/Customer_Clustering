a<-c(Customer[Customer$Cust_Age=='15-24',]$TotalRevenue.x)

b<-c(Customer[Customer$Cust_Age=='25-44',]$TotalRevenue.x)

c<-c(Customer[Customer$Cust_Age=='45-64',]$TotalRevenue.x)

d<-c(Customer[Customer$Cust_Age=='64+',]$TotalRevenue.x)

dat_1524 <- data.frame(Customer_Age = factor(rep(c('15-24'))), 
                       TotalRevenue.x = c(a))

dat_2544 <- data.frame(Customer_Age = factor(rep(c('25-44'))), 
                       TotalRevenue.x = c(b))

dat_4564 <- data.frame(Customer_Age = factor(rep(c('45-64'))), 
                       TotalRevenue.x = c(c))

dat_64plus <- data.frame(Customer_Age = factor(rep(c('64+'))), 
                       TotalRevenue.x = c(d))

dat<-rbind(dat_1524,dat_2544,dat_4564,dat_64plus)

ggplot(dat, aes(x=TotalRevenue.x, fill=Customer_Age)) +
  geom_density(aes(y = ..count..), stat="density", alpha=0.5)


g1<-ggplot(dat_1524, aes(x=TotalRevenue.x, fill=Customer_Age)) +
  scale_x_continuous(breaks=seq(0,5500,2000))+
  scale_y_continuous(breaks=seq(0,0.06,0.02))+
  geom_density(aes(y = ..count..), stat="density", alpha=0.5)
g2<-ggplot(dat_2544, aes(x=TotalRevenue.x, fill=Customer_Age)) +
  scale_x_continuous(breaks=seq(0,5500,2000))+
  scale_y_continuous(breaks=seq(0,0.6,0.2))+
  geom_density(aes(y = ..count..), stat="density", alpha=0.5)
g3<-ggplot(dat_4564, aes(x=TotalRevenue.x, fill=Customer_Age)) +
  scale_x_continuous(breaks=seq(0,5500,2000))+
  scale_y_continuous(breaks=seq(0,0.6,0.2))+
  geom_density(aes(y = ..count..), stat="density", alpha=0.5)
g4<-ggplot(dat_64plus, aes(x=TotalRevenue.x, fill=Customer_Age)) +
  scale_x_continuous(breaks=seq(0,5500,2000))+
  scale_y_continuous(breaks=seq(0,0.6,0.2))+
  geom_density(aes(y = ..count..), stat="density", alpha=0.5)

library(patchwork)
g1+g2+g3+g4


a<-c(Customer[Customer$Cust_Children=='Has_Child(ren)',]$TotalRevenue.x)
b<-c(Customer[Customer$Cust_Children=='Has_no_Child(ren)',]$TotalRevenue.x)
dat_chldr <- data.frame(Cust_Children = factor(rep(c('Has_Child(ren)'))), 
                       TotalRevenue.x = c(a))
dat_nochldr <- data.frame(Cust_Children = factor(rep(c('Has_no_Child(ren)'))), 
                        TotalRevenue.x = c(b))
dat<-rbind(dat_chldr,dat_nochldr)
ggplot(dat, aes(x=TotalRevenue.x, fill=Cust_Children)) +
  geom_density(aes(y = ..count..), stat="density", alpha=0.3)
