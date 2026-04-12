CREATE DATABASE  IF NOT EXISTS `student-z126_Trade` /*!40100 DEFAULT CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `student-z126_Trade`;
-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: 128.175.241.51    Database: student-z119_Trade
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Company`
--

DROP TABLE IF EXISTS `Company`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Company` (
  `Name` varchar(45) COLLATE utf8mb3_unicode_ci NOT NULL,
  `Industry` varchar(45) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `Country` varchar(45) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `NetProfitGrowth` decimal(8,4) DEFAULT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Company`
--

LOCK TABLES `Company` WRITE;
/*!40000 ALTER TABLE `Company` DISABLE KEYS */;
INSERT INTO `Company` VALUES ('Apple Inc.','Technology','USA',0.2100),('Bank of China','Banking','China',0.0400),('BYD Company','Automotive','China',-0.1900),('Chagee Holdings','Consumer Discretionary','China',-0.5000),('China Mobile','Telecom','China',-0.0100),('Costco Wholesale','Retail','USA',0.1200),('JPMorgan Chase','Banking','USA',-0.0200),('NVIDIA Corp','Technology','USA',0.6500),('S.F. Holding','Logistics','China',0.0900),('Tencent Holdings','Internet','China',0.1500);
/*!40000 ALTER TABLE `Company` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Exchange`
--

DROP TABLE IF EXISTS `Exchange`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Exchange` (
  `Code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `Name` varchar(45) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `Country` varchar(45) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `OpenTime` time DEFAULT NULL,
  `CloseTime` time DEFAULT NULL,
  `StampDutyRate` decimal(5,4) DEFAULT NULL,
  `CapitalGainTaxRate` decimal(5,4) DEFAULT NULL,
  PRIMARY KEY (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Exchange`
--

LOCK TABLES `Exchange` WRITE;
/*!40000 ALTER TABLE `Exchange` DISABLE KEYS */;
INSERT INTO `Exchange` VALUES ('HKEX','HK Exchanges and Clearing','China HK','09:30:00','16:00:00',0.0010,0.0000),('NASDAQ','NASDAQ Market','USA','09:30:00','16:00:00',0.0000,0.1500),('NYSE','New York Stock Exchange','USA','09:30:00','16:00:00',0.0000,0.1500),('SSE','Shanghai Stock Exchange','China','09:30:00','15:00:00',0.0005,0.0000),('SZSE','Shenzhen Stock Exchange','China','09:30:00','15:00:00',0.0005,0.0000);
/*!40000 ALTER TABLE `Exchange` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Factor`
--

DROP TABLE IF EXISTS `Factor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Factor` (
  `FactorID` int NOT NULL,
  `Name` varchar(45) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `Type` varchar(45) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `Formula` varchar(45) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`FactorID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Factor`
--

LOCK TABLES `Factor` WRITE;
/*!40000 ALTER TABLE `Factor` DISABLE KEYS */;
INSERT INTO `Factor` VALUES (1,'PE_Ratio','Value','MarketData.Close / MarketData.EPS'),(2,'Div_Yield','Value','MarketData.Dividend / MarketData.Close'),(3,'NetProfit_G','Growth','Company.NetProfitGrowth'),(4,'RSI_Status','Momentum','MarketData.RSI'),(5,'MACD_Signal','Momentum','MarketData.MACD'),(6,'Size_Factor','Size','MarketData.MarketCap'),(7,'Liq_Ratio','Liquidity','MarketData.Volume / MarketData.SharesOut'),(8,'Stock_Style','Style','Stock.Type'),(9,'Industry_Type','Industry','Company.Industry');
/*!40000 ALTER TABLE `Factor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `FactorUsageRule`
--

DROP TABLE IF EXISTS `FactorUsageRule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `FactorUsageRule` (
  `RuleID` int NOT NULL,
  `Signal` varchar(45) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `Operator` varchar(5) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `Value` varchar(25) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `Factor_FactorID` int NOT NULL,
  `Strategy_StrategyID` int NOT NULL,
  PRIMARY KEY (`RuleID`),
  KEY `fk_FactorUsageRule_Factor1_idx` (`Factor_FactorID`),
  KEY `fk_FactorUsageRule_Strategy1_idx` (`Strategy_StrategyID`),
  CONSTRAINT `fk_FactorUsageRule_Factor1` FOREIGN KEY (`Factor_FactorID`) REFERENCES `Factor` (`FactorID`),
  CONSTRAINT `fk_FactorUsageRule_Strategy1` FOREIGN KEY (`Strategy_StrategyID`) REFERENCES `Strategy` (`StrategyID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `FactorUsageRule`
--

LOCK TABLES `FactorUsageRule` WRITE;
/*!40000 ALTER TABLE `FactorUsageRule` DISABLE KEYS */;
INSERT INTO `FactorUsageRule` VALUES (601,'Buy','<','12',1,101),(602,'Buy','>','0.04',2,101),(603,'Buy','>','0.2',3,102),(604,'Buy','>','0',5,102),(605,'Buy','=','Technology',9,102),(606,'Buy','<','30',4,103),(607,'Buy','<','10000000000',6,104),(608,'Buy','=','Value',8,105),(609,'Sell','>','20',1,101),(610,'Sell','<','0',5,102),(611,'Sell','>','70',4,103),(612,'Sell','>','85',4,104),(613,'Sell','<','0.01',2,105);
/*!40000 ALTER TABLE `FactorUsageRule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MarketData`
--

DROP TABLE IF EXISTS `MarketData`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `MarketData` (
  `Date` datetime NOT NULL,
  `Open` decimal(18,4) DEFAULT NULL,
  `High` decimal(18,4) DEFAULT NULL,
  `Low` decimal(18,4) DEFAULT NULL,
  `Close` decimal(18,4) DEFAULT NULL,
  `Volume` bigint DEFAULT NULL,
  `Turnover` decimal(20,2) DEFAULT NULL,
  `SharesOutstanding` bigint DEFAULT NULL,
  `MarketCap` decimal(20,2) DEFAULT NULL,
  `Stock_Code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `EPS` decimal(18,4) DEFAULT NULL,
  `Dividend` decimal(18,4) DEFAULT NULL,
  `RSI` decimal(18,4) DEFAULT NULL,
  `MACD` decimal(18,4) DEFAULT NULL,
  PRIMARY KEY (`Date`,`Stock_Code`),
  KEY `fk_MarketData_Stock1_idx` (`Stock_Code`),
  CONSTRAINT `fk_MarketData_Stock1` FOREIGN KEY (`Stock_Code`) REFERENCES `Stock` (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MarketData`
--

LOCK TABLES `MarketData` WRITE;
/*!40000 ALTER TABLE `MarketData` DISABLE KEYS */;
INSERT INTO `MarketData` VALUES ('2026-04-01 00:00:00',38.4200,38.6600,37.9200,38.0900,25910000,987000000.00,5039000000,191935510000.00,'002352',2.2300,0.8900,69.2100,0.0600),('2026-04-01 00:00:00',105.9000,106.5000,102.3700,102.6500,71520000,7383000000.00,9117000000,935860050000.00,'002594',3.5800,0.3580,38.0900,0.4100),('2026-04-01 00:00:00',503.9300,504.5000,493.0000,496.6000,21280000,10600000000.00,9126000000,4531971600000.00,'00700',27.2788,4.5000,42.1200,-3.0900),('2026-04-01 00:00:00',79.6000,80.5000,79.5500,79.8000,21940000,1758000000.00,21650000000,1727670000000.00,'00941',7.0090,5.2400,62.3900,0.0200),('2026-04-01 00:00:00',106.8800,107.6000,101.6000,104.7000,41880000,4345000000.00,9117000000,954549900000.00,'01211',3.9611,0.4050,52.5600,0.3900),('2026-04-01 00:00:00',5.0000,5.0200,4.9600,5.0100,344000000,1718000000.00,322200000000,1614222000000.00,'03988',0.8350,0.2500,73.6600,0.0200),('2026-04-01 00:00:00',94.1600,94.3200,93.6100,93.8500,7484300,703000000.00,21650000000,2031852500000.00,'600941',6.3312,4.7790,37.8700,-0.1700),('2026-04-01 00:00:00',5.8900,5.9500,5.8500,5.8700,343200000,2022000000.00,322200000000,1891314000000.00,'601988',0.7400,0.2263,74.2100,0.0300),('2026-04-01 00:00:00',254.8100,255.9800,253.3200,256.4300,40060000,10220000000.00,14680000000,3764392400000.00,'AAPL',8.0223,1.0400,45.9800,-0.1400),('2026-04-01 00:00:00',9.3000,9.4900,9.0100,9.1600,738800,6817000.00,1910000000,17495600000.00,'CHA',0.8734,0.8700,23.4500,-0.0900),('2026-04-01 00:00:00',996.6500,1001.0200,991.9800,996.2100,1770000,1763000000.00,444000000,442317000000.00,'COST',19.2696,5.2000,61.2300,0.6200),('2026-04-01 00:00:00',295.4100,298.7200,292.9600,295.3800,11270000,3333000000.00,2697000000,796639860000.00,'JPM',21.1521,4.4000,59.4300,0.1600),('2026-04-01 00:00:00',174.4300,177.0900,174.1200,175.8600,168000000,29610000000.00,24300000000,4273398000000.00,'NVDA',4.9410,0.0400,34.6700,0.0500),('2026-04-02 00:00:00',38.1100,38.3500,37.7500,38.1400,25930000,988000000.00,5039000000,192187460000.00,'002352',2.2300,0.8900,69.4300,0.0800),('2026-04-02 00:00:00',102.4900,103.4800,100.5000,101.6500,60430000,6154000000.00,9117000000,926743050000.00,'002594',3.5800,0.3580,43.2200,0.5000),('2026-04-02 00:00:00',496.4000,496.4000,485.0000,489.2000,17030000,8324000000.00,9126000000,4464439200000.00,'00700',27.2788,4.5000,37.2200,-2.8700),('2026-04-02 00:00:00',79.4500,80.1500,79.3000,80.0500,11570000,923000000.00,21650000000,1733082500000.00,'00941',7.0090,5.2400,69.5400,0.0700),('2026-04-02 00:00:00',104.7000,106.5000,101.7000,103.9000,25830000,2683000000.00,9117000000,947256300000.00,'01211',3.9611,0.4050,47.9800,0.3700),('2026-04-02 00:00:00',5.0000,5.0600,4.9800,5.0600,345000000,1737000000.00,322200000000,1630332000000.00,'03988',0.8350,0.2500,78.8800,0.0300),('2026-04-02 00:00:00',93.8300,93.8300,93.0000,93.2800,6099800,570000000.00,21650000000,2019512000000.00,'600941',6.3312,4.7790,30.5500,-0.1600),('2026-04-02 00:00:00',5.8700,5.9700,5.8400,5.9400,292900000,1738000000.00,322200000000,1913868000000.00,'601988',0.7400,0.2263,80.4300,0.0400),('2026-04-02 00:00:00',254.1400,256.1300,250.7600,255.9200,31290000,7969000000.00,14680000000,3756905600000.00,'AAPL',8.0223,1.0400,55.5600,0.0400),('2026-04-02 00:00:00',9.5900,10.1600,9.2900,10.0900,1420000,13960000.00,1910000000,19271900000.00,'CHA',0.8734,0.8700,46.1200,-0.0800),('2026-04-02 00:00:00',1005.3700,1015.9900,1001.4300,1014.9600,1829000,1847000000.00,444000000,450642000000.00,'COST',19.2696,5.2000,72.4500,1.5600),('2026-04-02 00:00:00',292.2200,295.5900,288.7200,294.6000,6669000,1959000000.00,2697000000,794536200000.00,'JPM',21.1521,4.4000,63.9800,0.3200),('2026-04-02 00:00:00',172.0700,177.5500,171.1100,177.3900,143000000,25130000000.00,24300000000,4310577000000.00,'NVDA',4.9410,0.0400,56.4300,0.1200);
/*!40000 ALTER TABLE `MarketData` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Portfolio`
--

DROP TABLE IF EXISTS `Portfolio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Portfolio` (
  `PortfolioID` int NOT NULL,
  `Name` varchar(45) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`PortfolioID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Portfolio`
--

LOCK TABLES `Portfolio` WRITE;
/*!40000 ALTER TABLE `Portfolio` DISABLE KEYS */;
INSERT INTO `Portfolio` VALUES (1,'Main_Aggressive'),(2,'Retirement_Fund'),(3,'Tech_Spec_2026'),(4,'Dividend_Growth'),(5,'Small_Momentum');
/*!40000 ALTER TABLE `Portfolio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Stock`
--

DROP TABLE IF EXISTS `Stock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Stock` (
  `Code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `TradeCurrency` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `Type(Growth/Value)` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `Industry` varchar(20) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `StockIndex` varchar(20) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `Company_Name` varchar(45) COLLATE utf8mb3_unicode_ci NOT NULL,
  `Exchange_Code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`Code`),
  KEY `fk_Stock_Company1_idx` (`Company_Name`),
  KEY `fk_Stock_Exchange1_idx` (`Exchange_Code`),
  CONSTRAINT `fk_Stock_Exchange1` FOREIGN KEY (`Exchange_Code`) REFERENCES `Exchange` (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Stock`
--

LOCK TABLES `Stock` WRITE;
/*!40000 ALTER TABLE `Stock` DISABLE KEYS */;
INSERT INTO `Stock` VALUES ('002352','CNY','Growth','Logistics','CSI 300','S.F. Holding','SSE'),('002594','CNY','Growth','Automotive','CSI 300','BYD Company','SZSE'),('00700','HKD','Growth','Internet','Hang Seng Index','Tencent Holdings','HKEX'),('00941','HKD','Value','Telecom','Hang Seng Index','China Mobile','HKEX'),('01211','HKD','Growth','Automotive','Hang Seng Index','BYD Company','HKEX'),('03988','HKD','Value','Banking','Hang Seng Index','Bank of China','HKEX'),('600941','CNY','Value','Telecom','SSE 50','China Mobile','SSE'),('601988','CNY','Value','Banking','CSI 300','Bank of China','SSE'),('AAPL','USD','Growth','Technology','S&P 500','Apple Inc.','NASDAQ'),('CHA','USD','Growth','Consumer Disc','NASDAQ Composite','Chagee Holdings','NASDAQ'),('COST','USD','Value','Retail','S&P 500','Costco Wholesale','NASDAQ'),('JPM','USD','Value','Banking','DJIA','JPMorgan Chase','NYSE'),('NVDA','USD','Growth','Technology','NASDAQ 100','NVIDIA Corp','NASDAQ');
/*!40000 ALTER TABLE `Stock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Strategy`
--

DROP TABLE IF EXISTS `Strategy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Strategy` (
  `StrategyID` int NOT NULL,
  `Name` varchar(45) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`StrategyID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Strategy`
--

LOCK TABLES `Strategy` WRITE;
/*!40000 ALTER TABLE `Strategy` DISABLE KEYS */;
INSERT INTO `Strategy` VALUES (101,'Defensive_Value'),(102,'Tech_Growth_Alpha'),(103,'Mean_Reversion'),(104,'Small_Cap_Momentum'),(105,'Institutional_Core');
/*!40000 ALTER TABLE `Strategy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `TradeRecord`
--

DROP TABLE IF EXISTS `TradeRecord`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `TradeRecord` (
  `TradeID` int NOT NULL,
  `Time` datetime DEFAULT NULL,
  `Direction` varchar(45) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `ExecutionPrice` decimal(18,4) DEFAULT NULL,
  `Volume` int DEFAULT NULL,
  `StampDuty` decimal(18,4) DEFAULT NULL,
  `CapitalGainTax` decimal(18,4) DEFAULT NULL,
  `Portfolio_PortfolioID` int NOT NULL,
  `Strategy_StrategyID` int NOT NULL,
  `Stock_Code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`TradeID`),
  KEY `fk_TradeRecord_Portfolio1_idx` (`Portfolio_PortfolioID`),
  KEY `fk_TradeRecord_Strategy1_idx` (`Strategy_StrategyID`),
  KEY `fk_TradeRecord_Stock1_idx` (`Stock_Code`),
  CONSTRAINT `fk_TradeRecord_Portfolio1` FOREIGN KEY (`Portfolio_PortfolioID`) REFERENCES `Portfolio` (`PortfolioID`),
  CONSTRAINT `fk_TradeRecord_Stock1` FOREIGN KEY (`Stock_Code`) REFERENCES `Stock` (`Code`),
  CONSTRAINT `fk_TradeRecord_Strategy1` FOREIGN KEY (`Strategy_StrategyID`) REFERENCES `Strategy` (`StrategyID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `TradeRecord`
--

LOCK TABLES `TradeRecord` WRITE;
/*!40000 ALTER TABLE `TradeRecord` DISABLE KEYS */;
INSERT INTO `TradeRecord` VALUES (1,'2026-04-01 09:35:00','Buy',256.4300,1000,0.0000,0.0000,1,102,'AAPL'),(2,'2026-04-01 10:15:00','Buy',175.8600,500,0.0000,0.0000,1,102,'NVDA'),(3,'2026-04-01 11:00:00','Buy',996.2100,50,0.0000,0.0000,2,101,'COST'),(4,'2026-04-01 14:30:00','Buy',102.6500,5000,0.0000,0.0000,3,101,'002594'),(5,'2026-04-01 15:00:00','Buy',496.6000,400,198.6400,0.0000,4,104,'00700'),(6,'2026-04-02 09:31:00','Buy',5.9400,10000,0.0000,0.0000,5,105,'601988'),(7,'2026-04-02 10:10:00','Buy',102.4900,3000,0.0000,0.0000,3,101,'002594'),(8,'2026-04-02 10:45:00','Buy',177.3900,400,0.0000,0.0000,1,103,'NVDA'),(9,'2026-04-02 11:20:00','Buy',79.4500,2000,158.9000,0.0000,4,104,'00941'),(10,'2026-04-02 11:50:00','Buy',292.2200,200,0.0000,0.0000,2,101,'JPM'),(11,'2026-04-02 13:30:00','Sell',177.3900,500,0.0000,114.7500,1,102,'NVDA'),(12,'2026-04-02 14:05:00','Sell',1014.9600,30,0.0000,84.3800,2,101,'COST'),(13,'2026-04-02 14:15:00','Sell',251.9000,600,0.0000,0.0000,1,102,'AAPL'),(14,'2026-04-02 14:30:00','Sell',101.6500,4000,203.3000,0.0000,3,101,'002594'),(15,'2026-04-02 14:45:00','Sell',489.2000,200,97.8400,0.0000,4,104,'00700'),(16,'2026-04-02 15:00:00','Sell',80.0500,1000,80.0500,0.0000,4,104,'00941'),(17,'2026-04-02 15:15:00','Sell',5.9400,5000,14.8500,0.0000,5,105,'601988'),(18,'2026-04-02 15:30:00','Sell',177.3900,200,0.0000,0.0000,1,103,'NVDA'),(19,'2026-04-02 15:45:00','Sell',294.6000,100,0.0000,35.7000,2,101,'JPM'),(20,'2026-04-02 15:55:00','Sell',103.9000,1000,103.9000,0.0000,3,101,'01211');
/*!40000 ALTER TABLE `TradeRecord` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'student-z119_Trade'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-06 17:44:23
