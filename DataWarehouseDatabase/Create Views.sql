
CREATE VIEW vChannel_TargetSalesAmount AS
SELECT DimChannelID, DimDateID, SUM(TargetSalesAmount) AS TargetSalesByChannelByDate
	FROM [jack1206DW].[dbo].[FactTargetSalesAmount]
    GROUP BY DimChannelID, DimDateID;
GO

CREATE VIEW vChannel_SalesAmount AS
SELECT DimChannelID, DimDateID, SUM(SalesAmount) AS SalesAmountByChannelByDate
	FROM dbo.FactSales
	GROUP BY DimChannelID, DimDateID;
GO

CREATE VIEW vChannelSalesSummary AS
SELECT vcs.DimChannelID, vcs.DimDateID, vcs.SalesAmountByChannelByDate,vcts.TargetSalesByChannelByDate,
		dc.ChannelCategory, dc.Channel, dd.FullDate
	FROM dbo.vChannel_SalesAmount AS vcs
	INNER JOIN dbo.vChannel_TargetSalesAmount AS vcts
	ON vcs.DimChannelID = vcts.DimChannelID AND vcs.DimDateID = vcts.DimDateID
	INNER JOIN dbo.DimChannel AS dc
	ON vcs.DimChannelID = dc.DimChannelID
	INNER JOIN dbo.DimDate AS dd
	ON vcs.DimDateID = dd.DimDateID;
GO

CREATE VIEW vChannel_SalesProfit AS
SELECT fs.DimChannelID, fs.DimDateID, fs.DimProductID, SUM(fs.SalesAmount - fs.SalesQuantity * dp.Cost) AS SalesProfitByChannelByProductByDate
	FROM dbo.FactSales AS fs
	INNER JOIN dbo.DimProduct AS dp
	ON fs.DimProductID = dp.DimProductID
	GROUP BY fs.DimChannelID, fs.DimDateID, fs.DimProductID;
GO

CREATE VIEW vChannel_Geography_Sales AS
SELECT fs.DimChannelID, fs.DimCustomerID, fs.DimStoreID, fs.DimResellerID, dg.DimGeographyID, 
	fs.DimDateID, fs.SalesAmount, fs.SalesQuantity
	FROM dbo.FactSales AS fs
	INNER JOIN dbo.DimCustomer AS dc
	ON fs.DimCustomerID = dc.DimCustomerID
	INNER JOIN dbo.DimGeography AS dg
	ON dc.DimGeographyID = dg.DimGeographyID
	WHERE fs.DimCustomerID != -1
UNION ALL
SELECT fs.DimChannelID, fs.DimCustomerID, fs.DimStoreID, fs.DimResellerID, dg.DimGeographyID, 
	fs.DimDateID, fs.SalesAmount, fs.SalesQuantity
	FROM dbo.FactSales AS fs
	INNER JOIN dbo.DimStore AS ds
	ON fs.DimStoreID = ds.DimStoreID
	INNER JOIN dbo.DimGeography AS dg
	ON ds.DimGeographyID = dg.DimGeographyID
	WHERE fs.DimStoreID != -1
UNION ALL
SELECT fs.DimChannelID, fs.DimCustomerID, fs.DimStoreID, fs.DimResellerID, dg.DimGeographyID, 
	fs.DimDateID, fs.SalesAmount, fs.SalesQuantity
	FROM dbo.FactSales AS fs
	INNER JOIN dbo.DimReseller AS dr
	ON fs.DimResellerID = dr.DimResellerID
	INNER JOIN dbo.DimGeography AS dg
	ON dr.DimGeographyID = dg.DimGeographyID
	WHERE fs.DimResellerID != -1;
GO