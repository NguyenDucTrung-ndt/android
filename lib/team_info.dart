import 'models.dart';

/// Thông tin một thành viên trong nhóm.
class TeamMember {
  const TeamMember({
    required this.name,
    required this.studentId,
    required this.role,
  });

  final String name;
  final String studentId;
  final Bi role;
}

// TODO: Thay bằng thông tin thật của nhóm trước khi nộp.
const String kClassCode = 'N0x';
const String kTeamName = 'Nhóm ii';
const String kGithubUrl =
    'https://github.com/<tai-khoan>/2026_2027_1_1_LTTBDD_N0x_Nhom_ii';

const List<TeamMember> kTeamMembers = [
  TeamMember(
    name: 'Nguyễn Minh',
    studentId: '<Mã sinh viên 1>',
    role: Bi('Trưởng nhóm - Quản lý trạng thái, màn hình chi tiết',
        'Team leader - State management, detail screens'),
  ),
  TeamMember(
    name: '<Họ và tên thành viên 2>',
    studentId: '<Mã sinh viên 2>',
    role: Bi('Giao diện trang chủ, tìm kiếm, đa ngôn ngữ',
        'Home UI, search, localization'),
  ),
  TeamMember(
    name: '<Họ và tên thành viên 3>',
    studentId: '<Mã sinh viên 3>',
    role: Bi('Biểu mẫu công thức, danh sách đi chợ, kiểm thử',
        'Recipe form, shopping list, testing'),
  ),
];
