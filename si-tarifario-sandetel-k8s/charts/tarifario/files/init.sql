CREATE DATABASE IF NOT EXISTS concesionario;
USE concesionario;

CREATE TABLE IF NOT EXISTS personas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dni VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(150),
    direccion VARCHAR(255),
    ciudad VARCHAR(100),
    provincia VARCHAR(100),
    codigo_postal VARCHAR(10),
    fecha_nacimiento DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS empleados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    persona_id INT NOT NULL,
    puesto VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2) NOT NULL,
    fecha_contratacion DATE NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (persona_id) REFERENCES personas(id)
);

CREATE TABLE IF NOT EXISTS clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    persona_id INT NOT NULL,
    tipo_cliente VARCHAR(50) DEFAULT 'particular',
    puntos_fidelidad INT DEFAULT 0,
    fecha_alta DATE NOT NULL,
    FOREIGN KEY (persona_id) REFERENCES personas(id)
);

CREATE TABLE IF NOT EXISTS marcas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    pais_origen VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS modelos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    marca_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    segmento VARCHAR(50),
    combustible VARCHAR(50),
    FOREIGN KEY (marca_id) REFERENCES marcas(id)
);

CREATE TABLE IF NOT EXISTS concesionarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    direccion VARCHAR(255),
    telefono VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS coches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    modelo_id INT NOT NULL,
    concesionario_id INT NOT NULL,
    matricula VARCHAR(20) UNIQUE,
    bastidor VARCHAR(50) UNIQUE,
    color VARCHAR(50),
    anio INT NOT NULL,
    kilometros INT DEFAULT 0,
    precio DECIMAL(10,2) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    fecha_entrada DATE,
    vendido BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (modelo_id) REFERENCES modelos(id),
    FOREIGN KEY (concesionario_id) REFERENCES concesionarios(id)
);

CREATE TABLE IF NOT EXISTS ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    coche_id INT NOT NULL,
    cliente_id INT NOT NULL,
    empleado_id INT NOT NULL,
    fecha_venta DATE NOT NULL,
    precio_final DECIMAL(10,2) NOT NULL,
    metodo_pago VARCHAR(50),
    financiado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (coche_id) REFERENCES coches(id),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (empleado_id) REFERENCES empleados(id)
);

CREATE TABLE IF NOT EXISTS mantenimientos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    coche_id INT NOT NULL,
    fecha DATE NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    coste DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (coche_id) REFERENCES coches(id)
);

INSERT INTO personas (dni, nombre, apellidos, telefono, email, direccion, ciudad, provincia, codigo_postal, fecha_nacimiento) VALUES
('11111111A', 'Juan', 'Pérez García', '600111111', 'juan.perez@example.com', 'Calle Sol 1', 'Sevilla', 'Sevilla', '41001', '1985-03-10'),
('22222222B', 'María', 'López Ruiz', '600222222', 'maria.lopez@example.com', 'Avenida Luna 2', 'Málaga', 'Málaga', '29001', '1990-07-15'),
('33333333C', 'Carlos', 'Sánchez Díaz', '600333333', 'carlos.sanchez@example.com', 'Plaza Centro 3', 'Granada', 'Granada', '18001', '1978-11-20'),
('44444444D', 'Ana', 'Martín Gómez', '600444444', 'ana.martin@example.com', 'Calle Norte 4', 'Córdoba', 'Córdoba', '14001', '1992-01-08'),
('55555555E', 'Luis', 'Fernández Torres', '600555555', 'luis.fernandez@example.com', 'Calle Sur 5', 'Cádiz', 'Cádiz', '11001', '1988-05-22'),
('66666666F', 'Elena', 'Ramírez Castro', '600666666', 'elena.ramirez@example.com', 'Calle Río 6', 'Huelva', 'Huelva', '21001', '1995-09-12'),
('77777777G', 'Pedro', 'Navarro Jiménez', '600777777', 'pedro.navarro@example.com', 'Avenida Mar 7', 'Jaén', 'Jaén', '23001', '1983-06-30'),
('88888888H', 'Lucía', 'Ortega Molina', '600888888', 'lucia.ortega@example.com', 'Calle Sierra 8', 'Almería', 'Almería', '04001', '1998-12-01'),
('99999999I', 'Javier', 'Moreno León', '600999999', 'javier.moreno@example.com', 'Calle Real 9', 'Sevilla', 'Sevilla', '41002', '1981-04-17'),
('10101010J', 'Carmen', 'Vega Romero', '601010101', 'carmen.vega@example.com', 'Calle Nueva 10', 'Málaga', 'Málaga', '29002', '1993-08-25'),
('12121212K', 'Raúl', 'Herrera Cano', '601212121', 'raul.herrera@example.com', 'Calle Jardín 11', 'Granada', 'Granada', '18002', '1987-02-14'),
('13131313L', 'Sara', 'Gil Núñez', '601313131', 'sara.gil@example.com', 'Avenida Andalucía 12', 'Córdoba', 'Córdoba', '14002', '1996-10-03'),
('14141414M', 'Miguel', 'Calvo Pardo', '601414141', 'miguel.calvo@example.com', 'Calle Feria 13', 'Cádiz', 'Cádiz', '11002', '1984-07-07'),
('15151515N', 'Paula', 'Reyes Vidal', '601515151', 'paula.reyes@example.com', 'Calle Mercado 14', 'Huelva', 'Huelva', '21002', '1991-11-11'),
('16161616O', 'David', 'Cruz Santos', '601616161', 'david.cruz@example.com', 'Plaza España 15', 'Jaén', 'Jaén', '23002', '1989-01-19');

