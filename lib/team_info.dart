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

const String kClassCode = 'N0x';
const String kTeamName = 'Nhóm ii';
const String kGithubUrl = 'https://github.com/NguyenDucTrung-ndt/android';

const List<TeamMember> kTeamMembers = [
  TeamMember(
    name: 'Nguyễn Minh Hưng',
    studentId: '<Mã sinh viên 1>',
    role: Bi(
      'Quản lý trạng thái, dữ liệu công thức đa quốc gia, chi tiết & chế độ nấu',
      'State management, international recipes data, detail & cooking mode',
    ),
  ),
  TeamMember(
    name: 'Nguyễn Đức Trung',
    studentId: '<Mã sinh viên 2>',
    role: Bi(
      'Giao diện Mobile Web, Trang chủ, Tìm kiếm, Danh mục, Đi chợ, Cá nhân, Cài đặt & Kiểm thử',
      'Mobile Web UI, Home, Search, Catalog, Shopping, Profile, Settings & Testing',
    ),
  ),
];
