# Replicar sinais através do MT4
## Sistema desenvolvido na linguagem MetaQuotes da plataforma de negociação MetaTrader 4 utilizando a lib `MQLMySQL` 

### Arquivos: `server.ex4` e `client.ex4` 

###### Arquivo `server.ex4` é o responsável por enviar o registro das ordens que forem abertas para o banco de dados. (Servidor) 
###### Arquivo `client.ex4` é o responsável por capturar o registro das ordens no banco de dados e executá-las. (Cliente)

# Manual de instalação
###### Importante: Alterar os dados de conexão com o banco de dados nos arquivos `server.mq4` e `client.mq4`. 

* Colocar cada arquivo nas suas respectivas pastas do `MetaTrader 4`
* Importar as tabelas 
* Liberar porta 3306 no servidor (VPS) para receber conexões externas  
* Usar o EA (`server.ex4`) na máquina que irá emitir os sinais, dentro de cada par de moedas que irá operar. 
* Fazer a mesma coisa com o EA (`client.ex4`) nas máquinas dos clientes que irão receber os sinais. 
* Criar registro na tabela `fx_assinaturas` com os dados (id->Nome de usuário na corretora / nome->Nome real) e tempo de licença de cada cliente. 
* Verificar na aba `Expert Advisors (Robôs)` do terminal se o EA está funcionando corretamente. 
* Enjoy :) 

###### Dúvidas: [meu facebook] (https://www.facebook.com/jaamsavio) .
###### Créditos : [HOW TO ACCESS THE MYSQL DATABASE FROM MQL5 (MQL4)] (https://www.mql5.com/pt/articles/932) .

