const API_BASE = "/api";

async function cargarTablas() {
  try {
    const res = await fetch(`${API_BASE}/tablas`);
    const tablas = await res.json();

    const contenedor = document.getElementById("botones-tablas");
    contenedor.innerHTML = "";

    tablas.forEach(tabla => {
      const btn = document.createElement("button");
      btn.textContent = tabla;
      btn.onclick = () => cargarDatosTabla(tabla);

      contenedor.appendChild(btn);
    });
  } catch (error) {
    console.error("Error cargando tablas:", error);
  }
}

async function cargarDatosTabla(tabla) {
  try {
    const res = await fetch(`${API_BASE}/tabla/${tabla}`);
    const datos = await res.json();

    document.getElementById("titulo-tabla").textContent = `Tabla: ${tabla}`;

    const thead = document.getElementById("tabla-head");
    const tbody = document.getElementById("tabla-body");

    thead.innerHTML = "";
    tbody.innerHTML = "";

    if (datos.length === 0) return;

    // Cabeceras dinámicas
    const columnas = Object.keys(datos[0]);
    const filaHead = document.createElement("tr");

    columnas.forEach(col => {
      const th = document.createElement("th");
      th.textContent = col;
      filaHead.appendChild(th);
    });

    thead.appendChild(filaHead);

    // Filas
    datos.forEach(row => {
      const tr = document.createElement("tr");

      columnas.forEach(col => {
        const td = document.createElement("td");
        td.textContent = row[col];
        tr.appendChild(td);
      });

      tbody.appendChild(tr);
    });

  } catch (error) {
    console.error("Error cargando datos:", error);
  }
}

// Inicializar
cargarTablas();