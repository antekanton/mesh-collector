-- meshcollector.chat definition

CREATE TABLE `chat` (
  `dbtime` timestamp NULL DEFAULT NULL,
  `id` bigint DEFAULT NULL,
  `src` bigint DEFAULT NULL,
  `dst` bigint DEFAULT NULL,
  `message` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- meshcollector.info definition

CREATE TABLE `info` (
  `id` bigint DEFAULT NULL,
  `sname` text,
  `lname` text,
  `longitude` double DEFAULT NULL,
  `latitude` double DEFAULT NULL,
  `altitude` float(7,2) DEFAULT NULL,
  `isMobile` tinyint(1) DEFAULT NULL,
  `role` int DEFAULT NULL,
  `lastHeard` timestamp NULL DEFAULT NULL,
  `isIgnored` tinyint(1) DEFAULT NULL,
  `isFavored` tinyint(1) DEFAULT NULL,
  KEY `idx_id_lastheard` (`id`,`lastHeard` DESC),
  KEY `idx_coords` (`longitude`,`latitude`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- meshcollector.neighbours definition

CREATE TABLE `neighbours` (
  `dbtime` timestamp NULL DEFAULT NULL,
  `src` bigint DEFAULT NULL,
  `rssi` float DEFAULT NULL,
  `snr` float(7,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- meshcollector.packets definition

CREATE TABLE `packets` (
  `dbtime` timestamp NULL DEFAULT NULL,
  `id` bigint DEFAULT NULL,
  `src` bigint DEFAULT NULL,
  `dst` bigint DEFAULT NULL,
  `chHash` int DEFAULT NULL,
  `hopLimit` int DEFAULT NULL,
  `hopStart` int DEFAULT NULL,
  `nextHop` int DEFAULT NULL,
  `relayNode` int DEFAULT NULL,
  `rssi` float DEFAULT NULL,
  `snr` float(7,2) DEFAULT NULL,
  `transport` int DEFAULT NULL,
  `isTX` tinyint(1) DEFAULT NULL,
  `pSize` int DEFAULT NULL,
  `isMQTT` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- meshcollector.traces definition

CREATE TABLE `traces` (
  `id` bigint NOT NULL,
  `dbtime` datetime NOT NULL,
  `src` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dst` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `snr` decimal(5,2) NOT NULL,
  `is_reverse` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- meshcollector.names definition

CREATE TABLE `names` (
  `id` bigint DEFAULT NULL,
  `lname` text,
  `sname` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

GRANT ALTER ON meshcollector.* TO 'meshcollector'@'%';
GRANT CREATE ON meshcollector.* TO 'meshcollector'@'%';
GRANT CREATE VIEW ON meshcollector.* TO 'meshcollector'@'%';
GRANT DELETE ON meshcollector.* TO 'meshcollector'@'%';
GRANT DROP ON meshcollector.* TO 'meshcollector'@'%';
GRANT GRANT OPTION ON meshcollector.* TO 'meshcollector'@'%';
GRANT INDEX ON meshcollector.* TO 'meshcollector'@'%';
GRANT INSERT ON meshcollector.* TO 'meshcollector'@'%';
GRANT REFERENCES ON meshcollector.* TO 'meshcollector'@'%';
GRANT SELECT ON meshcollector.* TO 'meshcollector'@'%';
GRANT SHOW VIEW ON meshcollector.* TO 'meshcollector'@'%';
GRANT TRIGGER ON meshcollector.* TO 'meshcollector'@'%';
GRANT UPDATE ON meshcollector.* TO 'meshcollector'@'%';
GRANT ALTER ROUTINE ON meshcollector.* TO 'meshcollector'@'%';
GRANT CREATE ROUTINE ON meshcollector.* TO 'meshcollector'@'%';
GRANT CREATE TEMPORARY TABLES ON meshcollector.* TO 'meshcollector'@'%';
GRANT EXECUTE ON meshcollector.* TO 'meshcollector'@'%';
GRANT LOCK TABLES ON meshcollector.* TO 'meshcollector'@'%';
GRANT GRANT OPTION ON meshcollector.* TO 'meshcollector'@'%';