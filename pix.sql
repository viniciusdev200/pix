-- PIX

CREATE TABLE IF NOT EXISTS `pix` (
	`id` int(10) NOT NULL auto_increment,
	`userid` varchar(255) NOT NULL DEFAULT '0',
	`namekey` varchar(255) NOT NULL DEFAULT '0',
	`pixkey` varchar(255) NOT NULL DEFAULT '0',
	PRIMARY KEY( `id` )
);