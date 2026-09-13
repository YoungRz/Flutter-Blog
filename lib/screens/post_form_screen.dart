import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/category.dart';
import '../services/api_services.dart';

class PostFormScreen extends StatefulWidget {
  final Post? post;

  const PostFormScreen({super.key, this.post});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  int? _selectedCategoryId;
  late Future<List<Category>> _categoriesFuture;
  bool _isSaving = false;

  bool get _isEdit => widget.post != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _descController = TextEditingController(text: widget.post?.descriptions ?? '');
    _selectedCategoryId = widget.post?.categoryId;
    _categoriesFuture = ApiService.getCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (_isEdit) {
        await ApiService.updatePost(
          id: widget.post!.id,
          title: _titleController.text,
          descriptions: _descController.text,
          categoryId: _selectedCategoryId,
        );
      } else {
        await ApiService.createPost(
          title: _titleController.text,
          descriptions: _descController.text,
          categoryId: _selectedCategoryId,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Post' : 'Tambah Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 4,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Category>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator(color: Colors.black);
                  }
                  final categories = snapshot.data!;
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: categories
                        .map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.categoryTitle),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedCategoryId = value),
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _savePost,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}