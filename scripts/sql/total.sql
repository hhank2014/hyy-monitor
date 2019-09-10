SELECT
    a.RegionId,
    a.InstanceId,
    a.TagKey,
    a.TagValue,
    a.InstanceName,
    a.PublicIpAddress,
    a.InstanceType,
    p.monthlyPrice,
    d.Size,
    ROUND(d.Size / 100 * 5.10, 2) AS DiskPrice,
    ROUND(p.monthlyPrice + ROUND(d.Size / 100 * 5.10, 2)) AS TotalPrice
FROM
    assets AS a
        LEFT JOIN
    (SELECT
        monthlyPrice, InstanceId
    FROM
        instancePrice) AS p ON a.InstanceType = p.InstanceId
        LEFT JOIN
    (SELECT
        Size, InstanceId
    FROM
        assets_disk) AS d ON a.InstanceId = d.InstanceId
GROUP BY a.InstanceId
	;