INSERT INTO empleados (persona_id, puesto, salario, fecha_contratacion, activo) VALUES
(1, 'Vendedor', 24000.00, '2021-01-10', TRUE),
(2, 'Vendedor', 25000.00, '2020-03-15', TRUE),
(3, 'Jefe de ventas', 32000.00, '2019-06-01', TRUE),
(4, 'Administrativa', 22000.00, '2022-02-20', TRUE),
(5, 'Mecánico', 23000.00, '2021-09-05', TRUE);

INSERT INTO clientes (persona_id, tipo_cliente, puntos_fidelidad, fecha_alta) VALUES
(6, 'particular', 120, '2023-01-10'),
(7, 'particular', 80, '2023-02-18'),
(8, 'empresa', 300, '2022-11-03'),
(9, 'particular', 50, '2024-01-12'),
(10, 'particular', 20, '2024-03-22'),
(11, 'empresa', 500, '2022-05-14'),
(12, 'particular', 0, '2024-04-30'),
(13, 'particular', 40, '2023-12-01'),
(14, 'empresa', 250, '2023-06-18'),
(15, 'particular', 10, '2024-02-09');

INSERT INTO marcas (nombre, pais_origen) VALUES
('Toyota', 'Japón'),
('Volkswagen', 'Alemania'),
('Seat', 'España'),
('Renault', 'Francia'),
('Peugeot', 'Francia'),
('BMW', 'Alemania'),
('Audi', 'Alemania'),
('Mercedes-Benz', 'Alemania');

INSERT INTO modelos (marca_id, nombre, segmento, combustible) VALUES
(1, 'Corolla', 'Berlina', 'Gasolina'),
(1, 'Yaris', 'Utilitario', 'Híbrido'),
(2, 'Golf', 'Compacto', 'Diésel'),
(2, 'Polo', 'Utilitario', 'Gasolina'),
(3, 'Ibiza', 'Utilitario', 'Gasolina'),
(3, 'León', 'Compacto', 'Diésel'),
(4, 'Clio', 'Utilitario', 'Gasolina'),
(4, 'Megane', 'Compacto', 'Híbrido'),
(5, '208', 'Utilitario', 'Gasolina'),
(5, '308', 'Compacto', 'Diésel'),
(6, 'Serie 1', 'Compacto', 'Gasolina'),
(6, 'Serie 3', 'Berlina', 'Diésel'),
(7, 'A3', 'Compacto', 'Gasolina'),
(7, 'A4', 'Berlina', 'Diésel'),
(8, 'Clase A', 'Compacto', 'Gasolina'),
(8, 'Clase C', 'Berlina', 'Híbrido');

INSERT INTO concesionarios (nombre, ciudad, direccion, telefono) VALUES
('Concesionario Centro Sevilla', 'Sevilla', 'Av. Constitución 100', '955000001'),
('Concesionario Málaga Motor', 'Málaga', 'Calle Larios 25', '952000002'),
('Concesionario Granada Auto', 'Granada', 'Camino de Ronda 50', '958000003');

