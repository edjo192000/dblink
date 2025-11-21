-- Script de inicialización para MariaDB
-- Parte 1: Configurar MySQL o MariaDB

USE testdb;

-- Crear tabla de prueba
CREATE TABLE alumnos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    carrera VARCHAR(100)
);

-- Insertar datos de prueba
INSERT INTO alumnos (nombre, carrera) VALUES
('Ana Torres', 'Ingeniería en Software'),
('Luis Gómez', 'Desarrollo de Sistemas');

-- Mostrar datos insertados
SELECT 'Datos iniciales en tabla alumnos:' as mensaje;
SELECT * FROM alumnos;
