CREATE TABLE <>.Titulo (
    id INT IDENTITY(1,1) PRIMARY KEY,
    institucion VARCHAR(100) NOT NULL,
    fecha_emision DATE NOT NULL
);

create or alter procedure <>.AltaTitulo
    @institucion VARCHAR(100),
    @fe DATE
AS BEGIN
    INSERT INTO Titulo (institucion, fecha_emision) VALUES (@institucion, @fe);
END;

create or alter procedure <>.BajaTitulo @id INT AS BEGIN
    DELETE FROM Titulo WHERE id = @id;
END;

create or alter procedure <>.ModificacionTitulo
    @id INT,
    @institucion VARCHAR(100),
    @fe DATE
AS BEGIN
    UPDATE <>.Titulo SET institucion = isnull(@institucion, institucion), fecha_emision = isnull(@fe, fecha_emision) WHERE id = @id;
END;