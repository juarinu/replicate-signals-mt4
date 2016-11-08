

CREATE TABLE `fx` (
  
`id` int(5) NOT NULL,
 
`corretora` varchar(50) NOT NULL,
  
`preco` float NOT NULL,
  
`stoploss` float NOT NULL,

`takeprofit` float NOT NULL,
 
`ordem` int(11) NOT NULL,
 
  
`simbolo` varchar(25) NOT NULL,
  
`dia` varchar(2) NOT NULL,
  
`mes` varchar(2) NOT NULL,
  
`ano` varchar(4) NOT NULL,
  
`hora` varchar(2) NOT NULL,
  
`minutos` varchar(2) NOT NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8;