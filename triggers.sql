/*Trigger fonetiza nome no insert*/
Delimiter //
CREATE TRIGGER fonetiza_nome_insert BEFORE INSERT ON pessoa 
FOR EACH ROW
BEGIN
		
	set @nomeFonetizar = NEW.nome;
	call fonetizador(@nomeFonetizar);
	set NEW.nomef = @nomeFonetizar;
END//
Delimiter ;

/*Trigger fonetiza nome no update*/
Delimiter //
CREATE TRIGGER fonetiza_nome_update BEFORE UPDATE ON pessoa
FOR EACH ROW
BEGIN
	set @nomeFonetizar = NEW.nome;
	call fonetizador(@nomeFonetizar);
	set NEW.nomef = @nomeFonetizar;
END//
Delimiter ;


/*Função fonetiza nome para select*/
Delimiter //
CREATE FUNCTION fonetizar (nome VARCHAR(100))
RETURNS VARCHAR(100) 
DETERMINISTIC
BEGIN
	
	call fonetizador(nome);

	return nome;
END//
Delimiter ;
