drop database if exists fonetica;
create database fonetica;
use fonetica;

create table pessoa(
	id int auto_increment,
	nome char(100),
	nomef char(100),
	primary key (id)
);

insert into pessoa (nome, nomef) values ('cilva', 'siuva');

Delimiter $$
/*REMOVE PREPOSICOES E ARTIGOS*/
create procedure removePrep(INOUT nome varchar(100))
begin

	DECLARE preposicoes1 varchar(38) default ' DI DE DA DO AS OS AO NA NO ';
	DECLARE preposicoes2 varchar(38) default ' DOS DAS AOS NAS NOS COM ';
	DECLARE i int default 1;

	set i = 1;
	while i <= 32 do
		set nome = replace(nome, substring(preposicoes1,i,4)," ");
		set i = i + 3;
	end while;

	set i = 1;
	while i <= 30 do
		set nome = replace(nome, substring(preposicoes2,i,5), " ");
		set i = i + 4;
	end while;

	set nome = replace(nome, " E ", " ");

end$$
Delimiter ;

Delimiter $$
/*REMOVE ACENTOS*/
create procedure removeAcentos(INOUT nome varchar(100))
begin
	DECLARE acentos varchar(18) default 'ÁÀÃÂÉÈÊÍÌÎÓÒÔÕÚÙÛÜ';
	DECLARE sem_acentos varchar(18) default 'AAAAEEEIIIOOOOUUUU';
	DECLARE i int default 1;

	set i = 1;
	while i <= length(acentos) do
		set nome = replace(nome, substring(acentos, i, 1), substring(sem_acentos, i , 1));
		set i = i + 1;
	end while;

end$$
Delimiter ;

Delimiter $$
/*ELIMINA LETRAS IGUAIS SEGUIDAS UMA DA OUTRA EXCETO SS*/
create procedure removeMultiplos(INOUT nome char(100))
begin	
	
	DECLARE aux varchar(100);
	DECLARE i int default 1;

	set aux = substring(nome, 1, 1); /*recebe a primeira letra*/
	set i = 2;

	while i <= length(nome) do

		if substring(nome,i - 1, 1) <> substring(nome, i, 1) or substring(nome, i, 1) = 'S' then
			set aux = concat(aux, substring(nome, i, 1));
		end if;		
		
		set i = i + 1;
	end while;

	set nome = aux;

end$$
Delimiter ;

