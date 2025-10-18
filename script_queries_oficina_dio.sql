
-- =================================================================================
-- PERSISTÊNCIA DE DADOS (DML) PARA TESTES
-- =================================================================================

-- Inserir Clientes
insert into Cliente (Nome, CPF, Endereco, Telefone) values
('João Silva', '11111111111', 'Rua A, 100', '11987654321'), -- idCliente 1
('Maria Souza', '22222222222', 'Avenida B, 200', '21912345678'), -- idCliente 2
('Pedro Santos', '33333333333', 'Rua C, 300', '31965432109'); -- idCliente 3

-- Inserir Veículos
insert into Veiculo (Placa, Marca, Modelo, Ano, idCliente) values
('ABC1234', 'Fiat', 'Palio', 2010, 1), -- idVeiculo 1 (João)
('XYZ5678', 'Ford', 'Focus', 2018, 2), -- idVeiculo 2 (Maria)
('GHI9012', 'VW', 'Golf', 2022, 3), -- idVeiculo 3 (Pedro)
('JKL3456', 'Fiat', 'Uno', 1999, 1); -- idVeiculo 4 (João)

-- Inserir Mecânicos
insert into Mecanico (Nome, CPF, Especialidade, Telefone) values
('Carlos Lima', '44444444444', 'Motor', '11911112222'), -- idMecanico 1
('Ana Oliveira', '55555555555', 'Elétrica', '21933334444'), -- idMecanico 2
('José Pereira', '66666666666', 'Geral', '31955556666'); -- idMecanico 3

-- Inserir Peças
insert into Peca (Descricao, ValorUnitario, QuantidadeEstoque) values
('Filtro de Óleo', 25.00, 50), -- idPeca 1
('Vela de Ignição', 45.00, 100), -- idPeca 2
('Pastilha de Freio', 120.00, 30), -- idPeca 3
('Bateria 60Ah', 350.00, 15); -- idPeca 4

-- Inserir Serviços
insert into Servico (Descricao, ValorMaoObra) values
('Troca de Óleo e Filtro', 50.00), -- idServico 1
('Revisão Elétrica Básica', 80.00), -- idServico 2
('Substituição de Suspensão', 300.00), -- idServico 3
('Diagnóstico de Motor', 150.00); -- idServico 4

-- Inserir Ordens de Serviço (OS)
insert into OS (DataEmissao, DataConclusao, StatusOS, idVeiculo) values
('2025-10-01', '2025-10-05', 'Concluída', 1), -- idOS 1 (Palio - João)
('2025-10-10', null, 'Em Execução', 2), -- idOS 2 (Focus - Maria)
('2025-10-15', null, 'Aguardando Peças', 3), -- idOS 3 (Golf - Pedro)
('2025-10-18', null, 'Em Execução', 4); -- idOS 4 (Uno - João)

-- Atribuir Mecânicos às OSs (MecanicoOS)
insert into MecanicoOS (idMecanico, idOS, DataAtribuicao) values
(1, 1, '2025-10-01'), -- Carlos trabalhou na OS 1
(3, 1, '2025-10-02'), -- José também trabalhou na OS 1
(1, 2, '2025-10-10'), -- Carlos trabalhando na OS 2
(2, 3, '2025-10-15'), -- Ana na OS 3
(3, 4, '2025-10-18'); -- José na OS 4

-- Adicionar Serviços às OSs (ServicoOS)
insert into ServicoOS (idServico, idOS, StatusServico) values
(1, 1, 'Concluído'), -- Troca de Óleo na OS 1
(4, 1, 'Concluído'), -- Diagnóstico na OS 1
(1, 2, 'Em Andamento'), -- Troca de Óleo na OS 2
(2, 3, 'Pendente'), -- Revisão Elétrica na OS 3
(3, 4, 'Em Andamento'); -- Substituição de Suspensão na OS 4

-- Adicionar Peças às OSs (PecaOS)
insert into PecaOS (idPeca, idOS, QuantidadeUsada, PrecoVenda) values
(1, 1, 1, 25.00), -- Filtro de Óleo na OS 1
(2, 1, 4, 45.00), -- Velas de Ignição na OS 1
(3, 2, 2, 120.00), -- Pastilhas na OS 2
(4, 3, 1, 350.00); -- Bateria na OS 3

-- Atualizar ValorTotal da OS 1 (Peças: 25 + (4*45) = 205. Serviços: 50 + 150 = 200. Total: 405)
UPDATE OS SET ValorTotal = 405.00 WHERE idOS = 1; 

