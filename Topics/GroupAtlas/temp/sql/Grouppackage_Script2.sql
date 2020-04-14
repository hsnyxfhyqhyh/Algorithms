USE [TravelServices]
GO

/****** Object:  View [dbo].[vw_grp_Package]    Script Date: 4/14/2020 3:56:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [dbo].[vw_grp_Package]
AS
SELECT  p.PackageID, 
		p.GroupID, 
		p.PackageCd, 
		p.PackageName, 
		p.SingleRate, 
		p.DoubleRate, 
		p.TripleRate, 
		p.QuadRate, 
		p.SingleComm, 
		p.DoubleComm, 
		IsNull(p.TripleComm, 0) AS TripleComm, 
		IsNull(p.QuadComm, 0) AS QuadComm,
		p.Quantity, 
		p.Allocated, 
		p.PortCharges,
		p.PackageType,
		t.PackageTypeName,
		isnull(b.Sold,0) as Sold,
		isnull(b.SoldPax,0) as SoldPax
FROM    dbo.grp_Package p 
INNER JOIN dbo.grp_PackageType t on t.PackageType = p.PackageType
LEFT JOIN (SELECT l.PackageID, sum(b.PaxCnt) as SoldPax, count(*) as Sold
	FROM (SELECT DISTINCT BookingID, PackageID FROM dbo.grp_Bill) l
	INNER JOIN dbo.grp_Booking b on b.BookingID = l.BookingID
	WHERE b.Status = 'A'
	GROUP BY l.PackageID
)  b on b.PackageID = p.PackageID



GO


