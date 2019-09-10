DROP TABLE IF EXISTS temp1;

CREATE table IF NOT EXISTS temp1 as select a.Account, a.RegionId, a.InstanceId, a.TagKey, a.TagValue, a.InstanceName, a.PublicIpAddress, a.InstanceType, sum(d.Size) AS Size, sum(d.Size) / 100 * 5.10 as DiskPrice
	from assets as a, assets_disk as d
where a.InstanceId = d.InstanceId group by a.InstanceId;

SELECT a.TagKey AS Tags, 
	SUM(ROUND(b.monthlyPrice,2)) AS InstancePrice, 
	SUM(ROUND(a.DiskPrice,2)) AS DiskPrice, 
	SUM(ROUND((a.DiskPrice + b.monthlyprice),2)) AS TotalPrice 
FROM 
	temp1 as a , instancePrice as b 
WHERE 
	a.InstanceType = b.InstanceId AND b.system="linux" AND a.RegionId = b.region
GROUP BY 
	TagKey
ORDER BY TotalPrice DESC;
