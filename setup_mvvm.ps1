Write-Host "Creating Feature-based MVVM structure..."

# App
New-Item -ItemType Directory -Force -Path lib/app | Out-Null
New-Item -ItemType File -Force -Path `
lib/app/app.dart, `
lib/app/app_routes.dart, `
lib/app/app_theme.dart | Out-Null

# Core
$coreDirs = @(
    "lib/core/constants",
    "lib/core/utils",
    "lib/core/services",
    "lib/core/base"
)

foreach ($dir in $coreDirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

New-Item -ItemType File -Force -Path `
lib/core/constants/colors.dart, `
lib/core/constants/strings.dart, `
lib/core/constants/thresholds.dart, `
lib/core/utils/date_utils.dart, `
lib/core/utils/log_utils.dart, `
lib/core/utils/file_utils.dart, `
lib/core/services/api_service.dart, `
lib/core/services/websocket_service.dart, `
lib/core/services/auth_service.dart, `
lib/core/services/storage_service.dart, `
lib/core/base/base_viewmodel.dart, `
lib/core/base/base_state.dart | Out-Null

# Features
$features = @(
    "auth","dashboard","battery","temperature",
    "hand_telemetry","connectivity","camera",
    "navigation_test","reports"
)

foreach ($feature in $features) {
    New-Item -ItemType Directory -Force -Path "lib/features/$feature/model" | Out-Null
    New-Item -ItemType Directory -Force -Path "lib/features/$feature/view" | Out-Null
    New-Item -ItemType Directory -Force -Path "lib/features/$feature/viewmodel" | Out-Null
}

# Feature files
New-Item -ItemType File -Force -Path `
lib/features/auth/model/user_model.dart, `
lib/features/auth/view/login_view.dart, `
lib/features/auth/viewmodel/auth_viewmodel.dart, `
lib/features/dashboard/model/qc_status_model.dart, `
lib/features/dashboard/view/dashboard_view.dart, `
lib/features/dashboard/viewmodel/dashboard_viewmodel.dart, `
lib/features/battery/model/battery_model.dart, `
lib/features/battery/view/battery_view.dart, `
lib/features/battery/view/battery_graph_widget.dart, `
lib/features/battery/viewmodel/battery_viewmodel.dart, `
lib/features/temperature/model/temperature_model.dart, `
lib/features/temperature/view/temperature_view.dart, `
lib/features/temperature/viewmodel/temperature_viewmodel.dart, `
lib/features/hand_telemetry/model/hand_telemetry_model.dart, `
lib/features/hand_telemetry/view/hand_view.dart, `
lib/features/hand_telemetry/viewmodel/hand_viewmodel.dart, `
lib/features/connectivity/model/connectivity_model.dart, `
lib/features/connectivity/view/connectivity_view.dart, `
lib/features/connectivity/viewmodel/connectivity_viewmodel.dart, `
lib/features/camera/model/camera_result_model.dart, `
lib/features/camera/view/camera_view.dart, `
lib/features/camera/viewmodel/camera_viewmodel.dart, `
lib/features/navigation_test/model/navigation_result_model.dart, `
lib/features/navigation_test/view/navigation_view.dart, `
lib/features/navigation_test/viewmodel/navigation_viewmodel.dart, `
lib/features/reports/model/qc_report_model.dart, `
lib/features/reports/view/report_view.dart, `
lib/features/reports/viewmodel/report_viewmodel.dart | Out-Null

# Shared
New-Item -ItemType Directory -Force -Path lib/shared/widgets | Out-Null
New-Item -ItemType Directory -Force -Path lib/shared/enums | Out-Null

New-Item -ItemType File -Force -Path `
lib/shared/widgets/qc_card.dart, `
lib/shared/widgets/status_indicator.dart, `
lib/shared/widgets/qc_button.dart, `
lib/shared/widgets/loading_view.dart, `
lib/shared/enums/qc_status.dart, `
lib/shared/enums/connectivity_state.dart | Out-Null

Write-Host "MVVM folder structure created successfully."
