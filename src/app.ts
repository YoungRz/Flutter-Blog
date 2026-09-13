import express, { Request, Response } from "express";
import pool from "../db";
import cors from "cors";

const app = express();
app.use(cors());
app.use(express.json());

// ================= CATEGORIES =================

app.post("/categories", async (req: Request, res: Response) => {
  try {
    const { category_title } = req.body;
    if (!category_title) {
      return res.status(400).json({ message: "category_title wajib diisi" });
    }
    const [result]: any = await pool.query(
      "INSERT INTO categories (category_title) VALUES (?)",
      [category_title]
    );
    res.status(201).json({
      message: "Kategori berhasil ditambahkan",
      data: { id: result.insertId, category_title },
    });
  } catch (error: any) {
    res.status(500).json({ message: "Gagal menambahkan kategori", error: error.message });
  }
});

app.get("/categories", async (_req: Request, res: Response) => {
  try {
    const [rows] = await pool.query("SELECT * FROM categories ORDER BY id ASC");
    res.json({ data: rows });
  } catch (error: any) {
    res.status(500).json({ message: "Gagal mengambil kategori", error: error.message });
  }
});

app.get("/categories/:id", async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const [rows]: any = await pool.query("SELECT * FROM categories WHERE id = ?", [id]);
    if (rows.length === 0) {
      return res.status(404).json({ message: "Kategori tidak ditemukan" });
    }
    res.json({ data: rows[0] });
  } catch (error: any) {
    res.status(500).json({ message: "Gagal mengambil kategori", error: error.message });
  }
});

app.put("/categories/:id", async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { category_title } = req.body;
    if (!category_title) {
      return res.status(400).json({ message: "category_title wajib diisi" });
    }
    const [result]: any = await pool.query(
      "UPDATE categories SET category_title = ? WHERE id = ?",
      [category_title, id]
    );
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Kategori tidak ditemukan" });
    }
    res.json({ message: "Kategori berhasil diperbarui", data: { id, category_title } });
  } catch (error: any) {
    res.status(500).json({ message: "Gagal memperbarui kategori", error: error.message });
  }
});

app.delete("/categories/:id", async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const [result]: any = await pool.query("DELETE FROM categories WHERE id = ?", [id]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Kategori tidak ditemukan" });
    }
    res.json({ message: "Kategori berhasil dihapus" });
  } catch (error: any) {
    res.status(500).json({ message: "Gagal menghapus kategori", error: error.message });
  }
});

// ================= POSTS (versi simpel, tanpa upload gambar) =================

app.post("/posts", async (req: Request, res: Response) => {
  try {
    const { title, descriptions, category_id } = req.body;

    if (!title || !descriptions) {
      return res.status(400).json({ message: "title dan descriptions wajib diisi" });
    }

    const [result]: any = await pool.query(
      "INSERT INTO posts (title, descriptions, category_id) VALUES (?, ?, ?)",
      [title, descriptions, category_id ?? null]
    );

    res.status(201).json({
      message: "Post berhasil ditambahkan",
      data: { id: result.insertId, title, descriptions, category_id },
    });
  } catch (error: any) {
    res.status(500).json({ message: "Gagal menambahkan post", error: error.message });
  }
});

app.get("/posts", async (_req: Request, res: Response) => {
  try {
    const [rows] = await pool.query(
      `SELECT p.id, p.title, p.descriptions, p.image, p.category_id, c.category_title
       FROM posts p
       LEFT JOIN categories c ON p.category_id = c.id
       ORDER BY p.id ASC`
    );
    res.json({ data: rows });
  } catch (error: any) {
    res.status(500).json({ message: "Gagal mengambil post", error: error.message });
  }
});

app.get("/posts/:id", async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const [rows]: any = await pool.query(
      `SELECT p.id, p.title, p.descriptions, p.image, p.category_id, c.category_title
       FROM posts p
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE p.id = ?`,
      [id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ message: "Post tidak ditemukan" });
    }
    res.json({ data: rows[0] });
  } catch (error: any) {
    res.status(500).json({ message: "Gagal mengambil post", error: error.message });
  }
});

app.put("/posts/:id", async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { title, descriptions, category_id } = req.body;

    if (!title || !descriptions) {
      return res.status(400).json({ message: "title dan descriptions wajib diisi" });
    }

    const [result]: any = await pool.query(
      "UPDATE posts SET title = ?, descriptions = ?, category_id = ? WHERE id = ?",
      [title, descriptions, category_id ?? null, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Post tidak ditemukan" });
    }

    res.json({ message: "Post berhasil diperbarui", data: { id, title, descriptions, category_id } });
  } catch (error: any) {
    res.status(500).json({ message: "Gagal memperbarui post", error: error.message });
  }
});

app.delete("/posts/:id", async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const [result]: any = await pool.query("DELETE FROM posts WHERE id = ?", [id]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Post tidak ditemukan" });
    }
    res.json({ message: "Post berhasil dihapus" });
  } catch (error: any) {
    res.status(500).json({ message: "Gagal menghapus post", error: error.message });
  }
});

app.listen(777, () => {
  console.log("Server berjalan di http://localhost:777");
});

export default app;