TRUNCATE cn_temp1;
TRUNCATE cn_assets;
TRUNCATE cn_assets_disk;

DROP TABLE IF EXISTS cn_assets;
DROP TABLE IF EXISTS cn_assets_disk;

CREATE TABLE `cn_assets` (
  `RegionId` varchar(30) DEFAULT NULL,
  `ZoneId` varchar(30) DEFAULT NULL,
  `InstanceId` varchar(40) DEFAULT NULL,
  `InstanceName` varchar(40) DEFAULT NULL,
  `TagValue` varchar(40) DEFAULT NULL,
  `TagKey` varchar(40) DEFAULT NULL,
  `PrivateIpAddress` varchar(40) DEFAULT NULL,
  `PublicIpAddress` varchar(40) DEFAULT NULL,
  `Bandwidth` varchar(40) DEFAULT NULL,
  `InstanceType` varchar(40) DEFAULT NULL,
  `Cpu` varchar(20) DEFAULT NULL,
  `Memory` varchar(20) DEFAULT NULL,
  `OSType` varchar(20) DEFAULT NULL,
  `OSName` varchar(20) DEFAULT NULL,
  `Status` varchar(40) DEFAULT NULL,
  `Account` varchar(40) DEFAULT NULL,
  `CreationTime` varchar(100) DEFAULT NULL,
  `ExpiredTime` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cn_assets_disk` (
  `RegionId` varchar(50) DEFAULT NULL,
  `ZoneId` varchar(50) DEFAULT NULL,
  `InstanceId` varchar(50) DEFAULT NULL,
  `DiskId` varchar(50) DEFAULT NULL,
  `Device` varchar(50) DEFAULT NULL,
  `Size` int(10) DEFAULT NULL,
  `Status` varchar(40) DEFAULT NULL,
  `Account` varchar(30) DEFAULT NULL,
  `CreationTime` varchar(100) DEFAULT NULL,
  `ExpiredTime` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8
