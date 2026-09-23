CREATE DATABASE IF NOT EXISTS coma_bem;
USE coma_bem;

CREATE TABLE usuario (
    usu_id_usuario INT AUTO_INCREMENT PRIMARY KEY, 
    usu_nm_usuario VARCHAR(100) NOT NULL,          
    usu_tx_email VARCHAR(100) NOT NULL UNIQUE,     
    usu_tx_senha VARCHAR(255) NOT NULL             
);

CREATE TABLE restaurante (
    res_id_restaurante INT AUTO_INCREMENT PRIMARY KEY,
    res_nm_restaurante VARCHAR(100) NOT NULL,
    res_nu_latitude VARCHAR(20) NOT NULL,
    res_nu_longitude VARCHAR(20) NOT NULL,
    res_ds_tipo_culinaria VARCHAR(50) NOT NULL 
);

CREATE TABLE prato (
    pra_id_prato INT AUTO_INCREMENT PRIMARY KEY,
    pra_nm_prato VARCHAR(100) NOT NULL,
    pra_im_foto VARCHAR(255) NULL,       
    pra_id_restaurante INT NOT NULL,     

    
    FOREIGN KEY (pra_id_restaurante)
        REFERENCES restaurante(res_id_restaurante)
);

CREATE TABLE avaliacao (
    avl_id_avaliacao INT AUTO_INCREMENT PRIMARY KEY,
    avl_nu_ranking INT NOT NULL,             
    avl_tx_recomendacao TEXT NOT NULL,       
    avl_id_prato INT NOT NULL,               
    avl_id_usuario INT NOT NULL,            

    CHECK (avl_nu_ranking >= 1 AND avl_nu_ranking <= 5),

    FOREIGN KEY (avl_id_prato) REFERENCES prato(pra_id_prato),
    FOREIGN KEY (avl_id_usuario) REFERENCES usuario(usu_id_usuario)
);

INSERT INTO usuario (usu_nm_usuario, usu_tx_email, usu_tx_senha) VALUES
('Carlos Silva', 'carlos@email.com', 'senha123'),
('Mariana Souza', 'mariana@email.com', 'senha456'),
('João Pereira', 'joao@email.com', 'senha789'),
('Fernanda Lima', 'fernanda@email.com', 'senha101'),
('Rafael Costa', 'rafael@email.com', 'senha102');

INSERT INTO restaurante (res_nm_restaurante, res_nu_latitude, res_nu_longitude, res_ds_tipo_culinaria) VALUES
('Sushi House', '-23.550520', '-46.633308', 'Japonesa'),
('Cantina Bella Itália', '-23.561684', '-46.655981', 'Italiana'),
('Le Petit Bistrô', '-23.570123', '-46.641234', 'Francesa'),
('Churrascaria Boi Bom', '-23.582345', '-46.671234', 'Brasileira'),
('Taco Loco', '-23.590987', '-46.680123', 'Mexicana');

INSERT INTO prato (pra_nm_prato, pra_im_foto, pra_id_restaurante) VALUES
('Combinado Salmão', 'img/salmao.jpg', 1),      
('Lasanha à Bolonhesa', 'img/lasanha.jpg', 2),  
('Filet Mignon au Poivre', 'img/filet.jpg', 3), 
('Picanha na Brasa', 'img/picanha.jpg', 4),     
('Nachos Supremos', 'img/nachos.jpg', 5);       


INSERT INTO avaliacao (avl_nu_ranking, avl_tx_recomendacao, avl_id_prato, avl_id_usuario) VALUES
(5, 'O peixe estava extremamente fresco, maravilhoso!', 1, 1),
(4, 'Massa muito boa, mas o molho podia ter mais tempero.', 2, 2),
(5, 'Carne no ponto perfeito, ambiente agradável.', 3, 3),
(3, 'A picanha estava um pouco dura hoje.', 4, 4),
(5, 'Melhor guacamole da cidade, muito bem servido!', 5, 5);


SELECT res_nm_restaurante, res_ds_tipo_culinaria
FROM restaurante
WHERE res_ds_tipo_culinaria = 'Italiana';

SELECT p.pra_nm_prato, a.avl_nu_ranking, a.avl_tx_recomendacao
FROM avaliacao a
INNER JOIN prato p ON a.avl_id_prato = p.pra_id_prato
WHERE a.avl_nu_ranking = 5;

UPDATE avaliacao
SET avl_nu_ranking = 4, avl_tx_recomendacao = 'A carne estava boa, erro meu na avaliação anterior.'
WHERE avl_id_avaliacao = 4;

DELETE FROM avaliacao
WHERE avl_id_avaliacao = 5;

