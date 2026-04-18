from flask import Flask, jsonify
from flask_cors import CORS
import pymysql
import os

app = Flask(__name__)
CORS(app)

DB_HOST = os.getenv("DB_HOST", "127.0.0.1")
DB_PORT = int(os.getenv("DB_PORT", "3306"))
DB_USER = os.getenv("DB_USER", "tarifario")
DB_PASSWORD = os.getenv("DB_PASSWORD", "password")
DB_NAME = os.getenv("DB_NAME", "tarifario")


def get_connection():
    return pymysql.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"})


@app.route("/productos", methods=["GET"])
def obtener_productos():
    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            sql = """
                SELECT
                    p.id,
                    p.nombre,
                    p.descripcion,
                    p.modelo,
                    p.sku,
                    p.precio,
                    p.moneda,
                    p.stock,
                    p.activo,
                    c.nombre AS categoria,
                    m.nombre AS marca
                FROM productos p
                JOIN categorias c ON p.categoria_id = c.id
                JOIN marcas m ON p.marca_id = m.id
                ORDER BY p.id
            """
            cursor.execute(sql)
            productos = cursor.fetchall()

        return jsonify(productos)

    finally:
        connection.close()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)