INSERT INTO coches (modelo_id, concesionario_id, matricula, bastidor, color, anio, kilometros, precio, estado, fecha_entrada, vendido) VALUES
(1, 1, '1234ABC', 'BASTIDOR0001', 'Blanco', 2022, 15000, 18500.00, 'disponible', '2024-01-10', FALSE),
(2, 1, '1235ABC', 'BASTIDOR0002', 'Rojo', 2023, 5000, 17200.00, 'disponible', '2024-01-15', FALSE),
(3, 1, '1236ABC', 'BASTIDOR0003', 'Gris', 2021, 32000, 19800.00, 'vendido', '2024-01-20', TRUE),
(4, 1, '1237ABC', 'BASTIDOR0004', 'Azul', 2020, 41000, 14500.00, 'disponible', '2024-01-22', FALSE),
(5, 2, '1238ABC', 'BASTIDOR0005', 'Negro', 2022, 22000, 16000.00, 'vendido', '2024-02-01', TRUE),
(6, 2, '1239ABC', 'BASTIDOR0006', 'Blanco', 2021, 28000, 17900.00, 'disponible', '2024-02-05', FALSE),
(7, 2, '1240ABC', 'BASTIDOR0007', 'Plateado', 2023, 3000, 16950.00, 'disponible', '2024-02-10', FALSE),
(8, 2, '1241ABC', 'BASTIDOR0008', 'Azul', 2022, 12000, 21000.00, 'reservado', '2024-02-12', FALSE),
(9, 3, '1242ABC', 'BASTIDOR0009', 'Rojo', 2023, 2500, 15800.00, 'disponible', '2024-02-20', FALSE),
(10, 3, '1243ABC', 'BASTIDOR0010', 'Negro', 2021, 33000, 18200.00, 'vendido', '2024-02-22', TRUE),
(11, 3, '1244ABC', 'BASTIDOR0011', 'Blanco', 2022, 14000, 28900.00, 'disponible', '2024-03-01', FALSE),
(12, 3, '1245ABC', 'BASTIDOR0012', 'Gris', 2020, 46000, 30500.00, 'disponible', '2024-03-05', FALSE),
(13, 1, '1246ABC', 'BASTIDOR0013', 'Azul', 2023, 7000, 27500.00, 'disponible', '2024-03-10', FALSE),
(14, 1, '1247ABC', 'BASTIDOR0014', 'Negro', 2021, 39000, 31200.00, 'vendido', '2024-03-15', TRUE),
(15, 2, '1248ABC', 'BASTIDOR0015', 'Blanco', 2023, 6000, 33000.00, 'reservado', '2024-03-18', FALSE),
(16, 2, '1249ABC', 'BASTIDOR0016', 'Gris', 2022, 11000, 36800.00, 'disponible', '2024-03-20', FALSE);

INSERT INTO ventas (coche_id, cliente_id, empleado_id, fecha_venta, precio_final, metodo_pago, financiado) VALUES
(3, 1, 1, '2024-02-01', 19200.00, 'transferencia', FALSE),
(5, 2, 2, '2024-02-14', 15500.00, 'financiacion', TRUE),
(10, 3, 3, '2024-03-01', 17800.00, 'contado', FALSE),
(14, 4, 1, '2024-03-22', 30750.00, 'financiacion', TRUE);

INSERT INTO mantenimientos (coche_id, fecha, tipo, descripcion, coste) VALUES
(1, '2024-04-01', 'Revisión', 'Cambio de aceite y filtros', 180.00),
(2, '2024-04-05', 'Neumáticos', 'Sustitución de neumáticos delanteros', 240.00),
(3, '2024-04-10', 'Frenos', 'Cambio de pastillas de freno', 210.00),
(4, '2024-04-15', 'Batería', 'Sustitución de batería', 150.00),
(5, '2024-04-18', 'Revisión', 'Revisión general preentrega', 95.00),
(6, '2024-04-20', 'ITV', 'Gestión y revisión ITV', 75.00);

CREATE INDEX idx_personas_dni ON personas(dni);
CREATE INDEX idx_coches_estado ON coches(estado);
CREATE INDEX idx_coches_matricula ON coches(matricula);
CREATE INDEX idx_ventas_fecha ON ventas(fecha_venta);
CREATE INDEX idx_mantenimientos_fecha ON mantenimientos(fecha);