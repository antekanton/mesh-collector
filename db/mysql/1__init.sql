CREATE TABLE meshrouter.packets (dbtime TIMESTAMP, id BIGINT, src BIGINT, dst BIGINT, chHash INT,
  hopLimit INT, hopStart INT, nextHop INT, relayNode INT, rssi FLOAT, snr FLOAT(7,2), transport INT,
  isTX BOOLEAN, pSize INT, isMQTT BOOLEAN);

CREATE TABLE meshrouter.info (id BIGINT, sname text, lname text,
  longitude DOUBLE, latitude DOUBLE, altitude FLOAT(7,2), isMobile BOOLEAN, role INT,
  lastHeard TIMESTAMP, isIgnored BOOLEAN, isFavored BOOLEAN);

CREATE TABLE meshrouter.neighbours (dbtime TIMESTAMP, src BIGINT, rssi FLOAT, snr FLOAT(7,2));

CREATE TABLE meshrouter.names (id BIGINT, lname TEXT, sname TEXT);

CREATE TABLE meshrouter.chat (dbtime TIMESTAMP, id BIGINT, src BIGINT, dst BIGINT, message TEXT);

CREATE TABLE meshrouter.badpkts (dbtime TIMESTAMP, pSize INT);