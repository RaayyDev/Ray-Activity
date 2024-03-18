CREATE TABLE `activity` (
  `identifier` varchar(100)  NOT NULL,
  `time` int(11) NOT NULL DEFAULT 0,
  `login` int(11) NOT NULL DEFAULT 0,
  `discord` varchar(100)  NOT NULL,
  `last_logout` VARCHAR(19)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