Delimiter $$
create procedure fonetizar(INOUT nome varchar(100))
begin

	DECLARE i int default 1;
	DECLARE retirouLetra int;
	DECLARE letraAux varchar(1);
	DECLARE letra varchar(1);
	DECLARE letraPosterior varchar(1);
	DECLARE letraAnterior varchar(1);

	/*Y vira I*/
	set nome = replace(nome, 'Y', 'I');

	/*Ç troca por S*/
	set nome = replace(nome, 'Ç', 'SS');

	/*Fonetiza o nome percorrendo letra por letra*/
	set i = 1;
	set retirouLetra = 0;	
	while i <= length(nome) do
		
		set letra = substring(nome, i, 1);

		case letra

			when 'C' then

				set letraAnterior = substring(nome, i - 1);
				set letraPosterior = substring(nome, i + 1);
				set letraAux = substring(nome, i + 2);

				/*SCI por SI*/
				if letraAnterior = 'S' and letraPosterior = 'I' then
					set nome = insert(nome, i, 1, '');

				/*Troca C com som de S por S*/
				elseif letraPosterior = 'I' or letraPosterior = 'E' then
				
					set nome = insert(nome, i, 1, 'S');

				/*Troca C por K*/
				elseif letraPosterior <> 'H' then

					set nome = insert(nome, i, 1, 'K');

				/*Troca CH por X, quando CH é seguido por vogal*/				
				elseif (letraPosterior = 'H') and (letraAux = 'A' or letraAux = 'E' or
					letraAux = 'I' or letraAux = 'O' or letraAux = 'U') then

					set nome = insert(nome, i, 2, 'X');
					set retirouLetra = 1;		
				end if;
		
			when 'S' then
				
				/*Se 'S' estiver entre duas vogais, troca por 'Z'*/
				if i >= 2 then				
					
					set letraAnterior = substring(nome, i - 1);
					set letraPosterior = substring(nome, i + 1);
					
					if (letraAnterior = 'A' or letraAnterior = 'E' or letraAnterior = 'I' or letraAnterior = 'O') and
						(letraPosterior = 'A' or letraPosterior = 'E' or letraPosterior = 'O' or letraPosterior = 'I') then
						set nome = insert(nome, i, 1, 'Z');

					/*Troca SS por S*/					
					elseif letraPosterior = 'S' then
						set nome = insert(nome, i, 1, '');

					/*Tira S do final, evita plural*/
					elseif i = length(nome) then
						set nome = insert(nome, i, 1, '');
						set i = i - 2;
					
					end if;	
						
				end if;

			when 'Z' then

				set letraPosterior = substring(nome, i + 1);

				/*Tirar Z do final, evita plural*/
				if i = length(nome) then
					set nome = insert(nome, i, 1, '');
					set i = i - 2;
				
				/*Z + Consoante vira S*/
				elseif letraPosterior <> 'A' and letraPosterior <> 'E' and letraPosterior <> 'I' and 
					letraPosterior <> 'O' and letraPosterior <> 'U' then
					set nome = insert(nome, i, 1, 'S');
				end if;
	

			when 'L' then
			
				set letraPosterior = substring(nome, i + 1);
			
				/*L + consoante (menos com H) troca por U*/
				if letraPosterior <> 'A' and letraPosterior <> 'E' and letraPosterior <> 'I' and 
					letraPosterior <> 'O' and letraPosterior <> 'U' and letraPosterior <> 'H' then
					set nome = insert(nome, i, 1, 'U');

				/*Troca LH por LI*/
				elseif letraPosterior = 'H' then
					set nome = insert(nome, i + 1, 1, 'I');
				end if;

			when 'O' then
				
				set letraAnterior = substring(nome, i - 1);

				/*Quando o nome termina com O, normalmente tem som de U, a não ser que tenha vogais como vizinho*/
				if (i = length(nome)) and (letraAnterior <> 'A' and letraAnterior <> 'E' and letraAnterior <> 'U') then
					set nome = insert(nome, i, 1, 'U');
				end if;
			
			when 'M' then
	
				set letraPosterior = substring(nome, i + 1);
				
				/*M mais consoante vira N*/
				if letraPosterior <> 'A' and letraPosterior <> 'E' and letraPosterior <> 'I' and
					letraPosterior <> 'O' and letraPosterior <> 'U' then

					set nome = insert(nome, i, 1, 'N');
				end if;

			when 'N' then

				set letraPosterior = substring(nome, i + 1);
				
				/*Troca NH por NI*/
				if letraPosterior = 'H' then
					set nome = insert(nome, i + 1, 1, 'I');
				end if;

			when 'P' then

				set letraPosterior = substring(nome, i + 1);
				set letraAux = substring(nome, i + 2);

				/*Troca PH por F*/
				if letraPosterior = 'H' and (letraAux = 'A' or letraAux = 'E' or letraAux = 'I' or 
					letraAux = 'O' or letraAux = 'U') then
					set nome = insert(nome, i, 2, 'F');
				end if;

			when 'H' then

				set letraAnterior = substring(nome, i - 1);

				/*Troca H se ele for mudo*/
				if letraAnterior <> 'L' and letraAnterior <> 'C' and letraAnterior <> 'P' then
					set nome = insert(nome, i, 1, '');
				end if;

			when 'Q' then
	
				set letraPosterior = substring(nome, i + 1);
				set letraAux = substring(nome, i + 2);

				if letraPosterior = 'U' then

					/*Troca QUA e QUO por KUA e KUO, respectivamente*/
					if letraAux = 'O' or letraAux = 'A' then
						set nome = insert(nome, i, 1, 'K');
					/*Troca QUE e QUI por KE e KI, respectivamente*/
					elseif letraAux = 'E' or letraAux = 'I' then
						set nome = insert(nome, i, 2, 'K');
					end if;

				end if;				

			else
        			BEGIN
        			END;
		end case;
		
		set i = i + 1;

	end while;	
	
end$$
Delimiter ;

Delimiter $$
create procedure fonetizador(INOUT nome varchar(100))
begin

	DECLARE aux varchar(100);
	DECLARE i int default 1;
	DECLARE nomeFonetizado varchar(100);
	
	set nome = trim(nome);
	set nome = upper(nome);
	call removePrep(nome);
	call removeMultiplos(nome);
	call removeAcentos(nome);
	
	set nomeFonetizado = '';
	set i = 1;
	while i <= length(nome) do

		if substring(nome, i, 1) = ' ' then
			set aux = substring(nome, 1, i - 1);
			call fonetizar(aux);
			set nomeFonetizado = concat(nomeFonetizado, ' ', aux, ' ');
			set nome = insert(nome, 1, i, '');
			set i = 0;

		elseif i = length(nome) then
			set aux = substring(nome, 1, i);
			call fonetizar(aux);
			set nomeFonetizado = concat(nomeFonetizado, ' ', aux);
		end if;

		set i = i + 1;
	end while;

	set nomeFonetizado = replace(nomeFonetizado, '  ', ' ');
	set nome = trim(nomeFonetizado);
end$$
Delimiter ;


