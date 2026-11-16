import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/daily_activity/daily_activity_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/daily_activity/daily_activity_controller.dart';
import 'package:quran_app/screen/daily_activity/text_input_dialog.dart';
import 'package:quran_app/screen/home/home_screen.dart';
import 'package:quran_app/screen/home/home_screen_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

const _dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

IconData _iconFor(String? key) {
  switch (key) {
    case 'sholat_berjamaah':
      return LucideIcons.users;
    case 'tilawah':
      return LucideIcons.bookOpen;
    case 'sholat_malam':
      return LucideIcons.moon;
    case 'sholat_dhuha':
      return LucideIcons.sun;
    case 'sholat_rawatib':
      return LucideIcons.repeat;
    case 'dzikir_pagi':
      return LucideIcons.sunrise;
    case 'dzikir_petang':
      return LucideIcons.sunset;
    case 'murojaah':
      return LucideIcons.star;
    case 'puasa_sunnah':
      return LucideIcons.utensilsCrossed;
    case 'sedekah':
      return LucideIcons.handHeart;
    default:
      return LucideIcons.listChecks;
  }
}

class DailyActivityScreen extends StatelessWidget {
  const DailyActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<DailyActivityController>()) {
      Get.delete<DailyActivityController>();
    }
    final controller = Get.put(DailyActivityController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Aktivitas Harian', style: pSemiBold16),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (!AuthController.to.isLogin.value) {
            return _LoginPrompt();
          }
          return RefreshIndicator(
            onRefresh: () => controller.load(silent: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                _ScopeChips(controller: controller),
                _Body(controller: controller),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: Obx(() {
        final day = controller.day.value;
        if (!AuthController.to.isLogin.value || day == null || !day.canManage) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton.extended(
          onPressed: () => _showAddSheet(controller),
          backgroundColor: AppColor.primaryColor,
          icon: const Icon(LucideIcons.plus, color: Colors.white),
          label: Text('Tambah', style: pBold14.copyWith(color: Colors.white)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      }),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.listChecks,
              size: 48,
              color: AppColor.primaryColor,
            ),
            const SizedBox(height: 16),
            Text('Masuk untuk memulai', style: pBold18),
            const SizedBox(height: 8),
            Text(
              'Catat ibadah harianmu, sendiri atau bersama grup.',
              textAlign: TextAlign.center,
              style: pRegular12.copyWith(color: AppColor.globalTextSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.dialog(
                const HomeScreen().buildLoginDialog(
                  Get.find<HomeScreenController>(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Masuk',
                style: pBold14.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScopeChips extends StatelessWidget {
  final DailyActivityController controller;
  const _ScopeChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final groups = controller.myGroups;
      final selected = controller.groupId.value;
      return SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _chip(
              'Pribadi',
              LucideIcons.user,
              selected == null,
              () => controller.selectGroup(null),
            ),
            for (final g in groups)
              _chip(
                g.name,
                LucideIcons.users,
                selected == g.id,
                () => controller.selectGroup(g.id),
              ),
            _chip(
              'Buat / gabung grup',
              LucideIcons.plus,
              false,
              () => _showGroupActionsSheet(controller),
            ),
          ],
        ),
      );
    });
  }

  Widget _chip(String label, IconData icon, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 4, bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: active ? AppColor.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? AppColor.primaryColor : AppColor.globalBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: active ? Colors.white : null),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pSemiBold12.copyWith(
                    color: active ? Colors.white : AppColor.globalTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final DailyActivityController controller;
  const _Body({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final day = controller.day.value;
      if (day == null) {
        return Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Center(
            child: controller.isLoading.value
                ? const CircularProgressIndicator(strokeWidth: 2)
                : TextButton(
                    onPressed: controller.load,
                    child: const Text('Coba lagi'),
                  ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WeekStrip(controller: controller, day: day),
          const SizedBox(height: 16),
          _ProgressCard(controller: controller, day: day),
          const SizedBox(height: 16),
          if (day.activities.isEmpty)
            _EmptyState(day: day)
          else
            for (final item in day.activities)
              _ActivityTile(controller: controller, day: day, item: item),
          if (day.groupId != null && day.members.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Progres Anggota', style: pBold14),
            const SizedBox(height: 4),
            Text(
              controller.isToday
                  ? 'Hari ini'
                  : 'Tanggal ${controller.selectedDate.value}',
              style: pRegular12.copyWith(color: AppColor.globalTextSecondary),
            ),
            const SizedBox(height: 12),
            for (final m in day.members)
              _MemberRow(member: m, total: day.totalCount),
          ],
        ],
      );
    });
  }
}

class _WeekStrip extends StatelessWidget {
  final DailyActivityController controller;
  final DailyActivityDay day;
  const _WeekStrip({required this.controller, required this.day});

  @override
  Widget build(BuildContext context) {
    final primary = AppColor.primaryColor;
    return Row(
      children: [
        for (final d in day.week)
          Expanded(
            child: Builder(
              builder: (_) {
                final date = DateTime.parse(d.date);
                final selected = d.date == controller.selectedDate.value;
                return GestureDetector(
                  onTap: () => controller.selectDate(d.date),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? primary : AppColor.globalBorder,
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _dayNames[date.weekday - 1],
                          style: pRegular10.copyWith(
                            color: selected
                                ? Colors.white
                                : AppColor.globalTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: pBold14.copyWith(
                            color: selected ? Colors.white : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          d.isComplete
                              ? LucideIcons.circleCheck
                              : LucideIcons.circle,
                          size: 14,
                          color: d.isComplete
                              ? (selected ? Colors.white : primary)
                              : (selected
                                    ? Colors.white54
                                    : AppColor.globalBorder),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final DailyActivityController controller;
  final DailyActivityDay day;
  const _ProgressCard({required this.controller, required this.day});

  @override
  Widget build(BuildContext context) {
    final total = day.totalCount;
    final done = day.checkedCount;
    final value = total == 0 ? 0.0 : done / total;
    final complete = total > 0 && done >= total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.primaryColor.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  day.groupName ?? 'Ibadah harian saya',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pSemiBold12.copyWith(
                    color: AppColor.globalTextSecondary,
                  ),
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: pBold18.copyWith(color: AppColor.primaryColor),
              ),
              if (day.groupId != null)
                IconButton(
                  tooltip: 'Anggota & kode grup',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    LucideIcons.users,
                    size: 18,
                    color: AppColor.primaryColor,
                  ),
                  onPressed: () async {
                    await Get.toNamed(
                      Routes.activityGroup,
                      arguments: day.groupId,
                    );
                    controller.refreshGroupsAfterManage();
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              color: AppColor.primaryColor,
              backgroundColor: AppColor.globalBorder,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            total == 0
                ? 'Belum ada aktivitas.'
                : complete
                ? 'Alhamdulillah, semua selesai!'
                : '$done dari $total selesai',
            style: pRegular12.copyWith(color: AppColor.globalTextSecondary),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final DailyActivityDay day;
  const _EmptyState({required this.day});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(LucideIcons.listChecks, size: 40, color: AppColor.globalBorder),
          const SizedBox(height: 12),
          Text('Belum ada aktivitas', style: pSemiBold14),
          const SizedBox(height: 4),
          Text(
            day.canManage
                ? 'Tekan "Tambah" untuk memilih ibadah yang ingin dicatat.'
                : 'Pembuat grup belum menambahkan aktivitas.',
            textAlign: TextAlign.center,
            style: pRegular12.copyWith(color: AppColor.globalTextSecondary),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final DailyActivityController controller;
  final DailyActivityDay day;
  final DailyActivityItem item;
  const _ActivityTile({
    required this.controller,
    required this.day,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColor.primaryColor;
    final checked = item.checked;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: checked ? primary.withValues(alpha: 0.06) : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: checked
              ? primary.withValues(alpha: 0.4)
              : AppColor.globalBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => controller.toggle(item),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconFor(item.icon),
                        size: 18,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        style: pSemiBold14.copyWith(
                          decoration: checked
                              ? TextDecoration.lineThrough
                              : null,
                          color: checked ? AppColor.globalTextSecondary : null,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: checked ? primary : Colors.transparent,
                        border: Border.all(
                          color: checked ? primary : AppColor.globalBorder,
                          width: 1.5,
                        ),
                      ),
                      child: checked
                          ? const Icon(
                              LucideIcons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (day.canManage)
            PopupMenuButton<String>(
              icon: const Icon(LucideIcons.ellipsisVertical, size: 18),
              onSelected: (v) {
                if (v == 'edit') _showRenameDialog(controller, item);
                if (v == 'delete') _showDeleteDialog(controller, item);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Ubah nama')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
              ],
            )
          else
            const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final DailyActivityMember member;
  final int total;
  const _MemberRow({required this.member, required this.total});

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : (member.checked / total).clamp(0.0, 1.0);
    final picture = member.profilePicture;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColor.globalBorder,
            backgroundImage: (picture != null && picture.isNotEmpty)
                ? NetworkImage(picture)
                : null,
            child: (picture == null || picture.isEmpty)
                ? const Icon(LucideIcons.user, size: 16)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pSemiBold12,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 5,
                    color: AppColor.primaryColor,
                    backgroundColor: AppColor.globalBorder,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${member.checked}/$total', style: pSemiBold12),
        ],
      ),
    );
  }
}

// ─── dialogs ─────────────────────────────────────────────────────────────────

void _showGroupActionsSheet(DailyActivityController controller) {
  Get.bottomSheet(
    SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.usersRound),
              title: Text('Buat grup baru', style: pSemiBold14),
              subtitle: Text(
                'Atur aktivitas bersama dan bagikan kode ke anggota.',
                style: pRegular12,
              ),
              onTap: () {
                Get.back();
                showTextInputDialog(
                  title: 'Buat grup baru',
                  hint: 'Nama grup, mis. Keluarga',
                  confirmLabel: 'Buat',
                  onSubmit: controller.createGroup,
                );
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.logIn),
              title: Text('Gabung dengan kode', style: pSemiBold14),
              subtitle: Text(
                'Masukkan kode dari pembuat grup.',
                style: pRegular12,
              ),
              onTap: () {
                Get.back();
                showTextInputDialog(
                  title: 'Gabung dengan kode',
                  hint: 'Kode grup, mis. AB12CD',
                  confirmLabel: 'Gabung',
                  capitalization: TextCapitalization.characters,
                  maxLength: 12,
                  onSubmit: controller.joinGroup,
                );
              },
            ),
          ],
        ),
      ),
    ),
    backgroundColor: Get.context!.theme.scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}

void _showAddSheet(DailyActivityController controller) {
  Get.bottomSheet(
    _AddSheet(controller: controller),
    isScrollControlled: true,
    backgroundColor: Get.context!.theme.scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}

class _AddSheet extends StatefulWidget {
  final DailyActivityController controller;
  const _AddSheet({required this.controller});

  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _addCustom() async {
    final title = _text.text.trim();
    if (title.isEmpty) return;
    if (await widget.controller.addActivity(title)) _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tambah Aktivitas', style: pBold18),
            const SizedBox(height: 4),
            Text(
              'Pilih saran di bawah atau tulis sendiri.',
              style: pRegular12.copyWith(color: AppColor.globalTextSecondary),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final existing = (c.day.value?.activities ?? [])
                  .map((a) => a.title.toLowerCase())
                  .toSet();
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in c.presets)
                    Builder(
                      builder: (_) {
                        final added = existing.contains(p.title.toLowerCase());
                        return ActionChip(
                          avatar: Icon(
                            added ? LucideIcons.check : _iconFor(p.key),
                            size: 16,
                          ),
                          label: Text(p.title, style: pSemiBold12),
                          onPressed: (added || c.isSaving.value)
                              ? null
                              : () => c.addActivity(p.title, icon: p.key),
                        );
                      },
                    ),
                ],
              );
            }),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    maxLength: 100,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addCustom(),
                    decoration: InputDecoration(
                      hintText: 'Aktivitas lainnya…',
                      counterText: '',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Obx(
                  () => ElevatedButton(
                    onPressed: c.isSaving.value ? null : _addCustom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Tambah',
                      style: pBold14.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showRenameDialog(
  DailyActivityController controller,
  DailyActivityItem item,
) {
  showTextInputDialog(
    title: 'Ubah nama',
    confirmLabel: 'Simpan',
    initialValue: item.title,
    onSubmit: (title) => controller.renameActivity(item, title),
  );
}

void _showDeleteDialog(
  DailyActivityController controller,
  DailyActivityItem item,
) {
  Get.dialog(
    AlertDialog(
      title: Text('Hapus aktivitas?', style: pBold18),
      content: Text(
        '"${item.title}" dan seluruh riwayat centangnya akan dihapus'
        '${controller.groupId.value != null ? ' untuk semua anggota grup' : ''}.',
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.deleteActivity(item);
          },
          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
