CREATE DATABASE IF NOT EXISTS tarifario;
USE tarifario;

CREATE TABLE IF NOT EXISTS categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS marcas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    pais_origen VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(255),
    categoria_id INT NOT NULL,
    marca_id INT NOT NULL,
    modelo VARCHAR(100),
    sku VARCHAR(50) NOT NULL UNIQUE,
    precio DECIMAL(10,2) NOT NULL,
    moneda VARCHAR(10) DEFAULT 'EUR',
    stock INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    FOREIGN KEY (marca_id) REFERENCES marcas(id)
);

CREATE TABLE IF NOT EXISTS historico_precios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo DECIMAL(10,2) NOT NULL,
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo VARCHAR(255),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

INSERT INTO categorias (nombre, descripcion) VALUES
('Portátiles', 'Equipos portátiles para uso profesional y personal'),
('Monitores', 'Pantallas y monitores de diferentes tamaños'),
('Impresoras', 'Impresoras multifunción y de oficina'),
('Componentes', 'Hardware y componentes internos'),
('Licencias', 'Licencias de software y sistemas operativos'),
('Periféricos', 'Teclados, ratones y accesorios');

INSERT INTO marcas (nombre, pais_origen) VALUES
('Dell', 'Estados Unidos'),
('HP', 'Estados Unidos'),
('Lenovo', 'China'),
('Asus', 'Taiwán'),
('Logitech', 'Suiza'),
('Microsoft', 'Estados Unidos');

INSERT INTO productos (nombre, descripcion, categoria_id, marca_id, modelo, sku, precio, moneda, stock, activo) VALUES
('Portátil Dell Latitude 5540', 'Portátil profesional 15 pulgadas con 16GB RAM y 512GB SSD', 1, 1, 'Latitude 5540', 'DELL-LAT-5540', 949.99, 'EUR', 12, TRUE),
('Portátil HP ProBook 450 G10', 'Portátil de oficina con procesador Intel Core i5', 1, 2, 'ProBook 450 G10', 'HP-PB-450G10', 899.50, 'EUR', 8, TRUE),
('Monitor Lenovo ThinkVision 24', 'Monitor Full HD de 24 pulgadas para escritorio', 2, 3, 'ThinkVision T24', 'LEN-T24-FHD', 179.90, 'EUR', 20, TRUE),
('Monitor Asus ProArt 27', 'Monitor 27 pulgadas orientado a diseño y productividad', 2, 4, 'ProArt PA278', 'ASUS-PA278', 329.00, 'EUR', 6, TRUE),
('Impresora HP LaserJet Pro', 'Impresora láser monocromo para pequeñas oficinas', 3, 2, 'LaserJet Pro 4002', 'HP-LJ-4002', 249.95, 'EUR', 5, TRUE),
('Ratón Logitech MX Master 3S', 'Ratón inalámbrico ergonómico de alta precisión', 6, 5, 'MX Master 3S', 'LOGI-MX3S', 99.99, 'EUR', 25, TRUE),
('Teclado Logitech MX Keys', 'Teclado inalámbrico para oficina y productividad', 6, 5, 'MX Keys', 'LOGI-MXKEYS', 109.99, 'EUR', 18, TRUE),
('Licencia Windows 11 Pro', 'Licencia profesional de sistema operativo', 5, 6, 'Windows 11 Pro', 'MS-W11-PRO', 189.00, 'EUR', 50, TRUE),
('Memoria RAM Kingston 16GB DDR4', 'Módulo de memoria DDR4 para ampliación de equipos', 4, 3, '16GB DDR4', 'RAM-16-DDR4', 64.90, 'EUR', 30, TRUE),
('SSD NVMe 1TB Samsung', 'Disco SSD NVMe de alto rendimiento', 4, 4, 'NVMe 1TB', 'SSD-NVME-1TB', 119.00, 'EUR', 15, TRUE);

INSERT INTO historico_precios (producto_id, precio_anterior, precio_nuevo, motivo) VALUES
(1, 999.99, 949.99, 'Oferta de campaña'),
(2, 929.50, 899.50, 'Ajuste de tarifa'),
(3, 199.90, 179.90, 'Descuento temporal'),
(6, 105.99, 99.99, 'Promoción de periféricos'),
(8, 199.00, 189.00, 'Revisión comercial');

CREATE INDEX idx_productos_nombre ON productos(nombre);
CREATE INDEX idx_productos_sku ON productos(sku);
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_marca ON productos(marca_id);
CREATE INDEX idx_historico_producto ON historico_precios(producto_id);
CREATE INDEX idx_historico_fecha ON historico_precios(fecha_cambio);