-- meshrouter.chat definition

CREATE TABLE `chat` (
  `dbtime` timestamp NULL DEFAULT NULL,
  `id` bigint DEFAULT NULL,
  `src` bigint DEFAULT NULL,
  `dst` bigint DEFAULT NULL,
  `message` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- meshrouter.info definition

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

-- meshrouter.neighbours definition

CREATE TABLE `neighbours` (
  `dbtime` timestamp NULL DEFAULT NULL,
  `src` bigint DEFAULT NULL,
  `rssi` float DEFAULT NULL,
  `snr` float(7,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- meshrouter.packets definition

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

-- meshrouter.traces definition

CREATE TABLE `traces` (
  `id` bigint NOT NULL,
  `dbtime` datetime NOT NULL,
  `src` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dst` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `snr` decimal(5,2) NOT NULL,
  `is_reverse` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

GRANT ALTER ON meshrouter.* TO 'meshrouter'@'%';
GRANT CREATE ON meshrouter.* TO 'meshrouter'@'%';
GRANT CREATE VIEW ON meshrouter.* TO 'meshrouter'@'%';
GRANT DELETE ON meshrouter.* TO 'meshrouter'@'%';
GRANT DROP ON meshrouter.* TO 'meshrouter'@'%';
GRANT GRANT OPTION ON meshrouter.* TO 'meshrouter'@'%';
GRANT INDEX ON meshrouter.* TO 'meshrouter'@'%';
GRANT INSERT ON meshrouter.* TO 'meshrouter'@'%';
GRANT REFERENCES ON meshrouter.* TO 'meshrouter'@'%';
GRANT SELECT ON meshrouter.* TO 'meshrouter'@'%';
GRANT SHOW VIEW ON meshrouter.* TO 'meshrouter'@'%';
GRANT TRIGGER ON meshrouter.* TO 'meshrouter'@'%';
GRANT UPDATE ON meshrouter.* TO 'meshrouter'@'%';
GRANT ALTER ROUTINE ON meshrouter.* TO 'meshrouter'@'%';
GRANT CREATE ROUTINE ON meshrouter.* TO 'meshrouter'@'%';
GRANT CREATE TEMPORARY TABLES ON meshrouter.* TO 'meshrouter'@'%';
GRANT EXECUTE ON meshrouter.* TO 'meshrouter'@'%';
GRANT LOCK TABLES ON meshrouter.* TO 'meshrouter'@'%';
GRANT GRANT OPTION ON meshrouter.* TO 'meshrouter'@'%';