-- Atualizar ValorTotal da OS 2 (Peças: 2*120 = 240. Serviços: 50. Total: 290)
UPDATE OS SET ValorTotal = 290.00 WHERE idOS = 2; 

-- Atualizar ValorTotal da OS 3 (Peças: 1*350 = 350. Serviços: 80. Total: 430)
UPDATE OS SET ValorTotal = 430.00 WHERE idOS = 3; 

-- =================================================================================
-- QUERIES COMPLEXAS (RECUPERAÇÕES, FILTROS, AGRUPAMENTO, JUNÇÕES)
-- =================================================================================

-- PERGUNTA 1: Qual é o custo total de peças em todas as Ordens de Serviço em execução (Em Execução)?
SELECT 
    OS.idOS,
    V.Placa,
    V.Modelo,
    SUM(PO.QuantidadeUsada * PO.PrecoVenda) AS Custo_Total_Pecas -- EXPRESSÃO PARA GERAR ATRIBUTO DERIVADO
FROM OS
INNER JOIN Veiculo V ON OS.idVeiculo = V.idVeiculo
INNER JOIN PecaOS PO ON OS.idOS = PO.idOS -- JUNÇÃO ENTRE TABELAS
WHERE OS.StatusOS = 'Em Execução' -- FILTRO COM WHERE STATEMENT
GROUP BY OS.idOS, V.Placa, V.Modelo
ORDER BY Custo_Total_Pecas DESC; -- DEFINE ORDENAÇÃO DOS DADOS COM ORDER BY


-- PERGUNTA 2: Quais mecânicos têm mais de uma OS atribuída, e qual a sua especialidade?
SELECT 
    M.Nome AS Nome_Mecanico,
    M.Especialidade,
    COUNT(MO.idOS) AS Total_OS_Atribuidas
FROM Mecanico M
INNER JOIN MecanicoOS MO ON M.idMecanico = MO.idMecanico -- JUNÇÃO
GROUP BY M.Nome, M.Especialidade
HAVING COUNT(MO.idOS) > 1 -- CONDIÇÕES DE FILTROS AOS GRUPOS – HAVING STATEMENT
ORDER BY Total_OS_Atribuidas DESC;


-- PERGUNTA 3: Listar todas as Ordens de Serviço Concluídas, mostrando o nome do cliente e a placa do veículo, e calcular o valor da Mão de Obra de cada OS.
SELECT
    C.Nome AS Nome_Cliente,
    V.Placa,
    V.Modelo,
    OS.DataEmissao,
    OS.ValorTotal AS Valor_OS_Total,
    SUM(S.ValorMaoObra) AS Valor_Mao_Obra_Total -- EXPRESSÃO PARA GERAR ATRIBUTO DERIVADO (soma dos serviços)
FROM OS
INNER JOIN Veiculo V ON OS.idVeiculo = V.idVeiculo
INNER JOIN Cliente C ON V.idCliente = C.idCliente -- JUNÇÃO TRIPLA
INNER JOIN ServicoOS SO ON OS.idOS = SO.idOS
INNER JOIN Servico S ON SO.idServico = S.idServico
WHERE OS.StatusOS = 'Concluída' -- FILTRO COM WHERE STATEMENT
GROUP BY OS.idOS, C.Nome, V.Placa, V.Modelo, OS.DataEmissao, OS.ValorTotal
ORDER BY OS.DataEmissao;


-- PERGUNTA 4: Qual a descrição dos serviços e peças utilizadas na OS 1? (JUNÇÃO)
SELECT 
    'Serviço' AS Tipo,
    S.Descricao AS Detalhe,
    S.ValorMaoObra AS Valor_Unitario
FROM Servico S
INNER JOIN ServicoOS SO ON S.idServico = SO.idServico
WHERE SO.idOS = 1

UNION ALL

SELECT
    'Peça' AS Tipo,
    P.Descricao AS Detalhe,
    PO.PrecoVenda AS Valor_Unitario
FROM Peca P
INNER JOIN PecaOS PO ON P.idPeca = PO.idPeca
WHERE PO.idOS = 1
ORDER BY Tipo, Detalhe;


-- PERGUNTA 5: Qual o estoque atual das peças cujo valor unitário é superior a R$ 100,00? (FILTRO SIMPLES)
SELECT
    Descricao AS Nome_Peca,
    ValorUnitario,
    QuantidadeEstoque
FROM Peca
WHERE ValorUnitario > 100.00 -- FILTRO COM WHERE STATEMENT
ORDER BY QuantidadeEstoque DESC; -- ORDENAÇÃO


