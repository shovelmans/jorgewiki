const API_URL = "http://localhost:5000/productos";

async function cargarProductos() {
  try {
    const respuesta = await fetch(API_URL);
    const productos = await respuesta.json();

    const tbody = document.getElementById("productos-body");
    tbody.innerHTML = "";

    productos.forEach(producto => {
      const fila = document.createElement("tr");

      fila.innerHTML = `
        <td>${producto.id}</td>
        <td>${producto.nombre}</td>
        <td>${producto.marca}</td>
        <td>${producto.categoria}</td>
        <td>${producto.modelo || ""}</td>
        <td>${producto.sku}</td>
        <td>${producto.precio} ${producto.moneda}</td>
        <td>${producto.stock}</td>
      `;

      tbody.appendChild(fila);
    });
  } catch (error) {
    console.error("Error cargando productos:", error);
  }
}

cargarProductos();