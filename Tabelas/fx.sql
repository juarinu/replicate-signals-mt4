DROP TABLE IF EXISTS fx;
CREATE TABLE `fx` (
`id` int(5) NOT NULL,
`preco` float NOT NULL,
`stoploss` float NOT NULL,
`takeprofit` float NOT NULL,
`ordem` int(11) NOT NULL,
`simbolo` varchar(25) NOT NULL, 
`numero` int(10)  NOT NULL,  
`lote` float  NOT NULL,   
`saldo_master` float  NOT NULL  
) ENGINE=InnoDB DEFAULT CHARSET=utf8;