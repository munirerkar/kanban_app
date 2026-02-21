class AppConstants {
  // Bu sınıfın başlatılmasını engellemek için private constructor
  AppConstants._();

  // BASE URL
  static const String baseUrl = 'http://192.168.1.3:8080/api';

  // ENDPOINTS
  static const String tasksEndpoint = '/tasks';
  static const String usersEndpoint = '/users';
  static const String workspacesEndpoint = '/workspaces';

  // NESTED ENDPOINT BUILDERS
  static String workspaceEndpoint(int workspaceId) =>
      '$workspacesEndpoint/$workspaceId';

  static String workspaceTasksEndpoint(int workspaceId) =>
      '${workspaceEndpoint(workspaceId)}$tasksEndpoint';

  static String workspaceMembersEndpoint(int workspaceId) =>
      '${workspaceEndpoint(workspaceId)}/members';

  static String workspaceLeaveEndpoint(int workspaceId) =>
      '${workspaceEndpoint(workspaceId)}/leave';

  static String workspacesReorderEndpoint() =>
      '$workspacesEndpoint/reorder';
}