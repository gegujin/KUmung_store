import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:kumeong_store/core/theme.dart';
import '../../models/post.dart';

class ProductEditScreen extends StatefulWidget {
  const ProductEditScreen({
    super.key,
    required this.productId,          // ✅ ID 기반
    this.initialProduct,              // ✅ 있으면 폼 초기값으로 사용
  });

  final String productId;
  final Product? initialProduct;

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  static const int _maxTags = 8;

  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _picker = ImagePicker();

  final List<File> _images = [];
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    final p = widget.initialProduct;
    if (p != null) {
      _titleCtrl.text = p.title;
      _priceCtrl.text = p.price.toString();
      _descCtrl.text = p.description;
    }
    // TODO(연동): widget.productId로 백엔드에서 상세를 불러와 폼 채우기
  }

  Future<void> _pickImage() async {
    if (_images.length >= 10) return;
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x != null) setState(() => _images.add(File(x.path)));
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 가격을 입력해 주세요.')),
      );
      return;
    }

    // TODO(연동):
    // - widget.productId가 존재하면 업데이트, 신규면 생성 API 호출
    // - 생성 시 서버가 부여한 productId로 교체 후 상세 페이지로 이동

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.initialProduct != null ? '수정 완료!' : '상품이 등록되었습니다!')),
    );

    // ✅ 뒤로가기(pop) 대신 앞으로 이동
    if (!mounted) return;
    context.goNamed(
      'productDetail',
      pathParameters: {'productId': widget.productId},
      // extra에 초안 데이터 전달 가능(최적화 용도, 신뢰는 서버)
      // extra: updatedProduct,
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<KuColors>()!;
    final isEditing = widget.initialProduct != null;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.primary,
        title: Text(isEditing ? '상품 수정' : '상품 등록', style: TextStyle(color: cs.onPrimary)),
        // ❌ 뒤로가기 버튼 사용 안 함
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 선택
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border.all(color: ext.accentSoft),
                  borderRadius: BorderRadius.circular(8),
                  image: _images.isNotEmpty
                      ? DecorationImage(image: FileImage(_images.first), fit: BoxFit.cover)
                      : null,
                ),
                child: _images.isEmpty
                    ? Icon(Icons.camera_alt, size: 36, color: cs.onSurfaceVariant)
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            Text('${_images.length}/10', style: TextStyle(fontSize: 12, color: cs.onSurface)),
            const SizedBox(height: 24),

            _buildLabel(context, '제목'),
            const SizedBox(height: 4),
            _buildTextField(_titleCtrl, '제목 작성', cs, ext),
            const SizedBox(height: 16),

            _buildLabel(context, '가격'),
            const SizedBox(height: 4),
            _buildTextField(_priceCtrl, '원', cs, ext, keyboardType: TextInputType.number),
            const SizedBox(height: 16),

            _buildLabel(context, '상세설명'),
            const SizedBox(height: 4),
            _buildTextField(_descCtrl, '제품 설명, 상세설명', cs, ext, maxLines: 6),
            const SizedBox(height: 24),

            _buildLabel(context, '태그'),
            const SizedBox(height: 8),
            _buildTagSelector(context, cs, ext),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            minimumSize: const Size.fromHeight(48),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          ),
          onPressed: _submit,
          child: Text(isEditing ? '수정하기' : '등록하기', style: TextStyle(fontSize: 18, color: cs.onPrimary)),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface));
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    ColorScheme cs,
    KuColors ext, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: cs.surface,
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: ext.accentSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: ext.accentSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        isDense: true,
      ),
      style: TextStyle(color: cs.onSurface),
    );
  }

  Widget _buildTagSelector(BuildContext context, ColorScheme cs, KuColors ext) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: const StadiumBorder(),
            ),
            onPressed: () async {
              if (_tags.length >= _maxTags) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('태그는 최대 $_maxTags개까지 선택할 수 있어요.')),
                );
                return;
              }
              final tag = await showDialog<String>(
                context: context,
                builder: (_) => const CategoryDialog(),
              );
              if (tag == null) return;
              if (_tags.contains(tag)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이미 선택한 태그예요.')),
                );
                return;
              }
              setState(() => _tags.add(tag));
            },
            child: const Text('필터 +'),
          ),
          const SizedBox(width: 8),
          ..._tags.map(
            (t) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(t, style: TextStyle(color: cs.onSurface)),
                backgroundColor: ext.accentSoft.withAlpha(50),
                shape: StadiumBorder(side: BorderSide(color: ext.accentSoft)),
                deleteIcon: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
                onDeleted: () => setState(() => _tags.remove(t)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 카테고리 선택 다이얼로그(모달 pop은 페이지 pop과 별개라 유지)
class CategoryDialog extends StatelessWidget {
  const CategoryDialog({super.key});

  static const Map<String, List<String>> categories = {
    '디지털기기': ['스마트폰', '태블릿/노트북', '데스크탑/모니터', '카메라/촬영장비', '게임기기', '웨어러블/주변기기'],
    '가전제품': ['TV/모니터', '냉장고', '세탁기/청소기', '에어컨/공기청정기', '주방가전', '뷰티가전'],
    '의류/패션': ['남성의류', '여성의류', '아동의류', '신발', '가방', '액세서리'],
    '가구/인테리어': ['침대/매트리스', '책상/의자', '소파', '수납/테이블', '조명/인테리어 소품'],
    '생활/주방': ['주방용품', '청소/세탁용품', '욕실/수납용품', '생활잡화', '기타 생활소품'],
    '유아/아동': ['유아의류', '장난감', '유모차/카시트', '육아용품', '침구/가구'],
    '취미/게임/음반': ['게임', '운동용품', '음반/LP', '악기', '아웃도어용품'],
    '도서/문구': ['소설/에세이', '참고서/전공서적', '만화책', '문구/사무용품', '기타 도서류'],
    '반려동물': ['사료/간식', '장난감/용품', '이동장/하우스', '의류/목줄', '기타 반려용품'],
    '기타 중고물품': ['티켓/상품권', '피규어/프라모델', '공구/작업도구', '수집품', '기타'],
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SimpleDialog(
      backgroundColor: cs.surface,
      title: Text('대분류 선택', style: TextStyle(color: cs.onSurface)),
      children: categories.keys.map((mainCat) {
        return SimpleDialogOption(
          child: Text(mainCat, style: TextStyle(color: cs.onSurface)),
          onPressed: () async {
            final sub = await showDialog<String>(
              context: context,
              builder: (_) => SimpleDialog(
                backgroundColor: cs.surface,
                title: Text('$mainCat - 소분류 선택', style: TextStyle(color: cs.onSurface)),
                children: categories[mainCat]!
                    .map((subCat) => SimpleDialogOption(
                          child: Text(subCat, style: TextStyle(color: cs.onSurface)),
                          onPressed: () => Navigator.pop(context, '$mainCat > $subCat'),
                        ))
                    .toList(),
              ),
            );
            if (sub != null && context.mounted) Navigator.pop(context, sub);
          },
        );
      }).toList(),
    );
  }
}
