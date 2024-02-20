10.1
a.
CREATE TABLE Furnizori (
    idf VARCHAR(255) PRIMARY KEY,
    numef VARCHAR(255),
    stare INT,
    oras VARCHAR(255)
);

b.
CREATE TABLE Componente (
    idc VARCHAR(255) PRIMARY KEY,
    numec VARCHAR(255),
    culoare VARCHAR(255),
    masa INT,
    oras VARCHAR(255)
);

c.
CREATE TABLE Proiecte (
    idp VARCHAR(255) PRIMARY KEY,
    numep VARCHAR(255),
    oras VARCHAR(255)
);

d.
CREATE TABLE Livrari (
    idf VARCHAR(255),
    idc VARCHAR(255),
    idp VARCHAR(255),
    cantitate INT,
    um VARCHAR(255),
    PRIMARY KEY (idf, idc, idp),
    FOREIGN KEY (idf) REFERENCES Furnizori(idf),
    FOREIGN KEY (idc) REFERENCES Componente(idc),
    FOREIGN KEY (idp) REFERENCES Proiecte(idp)
);

f.
ALTER TABLE Livrari
DROP COLUMN um;

10.2
a.
ALTER TABLE Componente
ADD CONSTRAINT check_culoare
CHECK (culoare IN ('roșu', 'verde', 'albastru', 'galben', 'negru', 'alb'));

b.
ALTER TABLE Proiecte
ADD CONSTRAINT check_nume_special
CHECK (oras <> 'Dej' OR (oras = 'Dej' AND numep LIKE '%special%'));

10.3
a.
SELECT * FROM Furnizori
ORDER BY stare DESC, numef ASC;

b.
SELECT * FROM Componente
WHERE masa BETWEEN 100 AND 500
AND oras = 'Cluj-Napoca';

10.4
a.
SELECT Proiecte.numep, Componente.numec, Proiecte.oras
FROM Proiecte
JOIN Livrari ON Proiecte.idp = Livrari.idp
JOIN Componente ON Livrari.idc = Componente.idc
WHERE Proiecte.oras = Componente.oras;

b.
SELECT DISTINCT
    a.idp AS idp1, 
    b.idp AS idp2
FROM 
    Livrari a
INNER JOIN 
    Livrari b ON a.idf = b.idf AND a.idc = b.idc
WHERE 
    a.idp < b.idp;

10.5
a.
SELECT numec 
FROM Componente 
WHERE idc IN (
    SELECT idc 
    FROM Livrari 
    WHERE idp IN (
        SELECT idp 
        FROM Proiecte 
        WHERE oras = 'Bistrița'
    ) AND cantitate <= ALL (
        SELECT cantitate 
        FROM Livrari 
        WHERE idp IN (
            SELECT idp 
            FROM Proiecte 
            WHERE oras = 'Bistrița'
        )
    )
);

b.
SELECT numep 
FROM Proiecte 
WHERE EXISTS (
    SELECT 1
    FROM Furnizori
    WHERE Furnizori.oras = Proiecte.oras AND Furnizori.idf = 'F001'
);


10.6
a.
SELECT 
    oras,
    (SELECT COUNT(*) FROM Proiecte WHERE oras = P.oras) AS număr_proiecte,
    (SELECT COUNT(*) FROM Componente WHERE oras = P.oras) AS număr_componente,
    (SELECT COUNT(*) FROM Furnizori WHERE oras = P.oras) AS număr_furnizori
FROM 
    (SELECT oras FROM Proiecte
     UNION 
     SELECT oras FROM Componente
     UNION 
     SELECT oras FROM Furnizori) P;

b.
SELECT 
    MIN(cantitate) AS cantitate_minimă,
    MAX(cantitate) AS cantitate_maximă
FROM 
    Livrari
WHERE 
    idc = 'C12';

10.7
a.
INSERT INTO Furnizori (idf, numef, stare, oras) 
VALUES ('F123', 'Prim', 0, 'Sibiu');

