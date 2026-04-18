export interface Producto {
  id: number;
  nombre: string;
  descripcion: string;
  categoriaId: number;
  marcaId: number;
  modelo: string;
  sku: string;
  precio: number;
  moneda: string;
  stock: number;
  activo: boolean;
  createdAt: string;
  updatedAt: string;
}