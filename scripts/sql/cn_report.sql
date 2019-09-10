DROP TABLE IF EXISTS cn_temp1;

CREATE table IF NOT EXISTS cn_temp1 as select a.Account, a.RegionId, a.InstanceId, a.TagKey, a.TagValue, a.InstanceName, a.PublicIpAddress, a.InstanceType, sum(d.Size) AS Size, sum(d.Size) / 100 * 5.10 as DiskPrice
	from cn_assets as a, cn_assets_disk as d
where a.InstanceId = d.InstanceId group by a.InstanceId;

SELECT a.TagKey, 
	SUM(ROUND(b.monthlyPrice,2)) AS InstancePrice, 
	SUM(ROUND(a.DiskPrice,2)) AS DiskPrice, 
	SUM(ROUND((a.DiskPrice + b.monthlyprice),2)) AS TotalPrice 
FROM 
	cn_temp1 as a , cn_instancePrice as b 
WHERE 
	a.InstanceType = b.InstanceId AND b.system="linux" AND a.RegionId = b.region AND network = "vpc"
GROUP BY 
	TagKey;
