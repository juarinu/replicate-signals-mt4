# Replicar sinais através do MT4
## Sistema desenvolvido na linguagem MetaQuotes da plataforma de negociação MetaTrader 4 utilizando a lib `MQLMySQL` 

### Arquivos: `Server.ex4` e `Client.ex4` 

###### Arquivo `Server.ex4` é o responsável por enviar o registro das ordens que forem abertas para o banco de dados. (Servidor) 
###### Arquivo `Client.ex4` é o responsável por capturar o registro das ordens no banco de dados e executá-las. (Cliente)

###### Créditos : [HOW TO ACCESS THE MYSQL DATABASE FROM MQL5 (MQL4)] (https://www.mql5.com/pt/articles/932) .

# Manual de instalação
###### Importante: alterar os dados de conexão com o banco de dados

* Colocar cada arquivo nas suas respectivas pastas do `MetaTrader 4`
* Importar as tabelas 
* Liberar portas no Servidor
* Usar o Expert Advisor (`Server.ex4`) na máquina que irá emitir os sinais, dentro de cada par de moedas que irá operar. 
* Fazer a mesma coisa com o Expert Advisor (`Client.ex4`) nas máquinas dos clientes. 
* Dúvidas: [meu facebook] (https://www.facebook.com/jaamsavio) .