INSERT INTO Livrari (idf, idc, idp, cantitate) 
VALUES ('F123', 'C213', 'P312', 5);

b.
DELETE FROM Furnizori 
WHERE idf NOT IN (SELECT idf FROM Livrari);


c.
UPDATE Furnizori 
SET stare = (SELECT COUNT(DISTINCT idp) FROM Livrari WHERE Furnizori.idf = Livrari.idf);

10.8
CREATE TABLE Exceptii (
    idf VARCHAR(255),
    numef VARCHAR(255),
    stare INT,
    oras VARCHAR(255),
    natura_exceptiei VARCHAR(255)
);


CREATE OR REPLACE PROCEDURE AdaugaExceptii AS
BEGIN
    INSERT INTO Exceptii (idf, numef, stare, oras, natura_exceptiei)
    SELECT 
        F.idf, F.numef, F.stare, F.oras, 
        CASE 
            WHEN F.oras = C.oras THEN 'Orasul componentei coincide'
            WHEN F.oras = P.oras THEN 'Orasul proiectului coincide'
            ELSE 'Alta exceptie'
        END as natura_exceptiei
    FROM 
        Furnizori F
    JOIN 
        Livrari L ON F.idf = L.idf
    LEFT JOIN 
        Componente C ON L.idc = C.idc
    LEFT JOIN 
        Proiecte P ON L.idp = P.idp
    WHERE 
        F.oras = C.oras OR F.oras = P.oras;
END AdaugaExceptii;

10.9
a.
CREATE OR REPLACE TRIGGER LivrariAfterInsert
AFTER INSERT ON Livrari
FOR EACH ROW
DECLARE
    stare_furnizor INT;
BEGIN
    SELECT stare INTO stare_furnizor FROM Furnizori WHERE idf = :NEW.idf;
    IF stare_furnizor = 0 THEN
        UPDATE Furnizori
        SET stare = 1
        WHERE idf = :NEW.idf;
    END IF;
END;

b.
CREATE VIEW LivrareNoua AS
SELECT  f.idf, numef, f.oras as orasf, c.idc, numec, culoare, masa,
        c.oras as orasc, p.idp, numep, p.oras as orasp, l.cantitate
FROM Furnizori F, Componente C, Proiecte P, Livrari L
WHERE   F.idf = L.idf AND
        C.idc = L.idc AND
        P.idp = L.idp;

CREATE OR REPLACE TRIGGER LivrareNouaInsteadOfInsert
INSTEAD OF INSERT ON LivrareNoua
FOR EACH ROW
DECLARE
    furnizor_exista INT;
    componenta_exista INT;
    proiect_exista INT;
BEGIN
    -- Verifica dacă furnizorul există
    SELECT COUNT(*) INTO furnizor_exista FROM Furnizori WHERE idf = :NEW.idf;
    IF furnizor_exista = 0 THEN
        INSERT INTO Furnizori (idf, numef, oras) 
        VALUES (:NEW.idf, :NEW.numef, :NEW.orasf);
    END IF;

    -- Verifica dacă componenta există
    SELECT COUNT(*) INTO componenta_exista FROM Componente WHERE idc = :NEW.idc;
    IF componenta_exista = 0 THEN
        INSERT INTO Componente (idc, numec, culoare, masa, oras) 
        VALUES (:NEW.idc, :NEW.numec, :NEW.culoare, :NEW.masa, :NEW.orasc);
    END IF;

    -- Verifica dacă proiectul există
    SELECT COUNT(*) INTO proiect_exista FROM Proiecte WHERE idp = :NEW.idp;
    IF proiect_exista = 0 THEN
        INSERT INTO Proiecte (idp, numep, oras) 
        VALUES (:NEW.idp, :NEW.numep, :NEW.orasp);
    END IF;

    -- Inserarea în Livrari
    INSERT INTO Livrari (idf, idc, idp, cantitate) 
    VALUES (:NEW.idf, :NEW.idc, :NEW.idp, :NEW.cantitate);
END;



