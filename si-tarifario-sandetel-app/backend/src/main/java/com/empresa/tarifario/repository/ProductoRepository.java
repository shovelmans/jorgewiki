package com.empresa.tarifario.repository;

import com.empresa.tarifario.model.Producto;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductoRepository extends JpaRepository<Producto, Long> {
}