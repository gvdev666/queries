-- Crear la base de datos
CREATE DATABASE TiendaOnline;
USE TiendaOnline;

-- Crear la tabla Clientes
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único para cada cliente
    Nombre VARCHAR(100),                      -- Nombre del cliente
    Email VARCHAR(100) UNIQUE,                -- Correo electrónico del cliente, único en la tabla
    FechaRegistro DATE,                       -- Fecha de registro del cliente
    Direccion VARCHAR(255)                    -- Dirección del cliente
);

-- Crear la tabla Productos
CREATE TABLE Productos (
    ProductoID INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único para cada producto
    Nombre VARCHAR(100),                       -- Nombre del producto
    Descripcion TEXT,                          -- Descripción del producto
    Precio DECIMAL(10, 2),                     -- Precio del producto
    Stock INT,                                 -- Cantidad disponible en inventario
    CategoriaID INT,                           -- Categoría a la que pertenece el producto
    FOREIGN KEY (CategoriaID) REFERENCES Categorias(CategoriaID) -- Clave foránea hacia la tabla Categorias
);

-- Crear la tabla Categorias
CREATE TABLE Categorias (
    CategoriaID INT PRIMARY KEY AUTO_INCREMENT, -- Identificador único para cada categoría
    Nombre VARCHAR(100)                         -- Nombre de la categoría
);

-- Crear la tabla Órdenes
CREATE TABLE Ordenes (
    OrdenID INT PRIMARY KEY AUTO_INCREMENT,   -- Identificador único para cada orden
    ClienteID INT,                            -- Identificador del cliente que hizo la orden
    FechaOrden DATE,                          -- Fecha en que se realizó la orden
    Total DECIMAL(10, 2),                     -- Total de la orden
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID) -- Clave foránea hacia la tabla Clientes
);

-- Crear la tabla Detalles_Orden
CREATE TABLE Detalles_Orden (
    DetalleID INT PRIMARY KEY AUTO_INCREMENT,  -- Identificador único para cada detalle de orden
    OrdenID INT,                               -- Identificador de la orden
    ProductoID INT,                            -- Identificador del producto en la orden
    Cantidad INT,                              -- Cantidad del producto en la orden
    Precio DECIMAL(10, 2),                     -- Precio del producto en la orden
    FOREIGN KEY (OrdenID) REFERENCES Ordenes(OrdenID), -- Clave foránea hacia la tabla Ordenes
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID) -- Clave foránea hacia la tabla Productos
);


-- Insertar un nuevo cliente
INSERT INTO Clientes (Nombre, Email, FechaRegistro, Direccion)
VALUES ('Juan Pérez', 'juan.perez@example.com', '2024-08-20', 'Calle Falsa 123');


-- Seleccionar todos los productos de la tabla Productos
SELECT * FROM Productos;

-- Actualizar el stock del producto con ID 1
UPDATE Productos
SET Stock = 50
WHERE ProductoID = 1;

-- Eliminar la categoría con ID 3
DELETE FROM Categorias
WHERE CategoriaID = 3;


-- Eliminar la categoría con ID 3
DELETE FROM Categorias
WHERE CategoriaID = 3;



-- Seleccionar información detallada de todas las órdenes junto con los productos correspondientes
SELECT 
    Ordenes.OrdenID, 
    Clientes.Nombre AS NombreCliente, 
    Productos.Nombre AS NombreProducto, 
    Detalles_Orden.Cantidad, 
    Detalles_Orden.Precio, 
    (Detalles_Orden.Cantidad * Detalles_Orden.Precio) AS Subtotal
FROM 
    Ordenes
JOIN 
    Clientes ON Ordenes.ClienteID = Clientes.ClienteID -- Unir la tabla Ordenes con Clientes para obtener el nombre del cliente
JOIN 
    Detalles_Orden ON Ordenes.OrdenID = Detalles_Orden.OrdenID -- Unir la tabla Ordenes con Detalles_Orden para obtener los detalles de cada orden
JOIN 
    Productos ON Detalles_Orden.ProductoID = Productos.ProductoID -- Unir la tabla Detalles_Orden con Productos para obtener el nombre del producto
ORDER BY 
    Ordenes.OrdenID; -- Ordenar los resultados por el ID de la orden


-- Seleccionar clientes junto con el total gastado en todas sus órdenes
SELECT 
    Clientes.Nombre, 
    SUM(Ordenes.Total) AS TotalGastado
FROM 
    Clientes
JOIN 
    Ordenes ON Clientes.ClienteID = Ordenes.ClienteID -- Unir Clientes con Ordenes
GROUP BY 
    Clientes.Nombre
HAVING 
    TotalGastado > 100; -- Filtrar clientes que han gastado más de 100 en total


-- Seleccionar el producto más vendido (con la mayor cantidad total vendida)
SELECT 
    Nombre, 
    TotalVendido
FROM 
    Productos
JOIN 
    (SELECT 
        ProductoID, 
        SUM(Cantidad) AS TotalVendido
     FROM 
        Detalles_Orden
     GROUP BY 
        ProductoID
     ORDER BY 
        TotalVendido DESC
     LIMIT 1) AS ProductosVendidos ON Productos.ProductoID = ProductosVendidos.ProductoID;



-- Clasificar clientes como 'Premium', 'Regular' o 'Básico' basado en su gasto total
SELECT 
    Clientes.Nombre, 
    SUM(Ordenes.Total) AS TotalGastado,
    CASE 
        WHEN SUM(Ordenes.Total) > 500 THEN 'Premium'
        WHEN SUM(Ordenes.Total) BETWEEN 200 AND 500 THEN 'Regular'
        ELSE 'Básico'
    END AS CategoriaCliente
FROM 
    Clientes
JOIN 
    Ordenes ON Clientes.ClienteID = Ordenes.ClienteID
GROUP BY 
    Clientes.Nombre;




-- Seleccionar los detalles de las órdenes realizadas en los últimos 30 días
WITH OrdenesRecientes AS (
    SELECT 
        * 
    FROM 
        Ordenes 
    WHERE 
        FechaOrden >= CURDATE() - INTERVAL 30 DAY
)
SELECT 
    OrdenesRecientes.OrdenID, 
    Clientes.Nombre AS NombreCliente, 
    OrdenesRecientes.Total
FROM 
    OrdenesRecientes
JOIN 
    Clientes ON OrdenesRecientes.ClienteID = Clientes.ClienteID;
