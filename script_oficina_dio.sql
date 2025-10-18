-- =================================================================================
-- CRIAÇÃO DO ESQUEMA (DDL) PARA O CENÁRIO DA OFICINA
-- =================================================================================

-- drop database oficina;
create database if not exists oficina;
use oficina;

-- 1. Tabela Cliente
create table Cliente(
    idCliente int auto_increment primary key,
    Nome varchar(100) not null,
    CPF char(11) not null unique,
    Endereco varchar(255),
    Telefone char(11)
);

-- 2. Tabela Veículo (Relacionamento 1:N com Cliente)
create table Veiculo(
    idVeiculo int auto_increment primary key,
    Placa char(7) not null unique,
    Marca varchar(50) not null,
    Modelo varchar(50) not null,
    Ano year,
    idCliente int not null,
    constraint fk_veiculo_cliente foreign key (idCliente) references Cliente(idCliente)
);

-- 3. Tabela Mecânico
create table Mecanico(
    idMecanico int auto_increment primary key,
    Nome varchar(100) not null,
    CPF char(11) not null unique,
    Especialidade enum('Motor', 'Suspensão', 'Elétrica', 'Pintura', 'Geral') default 'Geral',
    Telefone char(11)
);

-- 4. Tabela Ordem de Serviço (OS) (Relacionamento 1:N com Veículo)
create table OS(
    idOS int auto_increment primary key,
    DataEmissao date not null,
    DataConclusao date,
    StatusOS enum('Em Análise', 'Em Execução', 'Aguardando Peças', 'Concluída', 'Cancelada') default 'Em Análise',
    ValorTotal float default 0, -- Será calculado posteriormente
    idVeiculo int not null,
    constraint fk_os_veiculo foreign key (idVeiculo) references Veiculo(idVeiculo)
);

-- 5. Tabela N:M entre OS e Mecânico
create table MecanicoOS(
    idMecanico int,
    idOS int,
    DataAtribuicao date not null,
    primary key (idMecanico, idOS),
    constraint fk_mos_mecanico foreign key (idMecanico) references Mecanico(idMecanico),
    constraint fk_mos_os foreign key (idOS) references OS(idOS)
);

-- 6. Tabela Peça
create table Peca(
    idPeca int auto_increment primary key,
    Descricao varchar(100) not null,
    ValorUnitario float not null,
    QuantidadeEstoque int default 0
);

-- 7. Tabela N:M entre OS e Peça
create table PecaOS(
    idPeca int,
    idOS int,
    QuantidadeUsada int not null,
    PrecoVenda float not null, -- Preço na data da OS, para histórico
    primary key (idPeca, idOS),
    constraint fk_pos_peca foreign key (idPeca) references Peca(idPeca),
    constraint fk_pos_os foreign key (idOS) references OS(idOS)
);

-- 8. Tabela Serviço
create table Servico(
    idServico int auto_increment primary key,
    Descricao varchar(100) not null,
    ValorMaoObra float not null
);

-- 9. Tabela N:M entre OS e Serviço
create table ServicoOS(
    idServico int,
    idOS int,
    StatusServico enum('Pendente', 'Em Andamento', 'Concluído') default 'Pendente',
    primary key (idServico, idOS),
    constraint fk_sos_servico foreign key (idServico) references Servico(idServico),
    constraint fk_sos_os foreign key (idOS) references OS(idOS)
);

