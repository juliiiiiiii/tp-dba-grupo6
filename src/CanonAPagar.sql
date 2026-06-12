CREATE TABLE Concesiones.CanonPagar (
    id INT IDENTITY(1,1) PRIMARY KEY,
    monto DECIMAL(10,2) NOT NULL,
    fecha_generacion DATE NOT NULL,
    fecha_pagado DATE NULL,
    estado VARCHAR(30) NOT NULL,
    periodo VARCHAR(50) NOT NULL,
    idConcesion int not null,
    constraint FK_CANON_CONCESION foreign key (idConcesion) references Concesiones.Concesion(id)
);

CREATE PROCEDURE Concesiones.AltaCanonPagar
    @monto DECIMAL(10,2),
    @fecha_generacion DATE,
    @periodo VARCHAR(50),
    @concesion int
AS BEGIN
    INSERT INTO Concesiones.CanonPagar (monto, fecha_generacion, estado, periodo, idConcesion) VALUES (@monto, @fecha_generacion, 'PENDIENTE', @periodo, @concesion);
END;

CREATE PROCEDURE Concesiones.ModificacionCanonPagar (@id INT, @monto DECIMAL(10,2), @periodo VARCHAR(50)) AS BEGIN
    UPDATE Concesiones.CanonPagar SET monto = @monto, periodo = @periodo WHERE id = @id;
END;

CREATE PROCEDURE Concesiones.PagarCanon (@id INT, @fecha_pago date)  AS BEGIN

    UPDATE Concesiones.CanonPagar SET fecha_pagado = @fecha_pago, estado = 'PAGADO' WHERE id = @id;
END;

CREATE PROCEDURE Concesiones.BajaCanon (@id INT) AS BEGIN
      UPDATE Concesiones.CanonPagar SET estado = 'INVALIDO' WHERE id = @id;
END;